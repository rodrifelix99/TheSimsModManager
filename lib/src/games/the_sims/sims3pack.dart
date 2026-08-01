import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/app_message.dart';
import '../../core/install_path.dart';

/// The container The Sims 3 distributes content in: a short header, an XML
/// manifest, then every file it carries laid end to end. Custom content
/// comes out of it as ordinary `.package` files, which is what makes it
/// worth unpacking - once they are in Packages they enable, disable and
/// remove like anything else in the library.
///
/// The layout is not documented publicly, so it was read off real files
/// (the EA store worlds, 811 entries between them, every one landing
/// exactly where the arithmetic below says it does and no byte left over):
///
/// ```text
/// uint32  length of the magic string, 7
/// char[]  "TS3Pack"
/// uint8   major, uint8 minor - 1.1 on everything seen
/// uint32  length of the XML manifest
/// char[]  the manifest, UTF-8
///         the payload: each <PackagedFile> at <Offset> from here
/// ```
///
/// Offsets count from the end of the manifest rather than the start of the
/// file, which is the one part of this a reader has to get right.
const sims3PackExtension = '.sims3pack';

bool isSims3PackPath(String path) =>
    p.extension(path).toLowerCase() == sims3PackExtension;

const _magic = 'TS3Pack';

/// Header bytes before the manifest: the length-prefixed magic (4 + 7),
/// the two version bytes, and the manifest's own length.
const _headerLength = 4 + _magic.length + 2 + 4;

/// A manifest longer than this is not one we wrote the reader for. Real
/// ones run to tens of kilobytes (the largest here, a 221-entry world
/// bundle, is 271 KB); the cap only exists so a file that is not a
/// sims3pack at all can't ask for an arbitrary allocation.
const _maxManifestLength = 64 * 1024 * 1024;

/// One file inside the container, as the manifest describes it.
class Sims3PackEntry {
  const Sims3PackEntry({
    required this.name,
    required this.contentType,
    required this.offset,
    required this.length,
  });

  /// The name the manifest gives it, a GUID for everything seen
  /// (`0x1c53....package`). Creators never chose these, the exporter did.
  final String name;

  /// What the game calls this piece of content, lowercased: `object`,
  /// `caspart`, `world`, `lot`, `unknown` for the thumbnail.
  final String contentType;

  /// Where the bytes start, counted from the end of the manifest.
  final int offset;

  final int length;
}

/// What a `.sims3pack` says it holds.
class Sims3PackManifest {
  const Sims3PackManifest({
    required this.displayName,
    required this.payloadStart,
    required this.entries,
  });

  /// The pack's own name, as the creator titled it. Empty when the
  /// manifest carries none.
  final String displayName;

  /// Offset in the file where entry offsets are measured from.
  final int payloadStart;

  final List<Sims3PackEntry> entries;

  /// Content that the game installs somewhere other than the mods folder,
  /// if this pack carries any (see [sims3PackLibraryContentTypes]).
  Set<String> get libraryContent => {
        for (final entry in entries)
          if (sims3PackLibraryContentTypes.contains(entry.contentType))
            entry.contentType,
      };
}

/// Content types the mod loader never reads out of Packages. A world is
/// installed by the game's Launcher into its own folder and registered
/// with the game; lots, households and room blueprints go to the in-game
/// Library. Every EA store world here is a world entry plus the objects
/// and CAS parts that world uses, so unpacking one "successfully" would
/// scatter thirty-odd EA objects through the mods folder and still leave
/// the user without the world they wanted - which is why one of these
/// refuses the whole file rather than installing the rest of it.
const sims3PackLibraryContentTypes = {
  'world',
  'lot',
  'household',
  'sim',
  'blueprint',
  'roomblueprint',
};

/// Reads the manifest of [pack] without touching the payload.
///
/// Throws a [ModContentException] when the bytes are not a readable
/// sims3pack - the same verdict-on-the-file the archive reader gives, so
/// callers that already tell those apart need no new case.
Future<Sims3PackManifest> readSims3PackManifest(File pack) async {
  final name = p.basename(pack.path);
  final handle = await pack.open();
  try {
    final length = await handle.length();
    if (length < _headerLength) throw _unreadable(name);
    final header = await handle.read(_headerLength);
    if (header.length < _headerLength) throw _unreadable(name);
    final words = ByteData.sublistView(header);
    final magicLength = words.getUint32(0, Endian.little);
    if (magicLength != _magic.length) throw _unreadable(name);
    final magic = String.fromCharCodes(header, 4, 4 + _magic.length);
    if (magic != _magic) throw _unreadable(name);
    final manifestLength = words.getUint32(_headerLength - 4, Endian.little);
    if (manifestLength == 0 ||
        manifestLength > _maxManifestLength ||
        _headerLength + manifestLength > length) {
      throw _unreadable(name);
    }
    final manifestBytes = await handle.read(manifestLength);
    if (manifestBytes.length < manifestLength) throw _unreadable(name);
    // A manifest that isn't valid UTF-8 is not one of ours; allowMalformed
    // keeps a stray byte in a creator's description from being fatal,
    // since nothing below reads the prose.
    final xml = utf8.decode(manifestBytes, allowMalformed: true);
    final payloadStart = _headerLength + manifestLength;
    final entries = _readEntries(xml, payloadStart, length);
    if (entries.isEmpty) throw _unreadable(name);
    return Sims3PackManifest(
      displayName: _tagValue(xml, 'DisplayName') ?? '',
      payloadStart: payloadStart,
      entries: entries,
    );
  } finally {
    await handle.close();
  }
}

ModContentException _unreadable(String name) =>
    ModContentException(AppMessage('sims3PackUnreadable', [name]));

/// The `<PackagedFile>` blocks, in manifest order. Deliberately not a
/// general XML parse: the four fields wanted here are exporter-written
/// (GUID names and decimal numbers), the app has no XML dependency, and
/// adding one is not free (see the release pin in CLAUDE.md). Anything
/// whose numbers don't sit inside the file is dropped rather than
/// trusted, so a malformed manifest costs its own entry.
List<Sims3PackEntry> _readEntries(String xml, int payloadStart, int fileLength) {
  final entries = <Sims3PackEntry>[];
  for (final block
      in RegExp(r'<PackagedFile>(.*?)</PackagedFile>', dotAll: true)
          .allMatches(xml)) {
    final body = block.group(1)!;
    final name = _tagValue(body, 'Name');
    final offset = int.tryParse(_tagValue(body, 'Offset') ?? '');
    final length = int.tryParse(_tagValue(body, 'Length') ?? '');
    if (name == null || name.isEmpty || offset == null || length == null) {
      continue;
    }
    if (offset < 0 || length < 0) continue;
    if (payloadStart + offset + length > fileLength) continue;
    entries.add(Sims3PackEntry(
      name: name,
      // `<ContentType>` is the manifest's; `<name>` inside `<metatags>`
      // is lowercase and a different thing, which is why these read the
      // exact capitalisation and only compare lowercased.
      contentType: (_tagValue(body, 'ContentType') ?? '').toLowerCase(),
      offset: offset,
      length: length,
    ));
  }
  return entries;
}

String? _tagValue(String xml, String tag) {
  final match = RegExp('<$tag>(.*?)</$tag>', dotAll: true).firstMatch(xml);
  return match?.group(1)?.trim();
}

/// Bytes copied per read while unpacking. Enough that a large package is
/// a handful of reads, small enough that the event loop keeps turning.
const _copyChunk = 1 << 20;

/// Unpacks the files in [pack] whose extension is in [fileExtensions]
/// under [destination] and returns them.
///
/// Everything is named after the pack rather than after the entry: the
/// exporter names entries by GUID, so the pack's own title is the only
/// name a person ever wrote, and a library card reading
/// `0xe4a3eb83c9f5bb1a3192944a69f9c025` is what a file name is for. A pack
/// carrying one mod file - which is most custom content - lands as that
/// one file; several land in a folder named after the pack, numbered
/// `Name-2`, `Name-3`... in manifest order, so the folder is still the
/// library's filter chip for the set. Two packs that share a title now
/// share a name too, and the second overwrites the first; that is the same
/// bargain every other install makes, and it is what keeps reinstalling a
/// pack from piling up copies of it.
///
/// Refuses the whole pack when the manifest carries content the mod
/// loader would never read (worlds, lots and the rest of
/// [sims3PackLibraryContentTypes]) - those install through the game's own
/// Launcher, and half-unpacking one helps nobody.
Future<List<File>> extractSims3Pack(
  File pack,
  Directory destination,
  Set<String> fileExtensions,
) async {
  final name = p.basename(pack.path);
  final manifest = await readSims3PackManifest(pack);
  final library = manifest.libraryContent;
  if (library.isNotEmpty) {
    throw ModContentException(AppMessage(
      library.contains('world') ? 'sims3PackWorld' : 'sims3PackLibrary',
      [name],
    ));
  }
  final wanted = [
    for (final entry in manifest.entries)
      if (fileExtensions.contains(p.extension(entry.name).toLowerCase()))
        entry,
  ];
  if (wanted.isEmpty) {
    throw ModContentException.noModFiles(fileExtensions, name);
  }
  final title = _packTitle(manifest.displayName, name);
  final handle = await pack.open();
  final taken = <String>{};
  final written = <File>[];
  try {
    for (final entry in wanted) {
      // The GUID is dropped, so two entries can arrive at one path and
      // neither asked to replace the other - which is the case
      // claimInstallTarget reads as "the source said overwrite".
      final named = '$title${p.extension(entry.name)}';
      final target = claimDistinctInstallTarget(destination.path,
          wanted.length == 1 ? named : p.join(title, named), taken);
      final file = File(target);
      await file.parent.create(recursive: true);
      final sink = file.openWrite();
      try {
        await handle.setPosition(manifest.payloadStart + entry.offset);
        var left = entry.length;
        while (left > 0) {
          final chunk = await handle.read(left < _copyChunk ? left : _copyChunk);
          if (chunk.isEmpty) break; // Truncated since the manifest was read.
          sink.add(chunk);
          left -= chunk.length;
        }
      } finally {
        await sink.close();
      }
      written.add(file);
    }
  } finally {
    await handle.close();
  }
  return written;
}

/// What installed files are named after: the pack's own title where it
/// has one, otherwise its file name without the extension. Creator-written
/// either way, so it goes through the same sanitising as any other install
/// path - and separators are folded first, because this is now a file name
/// as well as a folder's and a title reading `Hair/Dark` would otherwise
/// quietly install a folder nobody asked for.
String _packTitle(String displayName, String fileName) {
  final title = displayName.trim().isEmpty
      ? p.basenameWithoutExtension(fileName)
      : displayName.trim();
  return title.replaceAll(RegExp(r'[\\/]+'), '_');
}
