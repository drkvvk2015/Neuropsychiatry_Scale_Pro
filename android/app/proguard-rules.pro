# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:
-keepattributes *Annotation*
-keepattributes SourceFile
-keepattributes EnclosingMethod

# SQLite
-keep class * extends android.database.sqlite.SQLiteOpenHelper { *; }

# Prevent obfuscation of models
-keepclassmembers class com.neuroscale.neuroscale_pro.** { *; }

# Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items).
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

# With R8 full mode generic signatures are stripped for classes that are not kept.
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# Flutter plugins
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# Speech to text
-keep class com.google.android.gms.speech.** { *; }

# Keep data classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
    <fields>;
}