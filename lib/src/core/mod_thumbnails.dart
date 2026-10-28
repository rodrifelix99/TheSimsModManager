import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'app_data_dir.dart';
import 'dbpf.dart';

/// A picture the player picked for a mod themselves.
///
/// Most of the library draws itself from what is inside the files: a
/// `.package` carries its own preview and [scanPackage] finds it. Two of
/// the games carry nothing to find. The Sims 1 and The Sims 2 never put
/// a catalog thumbnail in a content file - the games render their own
/// into caches of their own, from content they have already loaded - so
/// every piece of CC for either one draws as stripes, and a shelf of
/// stripes is a shelf nobody can read. Asked for in issue #27.
///
/// So the answer here is the player's: point at an image and that is
/// what the mod looks like. It beats the embedded artwork wherever one
/// of each exists, because a picture somebody chose on purpose outranks
/// a picture a parser happened to find.
///
/// The image is **copied** into the app's own data folder rather than
/// referred to where it sits. A reference would be a thumbnail that goes
/// away when somebody tidies their Downloads folder, and the file it
/// names is usually the screenshot off a creator's post - exactly the
/// kind of thing that gets deleted once it has been used.
///
/// Records are per game and keyed by the path a mod carries while it is
/// switched on, relative to that game's mods folder - the same identity
/// the shop's install records, the settled clashes and the tags use, and
/// for the same reasons: a picture survives being disabled and
/// re-enabled, and it follows a mod that is moved into another folder
/// (`_repathRecords` rewrites it). Renaming or reinstalling the file
/// loses it, which is honest, since that is a different file.

/// The most one picture may weigh. Generous for a thumbnail - a PNG off
/// a creator's post is a megabyte or two - and a limit all the same,
/// because these are held in memory for as long as their game's library
/// is the one on screen. Every card decodes at the width it paints, so
/// what grows with a big picture is the bytes rather than the raster.
const maxThumbnailBytes = 8 << 20;

/// What the picker offers. Everything Flutter can draw from bytes, which
/// is also everything somebody is likely to have: `.webp` because that
/// is what half the web hands out now, `.bmp` because The Sims 1's own
/// skins are bitmaps and a player cropping one has no reason to convert
/// it.
const thumbnailFileExtensions = <String>[
  'png',
  'jpg',
  'jpeg',
  'gif',
  'webp',
  'bmp',
];

/// The extension [bytes] really are, or null when they are no picture
/// this app can draw. Read off the signature rather than the name the
/// file arrived with: a `.png` that is secretly something else would be
/// stored, recorded, and then draw as nothing at all.
String? thumbnailExtensionOf(Uint8List bytes) {
  if (isPng(bytes)) return 'png';
  if (isJpeg(bytes)) return 'jpg';
  if (_startsWith(bytes, 'GIF87a') || _startsWith(bytes, 'GIF89a')) {
    return 'gif';
  }
  // RIFF....WEBP - the four bytes between are the chunk length.
  if (_startsWith(bytes, 'RIFF') &&
      bytes.length >= 12 &&
      _startsWith(bytes.sublist(8, 12), 'WEBP')) {
    return 'webp';
  }
  if (_startsWith(bytes, 'BM')) return 'bmp';
  return null;
}

bool _startsWith(Uint8List bytes, String signature) {
  if (bytes.length < signature.length) return false;
  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature.codeUnitAt(i)) return false;
  }
  return true;
}

/// What the copy is called in the store. A hash of the record rather
/// than the mod's own name: a file name is somebody else's text, and one
/// mod has exactly one picture, so there is nothing a readable name would
/// buy that is worth a path component built out of it.
String thumbnailFileName(String record, String extension) =>
    '${sha1.convert(utf8.encode(record)).toString().substring(0, 16)}'
    '.$extension';

/// Where the copies live, per game, inside the app's own data folder.
Directory? modThumbnailFolder(String gameId) =>
    appDataFolder(['thumbnails', gameId]);

/// Whether [name] is a file this store could have written: a bare name,
/// nothing that climbs out of the folder. Checked on the way in because
/// the records are a preference file, and a preference file is editable.
bool isThumbnailFileName(String name) =>
    name.isNotEmpty &&
    name.length <= 64 &&
    !name.contains('/') &&
    !name.contains(r'\') &&
    !name.startsWith('.') &&
    thumbnailFileExtensions.any((e) => name.endsWith('.$e'));

/// The stored pictures by game id, then by mod path. A record that
/// doesn't parse costs only itself: the worst it can do is lose one mod
/// its picture, which is why nothing here throws on bad input.
Map<String, Map<String, String>> parseModThumbnails(String? source) {
  if (source == null || source.isEmpty) return {};
  try {
    final json = jsonDecode(source);
    if (json is! Map) return {};
    final thumbnails = <String, Map<String, String>>{};
    for (final game in json.entries) {
      final gameId = game.key;
      final mods = game.value;
      if (gameId is! String || mods is! Map) continue;
      final kept = <String, String>{};
      for (final mod in mods.entries) {
        final path = mod.key;
        final file = mod.value;
        if (path is! String || path.isEmpty) continue;
        if (file is! String || !isThumbnailFileName(file)) continue;
        kept[path] = file;
      }
      if (kept.isNotEmpty) thumbnails[gameId] = kept;
    }
    return thumbnails;
  } catch (_) {
    return {};
  }
}

String encodeModThumbnails(Map<String, Map<String, String>> thumbnails) =>
    jsonEncode({
      for (final game in thumbnails.entries)
        if (game.value.isNotEmpty) game.key: game.value,
    });
