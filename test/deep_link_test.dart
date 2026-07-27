// Every value that reaches parseDeepLink comes from a web page: a link a
// creator published, or one a page fired at the app unasked. So this is
// mostly a test about what is refused.
import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/deep_link.dart';

ModListingLink? _listing(String uri) =>
    parseDeepLink(Uri.parse(uri)) as ModListingLink?;

void main() {
  group('accepts', () {
    test('a mod link', () {
      expect(_listing('simsmodmanager://mod/abc123')?.listingId, 'abc123');
    });

    test('the scheme in any case, because the OS may normalise it', () {
      expect(_listing('SimsModManager://MOD/abc123')?.listingId, 'abc123');
    });

    test('the authority-less form some shells hand over', () {
      expect(_listing('simsmodmanager:mod/abc123')?.listingId, 'abc123');
    });

    test('a query, so a published link can grow one later', () {
      expect(_listing('simsmodmanager://mod/abc123?utm=tumblr#top')?.listingId,
          'abc123');
    });

    test('the id characters Firestore and the portal can produce', () {
      expect(_listing('simsmodmanager://mod/A-b_9')?.listingId, 'A-b_9');
      expect(_listing('simsmodmanager://mod/${'a' * 64}')?.listingId,
          'a' * 64);
    });
  });

  group('refuses', () {
    for (final uri in [
      'https://thesimsmodmanager.web.app/m/abc123',
      'file:///etc/passwd',
      // Deliberately not a verb we have: installing stays a button.
      'simsmodmanager://install/abc123',
      'simsmodmanager://mod',
      'simsmodmanager://mod/',
      'simsmodmanager://mod/abc/def',
      'simsmodmanager://mod/..',
      'simsmodmanager://mod/%2E%2E%2F%2E%2E%2Fusers',
      'simsmodmanager://mod/%2Fetc%2Fpasswd',
      'simsmodmanager://mod/abc 123',
      'simsmodmanager://mod/abc.123',
      'simsmodmanager://mod/café',
      'simsmodmanager://user:pw@mod/abc123',
      'simsmodmanager://mod:8080/abc123',
      'simsmodmanager:///abc123',
    ]) {
      test(uri, () => expect(parseDeepLink(Uri.parse(uri)), isNull));
    }

    test('an id longer than any we issue', () {
      expect(parseDeepLink(Uri.parse('simsmodmanager://mod/${'a' * 65}')),
          isNull);
    });
  });

  test('isShopListingId agrees with the parser', () {
    expect(isShopListingId('abc123'), isTrue);
    expect(isShopListingId(''), isFalse);
    expect(isShopListingId('a/b'), isFalse);
    expect(isShopListingId('..'), isFalse);
  });

  test('a listing link prints as the address it came from', () {
    expect(const ModListingLink('abc123').toString(),
        'simsmodmanager://mod/abc123');
  });
}
