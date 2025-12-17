import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studify/providers/locale_provider.dart';

void main() {
  group('LocaleProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial locale is English', () {
      final provider = LocaleProvider();
      expect(provider.locale, const Locale('en'));
    });

    test('setLocale updates locale and notifies listeners', () async {
      final provider = LocaleProvider();
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setLocale(const Locale('id'));

      expect(provider.locale, const Locale('id'));
      expect(notified, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language_code'), 'id');
    });

    test('setLocale ignores unsupported locales', () {
      final provider = LocaleProvider();
      provider.setLocale(const Locale('fr'));

      expect(provider.locale, const Locale('en'));
    });

    test('loads locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'language_code': 'id'});
      
      final provider = LocaleProvider();
      // Wait for _loadLocale to complete (it's called in constructor but async)
      // Since we can't await the constructor, we wait a bit or check if we can trigger it.
      // Actually, _loadLocale is async but called in constructor without await.
      // We need to wait for the microtask queue.
      await Future.delayed(Duration.zero);

      expect(provider.locale, const Locale('id'));
    });
  });
}
