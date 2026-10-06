# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Play Billing Library
-keep class com.android.billingclient.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# SharedPreferences
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Play Core (for Flutter deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# AdMob / Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# RevenueCat (purchases_flutter)
-keep class com.revenuecat.** { *; }
-keep class com.android.billingclient.** { *; }

# flutter_local_notifications: ScheduledNotificationBootReceiver が Gson の TypeToken を使う。
# R8 が総称型の署名を消すと「TypeToken must be created with a type argument」で起動時に異常終了する。
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-dontwarn com.google.gson.**
