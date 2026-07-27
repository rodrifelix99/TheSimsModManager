/// How the app names a subfolder of the mods directory.
///
/// A mod sitting in `Mods/Packages/cc/defaults` belongs to the folder
/// `cc/defaults`. That string is a key, not a path: it is compared, saved
/// in the folder arrangement and drawn on a chip, so it always joins on
/// `/` whatever the platform's own separator is.
library;

/// The separator between one folder key's segments.
const folderSeparator = '/';

/// The segments of [folder], outermost first: `cc/defaults` -> `[cc,
/// defaults]`.
List<String> folderSegments(String folder) => folder.split(folderSeparator);

/// [folder] and every folder above it, outermost first: `cc/defaults` ->
/// `[cc, cc/defaults]`. What a mod's folder contributes to, since a
/// parent holds everything below it.
List<String> folderAncestry(String folder) {
  final segments = folderSegments(folder);
  return [
    for (var i = 1; i <= segments.length; i++)
      segments.take(i).join(folderSeparator),
  ];
}

/// Whether [folder] is [ancestor] or sits below it.
bool folderIsWithin(String folder, String ancestor) =>
    folder == ancestor || folder.startsWith('$ancestor$folderSeparator');
