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
