# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Riverpod / Freezed
-keep class **.freezed.** { *; }
-keep class **.riverpod.** { *; }

# Keep model classes used by JSON/Hive
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep Hive type adapters
-keep class * extends hive.ObjectAdapter { *; }
-keep class * extends hive.TypeAdapter { *; }

# General
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep class * {
    public private *;
}

# Play Core (needed by Flutter dynamic features)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# OkHttp (used by gRPC/Firebase)
-keep class com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**
-dontwarn okhttp3.**

# gRPC
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**

# Misc
-dontwarn java.lang.reflect.AnnotatedType

# Remove debug logging
-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
    static void checkParameterIsNotNull(...);
    static void checkNotNullExpressionValue(...);
    static void checkNotNull(...);
    static void checkFieldIsNotNull(...);
    static void checkReturnedValueIsNotNull(...);
}
