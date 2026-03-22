package com.myanmarhome.common

object Versions {
    const val compileSdk = 34
    const val minSdk = 24
    const val targetSdk = 34
    const val versionCode = 1
    const val versionName = "1.0.0"
    
    const val kotlin = "1.9.22"
    const val coroutines = "1.7.3"
    const val compose = "1.6.0"
    const val composeCompiler = "1.5.8"
    const val material3 = "1.2.0"
    const val hilt = "2.50"
    const val retrofit = "2.9.0"
    const val okhttp = "4.12.0"
    const val room = "2.6.1"
    const val coil = "2.5.0"
    const val navigation = "2.7.6"
    const val lifecycle = "2.7.0"
    const val dataStore = "1.0.0"
    const val accompanist = "0.32.0"
    const val maps = "18.2.0"
    const val mapsCompose = "4.3.0"
    const val easemob = "4.6.0"
    const val junit = "4.13.2"
    const val mockk = "1.13.8"
    const val turbine = "1.0.0"
}

object Libs {
    // Kotlin & Coroutines
    const val kotlinStdLib = "org.jetbrains.kotlin:kotlin-stdlib:${Versions.kotlin}"
    const val coroutinesCore = "org.jetbrains.kotlinx:kotlinx-coroutines-core:${Versions.coroutines}"
    const val coroutinesAndroid = "org.jetbrains.kotlinx:kotlinx-coroutines-android:${Versions.coroutines}"
    const val coroutinesTest = "org.jetbrains.kotlinx:kotlinx-coroutines-test:${Versions.coroutines}"
    
    // AndroidX Core
    const val coreKtx = "androidx.core:core-ktx:1.12.0"
    const val appcompat = "androidx.appcompat:appcompat:1.6.1"
    const val activityKtx = "androidx.activity:activity-ktx:1.8.2"
    const val fragmentKtx = "androidx.fragment:fragment-ktx:1.6.2"
    
    // Compose
    const val composeBom = "androidx.compose:compose-bom:2024.01.00"
    const val composeUi = "androidx.compose.ui:ui"
    const val composeUiGraphics = "androidx.compose.ui:ui-graphics"
    const val composeUiToolingPreview = "androidx.compose.ui:ui-tooling-preview"
    const val composeMaterial3 = "androidx.compose.material3:material3:${Versions.material3}"
    const val composeMaterialIcons = "androidx.compose.material:material-icons-extended"
    const val composeActivity = "androidx.activity:activity-compose:1.8.2"
    const val composeViewModel = "androidx.lifecycle:lifecycle-viewmodel-compose:${Versions.lifecycle}"
    const val composeRuntime = "androidx.compose.runtime:runtime"
    const val composeCompiler = "androidx.compose.compiler:compiler:${Versions.composeCompiler}"
    
    // Compose Debug
    const val composeUiTooling = "androidx.compose.ui:ui-tooling"
    const val composeUiTestManifest = "androidx.compose.ui:ui-test-manifest"
    
    // Navigation
    const val navigationCompose = "androidx.navigation:navigation-compose:${Versions.navigation}"
    const val hiltNavigationCompose = "androidx.hilt:hilt-navigation-compose:1.1.0"
    
    // Lifecycle
    const val lifecycleRuntime = "androidx.lifecycle:lifecycle-runtime-ktx:${Versions.lifecycle}"
    const val lifecycleViewModel = "androidx.lifecycle:lifecycle-viewmodel-ktx:${Versions.lifecycle}"
    const val lifecycleLiveData = "androidx.lifecycle:lifecycle-livedata-ktx:${Versions.lifecycle}"
    
    // Hilt
    const val hiltAndroid = "com.google.dagger:hilt-android:${Versions.hilt}"
    const val hiltCompiler = "com.google.dagger:hilt-compiler:${Versions.hilt}"
    const val hiltAndroidTesting = "com.google.dagger:hilt-android-testing:${Versions.hilt}"
    
    // Network
    const val retrofit = "com.squareup.retrofit2:retrofit:${Versions.retrofit}"
    const val retrofitGson = "com.squareup.retrofit2:converter-gson:${Versions.retrofit}"
    const val okhttp = "com.squareup.okhttp3:okhttp:${Versions.okhttp}"
    const val okhttpLogging = "com.squareup.okhttp3:logging-interceptor:${Versions.okhttp}"
    
    // Serialization
    const val gson = "com.google.code.gson:gson:2.10.1"
    const val kotlinxSerialization = "org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2"
    
    // Database
    const val roomRuntime = "androidx.room:room-runtime:${Versions.room}"
    const val roomKtx = "androidx.room:room-ktx:${Versions.room}"
    const val roomCompiler = "androidx.room:room-compiler:${Versions.room}"
    
    // DataStore
    const val dataStore = "androidx.datastore:datastore-preferences:${Versions.dataStore}"
    const val dataStoreCore = "androidx.datastore:datastore-preferences-core:${Versions.dataStore}"
    
    // Image Loading
    const val coil = "io.coil-kt:coil:${Versions.coil}"
    const val coilCompose = "io.coil-kt:coil-compose:${Versions.coil}"
    
    // Google Maps
    const val maps = "com.google.android.gms:play-services-maps:${Versions.maps}"
    const val mapsCompose = "com.google.maps.android:maps-compose:${Versions.mapsCompose}"
    const val mapsUtils = "com.google.maps.android:android-maps-utils:3.8.0"
    
    // Easemob IM
    const val easemob = "io.hyphenate:ease-im-kit:${Versions.easemob}"
    const val easemobChat = "io.hyphenate:hyphenate-chat:${Versions.easemob}"
    
    // Accompanist
    const val accompanistPermissions = "com.google.accompanist:accompanist-permissions:${Versions.accompanist}"
    const val accompanistPager = "com.google.accompanist:accompanist-pager:${Versions.accompanist}"
    const val accompanistSystemUi = "com.google.accompanist:accompanist-systemuicontroller:${Versions.accompanist}"
    
    // Utils
    const val timber = "com.jakewharton.timber:timber:5.0.1"
    const val leakCanary = "com.squareup.leakcanary:leakcanary-android:2.12"
    
    // Testing
    const val junit = "junit:junit:${Versions.junit}"
    const val junitExt = "androidx.test.ext:junit:1.1.5"
    const val espresso = "androidx.test.espresso:espresso-core:3.5.1"
    const val composeUiTest = "androidx.compose.ui:ui-test-junit4"
    const val mockk = "io.mockk:mockk:${Versions.mockk}"
    const val mockkAndroid = "io.mockk:mockk-android:${Versions.mockk}"
    const val turbine = "app.cash.turbine:turbine:${Versions.turbine}"
}
