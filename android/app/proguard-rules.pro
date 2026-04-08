# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# SQLCipher
-keep class net.zetetic.database.** { *; }
-keep class net.sqlcipher.** { *; }

# Speech to text
-keep class com.csdcorp.speech_to_text.** { *; }

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep Kotlin metadata
-keepattributes *Annotation*
-keepattributes RuntimeVisibleAnnotations
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Prevent stripping of R8/ProGuard annotations
-dontwarn kotlin.**
-dontwarn kotlinx.**
