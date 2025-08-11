import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'matching_screen.dart';
import 'sample_data_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('ユーザーが見つかりません')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('マッチングアプリ'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // ログアウト時にローカルに保存されたユーザーIDをクリア
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('guest_user_id');
              print('ゲストユーザーIDをクリアしました');
              
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink, Colors.purple],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Firestoreエラー: ${snapshot.error}');
              // エラーが発生した場合は、Firebase AuthのdisplayNameを使用
              final fallbackName = user.displayName ?? 'ユーザー';
              return _buildMainContent(fallbackName);
            }
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            
            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final nickname = userData?['nickname'] ?? user.displayName ?? 'ユーザー';
            
            // 詳細ログを追加
            print('=== MainScreen Firestoreデータ取得結果 ===');
            print('ユーザーID: ${user.uid}');
            print('ユーザーが匿名か: ${user.isAnonymous}');
            print('snapshot.hasData: ${snapshot.hasData}');
            print('snapshot.hasError: ${snapshot.hasError}');
            print('snapshot.error: ${snapshot.error}');
            print('userData: $userData');
            print('userDataから取得したnickname: ${userData?['nickname']}');
            print('user.displayName: ${user.displayName}');
            print('最終的に使用するnickname: $nickname');
            print('=== MainScreen Firestoreデータ取得結果 終了 ===');
            
            return _buildMainContent(nickname);
          },
        ),
      ),
    );
  }
  
  Widget _buildMainContent(String nickname) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                        const Icon(
                Icons.favorite,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 32),
              const Text(
                'オンボーディング完了！',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ようこそ、$nicknameさん！',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'マッチング機能を始めましょう！',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(MyApp.navigatorKey.currentContext!).push(
                    MaterialPageRoute(
                      builder: (context) => const MatchingScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'マッチングを始める',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(MyApp.navigatorKey.currentContext!).push(
                    MaterialPageRoute(
                      builder: (context) => const SampleDataScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'サンプルデータ作成',
                  style: TextStyle(fontSize: 16),
                ),
              ),
        ],
      ),
    );
  }
}
