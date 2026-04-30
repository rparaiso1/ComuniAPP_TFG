import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/core/utils/responsive.dart';

void main() {
  group('Breakpoints', () {
    test('compact breakpoint is 600', () {
      expect(Breakpoints.compact, 600);
    });

    test('medium breakpoint is 840', () {
      expect(Breakpoints.medium, 840);
    });

    test('expanded breakpoint is 1200', () {
      expect(Breakpoints.expanded, 1200);
    });

    test('large breakpoint is 1600', () {
      expect(Breakpoints.large, 1600);
    });
  });

  group('Responsive', () {
    Widget buildTestWidget({
      required double width,
      required void Function(BuildContext) onBuild,
    }) {
      return MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Builder(builder: (context) {
          onBuild(context);
          return const SizedBox();
        }),
      );
    }

    group('isMobile', () {
      testWidgets('returns true when width < 600', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          onBuild: (context) {
            expect(Responsive(context).isMobile, isTrue);
          },
        ));
      });

      testWidgets('returns true at width 599', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 599,
          onBuild: (context) {
            expect(Responsive(context).isMobile, isTrue);
          },
        ));
      });

      testWidgets('returns false at width 600', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 600,
          onBuild: (context) {
            expect(Responsive(context).isMobile, isFalse);
          },
        ));
      });

      testWidgets('returns false at width 1200', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1200,
          onBuild: (context) {
            expect(Responsive(context).isMobile, isFalse);
          },
        ));
      });
    });

    group('isTablet', () {
      testWidgets('returns false when width < 600', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          onBuild: (context) {
            expect(Responsive(context).isTablet, isFalse);
          },
        ));
      });

      testWidgets('returns true at width 600', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 600,
          onBuild: (context) {
            expect(Responsive(context).isTablet, isTrue);
          },
        ));
      });

      testWidgets('returns true at width 900', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 900,
          onBuild: (context) {
            expect(Responsive(context).isTablet, isTrue);
          },
        ));
      });

      testWidgets('returns true at width 1199', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1199,
          onBuild: (context) {
            expect(Responsive(context).isTablet, isTrue);
          },
        ));
      });

      testWidgets('returns false at width 1200', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1200,
          onBuild: (context) {
            expect(Responsive(context).isTablet, isFalse);
          },
        ));
      });
    });

    group('isDesktop', () {
      testWidgets('returns false when width < 1200', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1199,
          onBuild: (context) {
            expect(Responsive(context).isDesktop, isFalse);
          },
        ));
      });

      testWidgets('returns true at width 1200', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1200,
          onBuild: (context) {
            expect(Responsive(context).isDesktop, isTrue);
          },
        ));
      });

      testWidgets('returns true at width 1920', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1920,
          onBuild: (context) {
            expect(Responsive(context).isDesktop, isTrue);
          },
        ));
      });
    });

    group('value()', () {
      testWidgets('returns mobile value on small screens', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          onBuild: (context) {
            final result = Responsive(context).value(
              mobile: 'mobile',
              tablet: 'tablet',
              desktop: 'desktop',
            );
            expect(result, 'mobile');
          },
        ));
      });

      testWidgets('returns tablet value on medium screens', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 800,
          onBuild: (context) {
            final result = Responsive(context).value(
              mobile: 'mobile',
              tablet: 'tablet',
              desktop: 'desktop',
            );
            expect(result, 'tablet');
          },
        ));
      });

      testWidgets('returns desktop value on large screens', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1400,
          onBuild: (context) {
            final result = Responsive(context).value(
              mobile: 'mobile',
              tablet: 'tablet',
              desktop: 'desktop',
            );
            expect(result, 'desktop');
          },
        ));
      });

      testWidgets('falls back to mobile when tablet is null', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 800,
          onBuild: (context) {
            final result = Responsive(context).value(
              mobile: 'mobile',
            );
            expect(result, 'mobile');
          },
        ));
      });

      testWidgets('falls back to tablet when desktop is null', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1400,
          onBuild: (context) {
            final result = Responsive(context).value(
              mobile: 'mobile',
              tablet: 'tablet',
            );
            expect(result, 'tablet');
          },
        ));
      });

      testWidgets('falls back to mobile when both tablet and desktop are null on desktop', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1400,
          onBuild: (context) {
            final result = Responsive(context).value(
              mobile: 'mobile',
            );
            expect(result, 'mobile');
          },
        ));
      });
    });

    group('gridColumns', () {
      testWidgets('returns 2 on mobile', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          onBuild: (context) {
            expect(Responsive(context).gridColumns, 2);
          },
        ));
      });

      testWidgets('returns 3 on tablet', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 800,
          onBuild: (context) {
            expect(Responsive(context).gridColumns, 3);
          },
        ));
      });

      testWidgets('returns 4 on desktop', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1400,
          onBuild: (context) {
            expect(Responsive(context).gridColumns, 4);
          },
        ));
      });
    });

    group('contentMaxWidth', () {
      testWidgets('returns infinity on mobile', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          onBuild: (context) {
            expect(Responsive(context).contentMaxWidth, double.infinity);
          },
        ));
      });

      testWidgets('returns 720 on tablet', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 800,
          onBuild: (context) {
            expect(Responsive(context).contentMaxWidth, 720);
          },
        ));
      });

      testWidgets('returns 960 on desktop', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1400,
          onBuild: (context) {
            expect(Responsive(context).contentMaxWidth, 960);
          },
        ));
      });
    });

    group('horizontalPadding', () {
      testWidgets('returns 16 on mobile', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 400,
          onBuild: (context) {
            expect(Responsive(context).horizontalPadding, 16);
          },
        ));
      });

      testWidgets('returns 24 on tablet', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 800,
          onBuild: (context) {
            expect(Responsive(context).horizontalPadding, 24);
          },
        ));
      });

      testWidgets('returns 32 on desktop', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          width: 1400,
          onBuild: (context) {
            expect(Responsive(context).horizontalPadding, 32);
          },
        ));
      });
    });
  });

  group('ResponsiveExtension', () {
    testWidgets('context.responsive returns a Responsive instance', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(500, 800)),
          child: Builder(builder: (context) {
            final responsive = context.responsive;
            expect(responsive, isA<Responsive>());
            expect(responsive.isMobile, isTrue);
            return const SizedBox();
          }),
        ),
      );
    });
  });
}
