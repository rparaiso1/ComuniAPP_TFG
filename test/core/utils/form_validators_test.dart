import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:comuniapp/core/utils/form_validators.dart';
import 'package:comuniapp/l10n/generated/app_localizations.dart';

/// Helper to get a BuildContext with localizations for testing.
Future<BuildContext> _getLocalizedContext(WidgetTester tester) async {
  late BuildContext capturedContext;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      home: Builder(
        builder: (context) {
          capturedContext = context;
          return const SizedBox();
        },
      ),
    ),
  );
  return capturedContext;
}

void main() {
  group('FormValidators.email', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.email(ctx)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.email(ctx)(''), isNotNull);
    });

    testWidgets('returns null for valid emails', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.email(ctx);
      expect(validator('user@example.com'), isNull);
      expect(validator('admin1@tfg.com'), isNull);
      expect(validator('test.name+tag@domain.org'), isNull);
      expect(validator('user123@sub.domain.com'), isNull);
    });

    testWidgets('returns error for invalid emails', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.email(ctx);
      expect(validator('notanemail'), isNotNull);
      expect(validator('missing@'), isNotNull);
      expect(validator('@nodomain.com'), isNotNull);
      expect(validator('spaces in@email.com'), isNotNull);
      expect(validator('user@.com'), isNotNull);
    });
  });

  group('FormValidators.password', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.password(ctx)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.password(ctx)(''), isNotNull);
    });

    testWidgets('returns error when shorter than minLength (default 6)', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.password(ctx);
      expect(validator('12345'), isNotNull);
      expect(validator('abc'), isNotNull);
    });

    testWidgets('returns null for valid passwords', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.password(ctx);
      expect(validator('123456'), isNull);
      expect(validator('longerpassword'), isNull);
    });

    testWidgets('respects custom minLength', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.password(ctx, minLength: 10)('12345678'), isNotNull);
      expect(FormValidators.password(ctx, minLength: 10)('1234567890'), isNull);
    });
  });

  group('FormValidators.strongPassword', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.strongPassword(ctx)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.strongPassword(ctx)(''), isNotNull);
    });

    testWidgets('returns error when shorter than 8 characters', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.strongPassword(ctx)('Ab1cdef'), isNotNull);
    });

    testWidgets('returns error when no uppercase letter', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.strongPassword(ctx)('abcdefg1'), isNotNull);
    });

    testWidgets('returns error when no lowercase letter', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.strongPassword(ctx)('ABCDEFG1'), isNotNull);
    });

    testWidgets('returns error when no digit', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.strongPassword(ctx)('Abcdefgh'), isNotNull);
    });

    testWidgets('returns null for valid strong passwords', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.strongPassword(ctx);
      expect(validator('Test1234'), isNull);
      expect(validator('MyP4ssword'), isNull);
      expect(validator('Abcdefg1'), isNull);
    });
  });

  group('FormValidators.confirmPassword', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.confirmPassword(ctx, 'Test1234')(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.confirmPassword(ctx, 'Test1234')(''), isNotNull);
    });

    testWidgets('returns error when passwords do not match', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.confirmPassword(ctx, 'Test1234')('Different1'), isNotNull);
    });

    testWidgets('returns null when passwords match', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.confirmPassword(ctx, 'Test1234')('Test1234'), isNull);
    });
  });

  group('FormValidators.required', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.required(ctx)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.required(ctx)(''), isNotNull);
    });

    testWidgets('returns error when only whitespace', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.required(ctx)('   '), isNotNull);
    });

    testWidgets('returns null for non-empty values', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.required(ctx);
      expect(validator('hello'), isNull);
      expect(validator(' hello '), isNull);
    });

    testWidgets('uses custom fieldName in error message', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final error = FormValidators.required(ctx, fieldName: 'El nombre')(null);
      expect(error, contains('El nombre'));
    });
  });

  group('FormValidators.minLength', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.minLength(ctx, 3)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.minLength(ctx, 3)(''), isNotNull);
    });

    testWidgets('returns error when shorter than minimum', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.minLength(ctx, 3)('ab'), isNotNull);
    });

    testWidgets('returns null when length exactly matches', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.minLength(ctx, 3)('abc'), isNull);
    });

    testWidgets('returns null when longer than minimum', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.minLength(ctx, 3)('abcdef'), isNull);
    });
  });

  group('FormValidators.maxLength', () {
    testWidgets('returns null when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.maxLength(ctx, 10)(null), isNull);
    });

    testWidgets('returns null when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.maxLength(ctx, 10)(''), isNull);
    });

    testWidgets('returns null when within limit', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.maxLength(ctx, 10)('hello'), isNull);
    });

    testWidgets('returns null when exactly at limit', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.maxLength(ctx, 10)('1234567890'), isNull);
    });

    testWidgets('returns error when exceeding limit', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.maxLength(ctx, 10)('12345678901'), isNotNull);
    });

    testWidgets('uses custom fieldName in error message', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final error = FormValidators.maxLength(ctx, 3, fieldName: 'Título')('toolong');
      expect(error, contains('Título'));
    });
  });

  group('FormValidators.phone', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.phone(ctx)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.phone(ctx)(''), isNotNull);
    });

    testWidgets('returns null for valid Spanish phone numbers', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.phone(ctx);
      expect(validator('612345678'), isNull);
      expect(validator('912345678'), isNull);
      expect(validator('+34612345678'), isNull);
      expect(validator('34612345678'), isNull);
    });

    testWidgets('accepts phones with spaces and dashes', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.phone(ctx);
      expect(validator('612 345 678'), isNull);
      expect(validator('612-345-678'), isNull);
    });

    testWidgets('returns error for invalid phone numbers', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.phone(ctx);
      expect(validator('123'), isNotNull);
      expect(validator('12345678'), isNotNull);
      expect(validator('abc'), isNotNull);
    });
  });

  group('FormValidators.number', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.number(ctx)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.number(ctx)(''), isNotNull);
    });

    testWidgets('returns error for non-numeric string', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.number(ctx);
      expect(validator('abc'), isNotNull);
      expect(validator('12.5'), isNotNull);
    });

    testWidgets('returns null for valid integers', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.number(ctx);
      expect(validator('0'), isNull);
      expect(validator('42'), isNull);
      expect(validator('-10'), isNull);
    });
  });

  group('FormValidators.numberRange', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.numberRange(ctx, 1, 10)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.numberRange(ctx, 1, 10)(''), isNotNull);
    });

    testWidgets('returns error for non-numeric string', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.numberRange(ctx, 1, 10)('abc'), isNotNull);
    });

    testWidgets('returns error when below minimum', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.numberRange(ctx, 1, 10)('0'), isNotNull);
    });

    testWidgets('returns error when above maximum', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.numberRange(ctx, 1, 10)('11'), isNotNull);
    });

    testWidgets('returns null when within range', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.numberRange(ctx, 1, 10)('5'), isNull);
    });

    testWidgets('returns null at range boundaries', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.numberRange(ctx, 1, 10);
      expect(validator('1'), isNull);
      expect(validator('10'), isNull);
    });
  });

  group('FormValidators.futureDate', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.futureDate(ctx, null), isNotNull);
    });

    testWidgets('returns error for past date', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      expect(FormValidators.futureDate(ctx, pastDate), isNotNull);
    });

    testWidgets('returns null for future date', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final futureDate = DateTime.now().add(const Duration(days: 1));
      expect(FormValidators.futureDate(ctx, futureDate), isNull);
    });

    testWidgets('uses custom fieldName in error message', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final error = FormValidators.futureDate(ctx, null, fieldName: 'La fecha de inicio');
      expect(error, contains('La fecha de inicio'));
    });
  });

  group('FormValidators.url', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.url(ctx)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.url(ctx)(''), isNotNull);
    });

    testWidgets('returns null for valid URLs', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.url(ctx);
      expect(validator('https://example.com'), isNull);
      expect(validator('http://example.com'), isNull);
      expect(validator('https://www.example.com/path?q=1'), isNull);
      expect(validator('https://sub.domain.org/file.pdf'), isNull);
    });

    testWidgets('returns error for invalid URLs', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.url(ctx);
      expect(validator('not a url'), isNotNull);
      expect(validator('ftp://example.com'), isNotNull);
      expect(validator('example.com'), isNotNull);
    });
  });

  group('FormValidators.postalCode', () {
    testWidgets('returns error when null', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.postalCode(ctx)(null), isNotNull);
    });

    testWidgets('returns error when empty', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      expect(FormValidators.postalCode(ctx)(''), isNotNull);
    });

    testWidgets('returns null for valid Spanish postal codes', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.postalCode(ctx);
      expect(validator('28001'), isNull);
      expect(validator('08080'), isNull);
      expect(validator('41001'), isNull);
    });

    testWidgets('returns error for invalid postal codes', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final validator = FormValidators.postalCode(ctx);
      expect(validator('1234'), isNotNull);
      expect(validator('123456'), isNotNull);
      expect(validator('abcde'), isNotNull);
      expect(validator('1234a'), isNotNull);
    });
  });

  group('FormValidators.combine', () {
    testWidgets('returns null when all validators pass', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final combined = FormValidators.combine([
        FormValidators.required(ctx),
        FormValidators.minLength(ctx, 3),
      ]);
      expect(combined('hello'), isNull);
    });

    testWidgets('returns first error when first validator fails', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final combined = FormValidators.combine([
        FormValidators.required(ctx),
        FormValidators.email(ctx),
      ]);
      final error = combined('');
      expect(error, isNotNull);
      expect(error, contains('obligatorio'));
    });

    testWidgets('returns second error when first passes but second fails', (tester) async {
      final ctx = await _getLocalizedContext(tester);
      final combined = FormValidators.combine([
        FormValidators.required(ctx),
        FormValidators.email(ctx),
      ]);
      final error = combined('notanemail');
      expect(error, isNotNull);
      expect(error, contains('correo'));
    });

    testWidgets('handles empty validator list', (tester) async {
      final combined = FormValidators.combine([]);
      expect(combined('anything'), isNull);
    });
  });
}
