# Add project specific ProGuard rules here.

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Keep source file names for stack traces
-keepattributes SourceFile,LineNumberTable

# Don't warn about missing classes
-dontwarn javax.**
-dontwarn org.codehaus.**
