plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("com.google.devtools.ksp")
    id("com.google.dagger.hilt.android")
    id("org.jetbrains.kotlin.plugin.parcelize")
    id("org.jetbrains.kotlin.plugin.serialization")
}

android {
    namespace = "com.myanmarhome.common"
    compileSdk = Versions.compileSdk

    defaultConfig {
        minSdk = Versions.minSdk
        targetSdk = Versions.targetSdk

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    buildFeatures {
        compose = true
        buildConfig = true
    }
    
    composeOptions {
        kotlinCompilerExtensionVersion = Versions.composeCompiler
    }
}

dependencies {
    // Kotlin
    api(Libs.kotlinStdLib)
    api(Libs.coroutinesCore)
    api(Libs.coroutinesAndroid)
    
    // AndroidX
    api(Libs.coreKtx)
    api(Libs.appcompat)
    api(Libs.activityKtx)
    api(Libs.fragmentKtx)
    
    // Compose BOM
    val composeBom = platform(Libs.composeBom)
    api(composeBom)
    androidTestApi(composeBom)
    
    // Compose
    api(Libs.composeUi)
    api(Libs.composeUiGraphics)
    api(Libs.composeUiToolingPreview)
    api(Libs.composeMaterial3)
    api(Libs.composeMaterialIcons)
    api(Libs.composeActivity)
    api(Libs.composeViewModel)
    api(Libs.composeRuntime)
    
    // Navigation
    api(Libs.navigationCompose)
    api(Libs.hiltNavigationCompose)
    
    // Lifecycle
    api(Libs.lifecycleRuntime)
    api(Libs.lifecycleViewModel)
    api(Libs.lifecycleLiveData)
    
    // Hilt
    api(Libs.hiltAndroid)
    ksp(Libs.hiltCompiler)
    
    // Network
    api(Libs.retrofit)
    api(Libs.retrofitGson)
    api(Libs.okhttp)
    api(Libs.okhttpLogging)
    
    // Serialization
    api(Libs.gson)
    api(Libs.kotlinxSerialization)
    
    // Database
    api(Libs.roomRuntime)
    api(Libs.roomKtx)
    ksp(Libs.roomCompiler)
    
    // DataStore
    api(Libs.dataStore)
    api(Libs.dataStoreCore)
    
    // Image Loading
    api(Libs.coil)
    api(Libs.coilCompose)
    
    // Google Maps
    api(Libs.maps)
    api(Libs.mapsCompose)
    api(Libs.mapsUtils)
    
    // Easemob IM
    api(Libs.easemob)
    api(Libs.easemobChat)
    
    // Accompanist
    api(Libs.accompanistPermissions)
    api(Libs.accompanistPager)
    api(Libs.accompanistSystemUi)
    
    // Utils
    api(Libs.timber)
    debugApi(Libs.leakCanary)
    
    // Testing
    testApi(Libs.junit)
    testApi(Libs.coroutinesTest)
    testApi(Libs.mockk)
    testApi(Libs.turbine)
    androidTestApi(Libs.junitExt)
    androidTestApi(Libs.espresso)
    androidTestApi(Libs.composeUiTest)
    androidTestApi(Libs.hiltAndroidTesting)
    androidTestApi(Libs.mockkAndroid)
    kspAndroidTest(Libs.hiltCompiler)
    
    // Debug
    debugApi(Libs.composeUiTooling)
    debugApi(Libs.composeUiTestManifest)
}
