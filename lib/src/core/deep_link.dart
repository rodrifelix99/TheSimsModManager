/// The addresses the app answers to from outside itself.
///
/// A mod's page on the website carries an "Install with The Sims Mod
/// Manager" button, and what that button opens is one of these. So every
/// value here arrives from a web page: a link the user clicked, or one a
/// page fired at them. The grammar below is a whitelist for that reason -
/// anything that isn't exactly an address we meant to publish is dropped
/// without a word, and the one address there is opens a listing rather
/// than installing it. Installing stays a button the user presses, on a
/// screen that has already told them what it is.
library;

/// The scheme registered with the OS, and the one half of every link that
/// is never translated.
const String appUrlScheme = 'simsmodmanager';

/// The host part of a mod link: `simsmodmanager://mod/<id>`.
const String _modHost = 'mod';

/// Firestore's own ids are twenty characters of ASCII letters and digits.
/// Hyphen and underscore are allowed on top of that because The Exchange
/// could grow hand-written ids later, and nothing else is, because this
/// string is about to become a path in a URL we build.
final RegExp _listingId = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

/// Whether [id] is a listing id this app will go looking for.
bool isShopListingId(String id) => _listingId.hasMatch(id);

/// Something the app was asked to open.
sealed class DeepLink {
  const DeepLink();
}

/// One listing on The Exchange, by id. The app opens its page; it does
/// not install it.
final class ModListingLink extends DeepLink {
  const ModListingLink(this.listingId);

  final String listingId;

  @override
  bool operator ==(Object other) =>
      other is ModListingLink && other.listingId == listingId;

  @override
  int get hashCode => listingId.hashCode;

  @override
  String toString() => '$appUrlScheme://$_modHost/$listingId';
}

/// [uri] as something to open, or null when it is anything else at all.
///
/// Accepts `simsmodmanager://mod/<id>`, and the authority-less
/// `simsmodmanager:mod/<id>` that some browsers and shells hand over
/// instead. A query or fragment is ignored rather than refused, so
/// hanging a `?utm=...` on a published link later cannot break the builds
/// that are already out there.
DeepLink? parseDeepLink(Uri uri) {
  // Uri lowercases the scheme and the host for us, so a link typed in
  // capitals still arrives here as itself.
  if (uri.scheme != appUrlScheme) return null;
  // Credentials or a port in a link of ours means it was not written by
  // us, whatever the rest of it says.
  if (uri.userInfo.isNotEmpty || uri.hasPort) return null;

  final segments = uri.pathSegments;
  final String? id;
  if (uri.host == _modHost) {
    id = segments.length == 1 ? segments.first : null;
  } else if (uri.host.isEmpty &&
      segments.length == 2 &&
      segments.first == _modHost) {
    id = segments[1];
  } else {
    id = null;
  }

  if (id == null || !isShopListingId(id)) return null;
  return ModListingLink(id);
}
