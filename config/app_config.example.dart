// アプリ設定のテンプレートファイル
// このファイルを app_config.dart にコピーして、実際の値を設定してください
// app_config.dart ファイルは .gitignore に含まれているため、Gitにコミットされません

class AppConfig {
  // Firebase Project Settings
  static const String firebaseProjectId = 'YOUR_PROJECT_ID';
  static const String firebaseProjectNumber = 'YOUR_PROJECT_NUMBER';
  
  // Firebase App IDs
  static const String firebaseAndroidAppId = 'YOUR_ANDROID_APP_ID';
  static const String firebaseIosAppId = 'YOUR_IOS_APP_ID';
  static const String firebaseMacosAppId = 'YOUR_MACOS_APP_ID';
  static const String firebaseWebAppId = 'YOUR_WEB_APP_ID';
  static const String firebaseWindowsAppId = 'YOUR_WINDOWS_APP_ID';
  
  // Firebase API Keys
  static const String firebaseAndroidApiKey = 'YOUR_ANDROID_API_KEY';
  static const String firebaseIosApiKey = 'YOUR_IOS_API_KEY';
  static const String firebaseMacosApiKey = 'YOUR_MACOS_API_KEY';
  static const String firebaseWebApiKey = 'YOUR_WEB_API_KEY';
  static const String firebaseWindowsApiKey = 'YOUR_WINDOWS_API_KEY';
  
  // Firebase Messaging
  static const String firebaseMessagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  
  // Firebase Storage
  static const String firebaseStorageBucket = 'YOUR_PROJECT_ID.firebasestorage.app';
  
  // Firebase Analytics
  static const String firebaseWebMeasurementId = 'YOUR_WEB_MEASUREMENT_ID';
  static const String firebaseWindowsMeasurementId = 'YOUR_WINDOWS_MEASUREMENT_ID';
  
  // Google Sign-In Configuration
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String googleReversedClientId = 'YOUR_REVERSED_CLIENT_ID';
  
  // Bundle IDs
  static const String iosBundleId = 'com.app.matching.matchingApp';
  static const String androidPackageName = 'com.app.matching.matching_app';
  static const String macosBundleId = 'com.app.matching.matchingApp';
  
  // App Configuration
  static const String appName = 'MatchingApp';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
}
