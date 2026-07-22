/// The running app's version, mirroring `version:` in pubspec.yaml.
///
/// tool/release.dart rewrites this constant on every release so the two
/// never drift (app_version_test.dart pins them together). Don't edit the
/// value by hand; run the release script instead.
const String appVersion = '1.0.4';
