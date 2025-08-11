import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'screens/matching_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase初期化（重複チェック付き）
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: AppConfig.firebaseIosApiKey,
        appId: AppConfig.firebaseIosAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        storageBucket: AppConfig.firebaseStorageBucket,
        iosBundleId: AppConfig.iosBundleId,
      ),
    );
  } catch (e) {
    // 既に初期化されている場合は無視
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized');
    } else {
      rethrow;
    }
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // NavigatorKeyを定義
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Matching App',
      navigatorKey: MyApp.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          if (user != null) {
            // ユーザーが認証されている場合、プロフィール設定が必要かチェック
            return _buildAuthenticatedScreen(user);
          }
          return const AuthScreen();
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) =>
            Scaffold(body: Center(child: Text('エラー: $error'))),
      ),
    );
  }

  Widget _buildAuthenticatedScreen(User user) {
    // Firestoreからプロフィール情報を取得して、完了状態をチェック
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Firestoreエラー: ${snapshot.error}');
          // エラーの場合は、ユーザーが匿名かどうかで判断
          if (user.isAnonymous) {
            // 匿名ユーザーの場合はオンボーディング画面を表示
            return const OnboardingScreen();
          } else {
            // 認証済みユーザーの場合はメイン画面を表示
            return const MainScreen();
          }
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final completionLevel = userData?['completionLevel'];
        
        // 詳細ログを追加
        print('=== Firestoreデータ取得結果 ===');
        print('ユーザーID: ${user.uid}');
        print('ユーザーが匿名か: ${user.isAnonymous}');
        print('snapshot.hasData: ${snapshot.hasData}');
        print('snapshot.hasError: ${snapshot.hasError}');
        print('snapshot.error: ${snapshot.error}');
        print('userData: $userData');
        print('completionLevel: $completionLevel (型: ${completionLevel.runtimeType})');
        
        // completionLevelの型をチェックして適切に処理
        bool isProfileComplete = false;
        if (completionLevel != null) {
          if (completionLevel is int) {
            isProfileComplete = completionLevel >= 100;
            print('completionLevelは数値: $completionLevel >= 100 = $isProfileComplete');
          } else if (completionLevel is String) {
            // ProfileCompletionLevel列挙型の文字列表現をチェック
            // "complete"の場合のみ完了とみなす
            isProfileComplete = completionLevel == "complete";
            print('completionLevelは文字列: "$completionLevel" == "complete" = $isProfileComplete');
          } else {
            print('completionLevelの型が不明: ${completionLevel.runtimeType}');
          }
        } else {
          print('completionLevelがnull');
        }
        
        print('プロフィール完了判定: $isProfileComplete');
        print('表示する画面: ${isProfileComplete ? "MainScreen" : "OnboardingScreen"}');
        print('=== Firestoreデータ取得結果 終了 ===');
        
        // プロフィール完了の場合はマッチング画面、そうでなければオンボーディング
        if (isProfileComplete) {
          return const MatchingScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}


