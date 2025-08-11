import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SampleDataScreen extends StatefulWidget {
  const SampleDataScreen({super.key});

  @override
  State<SampleDataScreen> createState() => _SampleDataScreenState();
}

class _SampleDataScreenState extends State<SampleDataScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  final List<Map<String, dynamic>> _sampleUsers = [
    {
      'uid': 'test_user_sakura',
      'nickname': 'さくら',
      'age': 25,
      'gender': 'female',
      'location': '東京都',
      'bio': 'こんにちは！映画鑑賞と料理が好きです。',
      'interests': ['映画', '料理', 'カフェ巡り'],
      'occupation': '会社員',
      'photos': [],
      'isGuest': false,
      'provider': 'test',
      'completionLevel': 'complete',
      'createdAt': null,
      'updatedAt': null,
    },
    {
      'uid': 'test_user_miki',
      'nickname': 'みき',
      'age': 23,
      'gender': 'female',
      'location': '神奈川県',
      'bio': 'アウトドアが好きです！一緒に山登りしませんか？',
      'interests': ['アウトドア', '山登り', 'キャンプ'],
      'occupation': '学生',
      'photos': [],
      'isGuest': false,
      'provider': 'test',
      'completionLevel': 'complete',
      'createdAt': null,
      'updatedAt': null,
    },
    {
      'uid': 'test_user_yui',
      'nickname': 'ゆい',
      'age': 27,
      'gender': 'female',
      'location': '大阪府',
      'bio': 'カフェ巡りが趣味です。おいしいコーヒーを飲みながらお話しましょう。',
      'interests': ['カフェ巡り', 'コーヒー', '読書'],
      'occupation': 'デザイナー',
      'photos': [],
      'isGuest': false,
      'provider': 'test',
      'completionLevel': 'complete',
      'createdAt': null,
      'updatedAt': null,
    },
    {
      'uid': 'test_user_ayaka',
      'nickname': 'あやか',
      'age': 24,
      'gender': 'female',
      'location': '愛知県',
      'bio': 'ヨガとフィットネスが好きです。健康的な生活を心がけています。',
      'interests': ['ヨガ', 'フィットネス', '健康'],
      'occupation': 'インストラクター',
      'photos': [],
      'isGuest': false,
      'provider': 'test',
      'completionLevel': 'complete',
      'createdAt': null,
      'updatedAt': null,
    },
    {
      'uid': 'test_user_nana',
      'nickname': 'なな',
      'age': 26,
      'gender': 'female',
      'location': '福岡県',
      'bio': '読書と音楽が好きです。新しい本や音楽を教えてください。',
      'interests': ['読書', '音楽', 'アート'],
      'occupation': 'ライター',
      'photos': [],
      'isGuest': false,
      'provider': 'test',
      'completionLevel': 'complete',
      'createdAt': null,
      'updatedAt': null,
    },
    // 男性ユーザーも追加（テスト用）
    {
      'uid': 'test_user_ken',
      'nickname': 'けん',
      'age': 28,
      'gender': 'male',
      'location': '北海道',
      'bio': 'スキーと温泉が好きです。冬の北海道は最高です！',
      'interests': ['スキー', '温泉', '旅行'],
      'occupation': 'エンジニア',
      'photos': [],
      'isGuest': false,
      'provider': 'test',
      'completionLevel': 'complete',
      'createdAt': null,
      'updatedAt': null,
    },
    {
      'uid': 'test_user_taro',
      'nickname': 'たろう',
      'age': 30,
      'gender': 'male',
      'location': '沖縄県',
      'bio': '海とサンゴが大好きです。一緒にダイビングしませんか？',
      'interests': ['ダイビング', '海', 'サンゴ'],
      'occupation': 'ガイド',
      'photos': [],
      'isGuest': false,
      'provider': 'test',
      'completionLevel': 'complete',
      'createdAt': null,
      'updatedAt': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('サンプルデータ作成'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'テスト用のサンプルユーザーを作成します',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '作成されるユーザー数: ${_sampleUsers.length}人',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _createSampleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('サンプルデータを作成', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('成功') ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('成功') ? Colors.green.shade800 : Colors.red.shade800,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _sampleUsers.length,
                itemBuilder: (context, index) {
                  final user = _sampleUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user['gender'] == 'female' ? Colors.pink.shade100 : Colors.blue.shade100,
                        child: Text(
                          user['nickname'][0],
                          style: TextStyle(
                            color: user['gender'] == 'female' ? Colors.pink.shade800 : Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text('${user['nickname']} (${user['age']}歳)'),
                      subtitle: Text('${user['location']} - ${user['bio']}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: user['gender'] == 'female' ? Colors.pink.shade100 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user['gender'] == 'female' ? '女性' : '男性',
                          style: TextStyle(
                            color: user['gender'] == 'female' ? Colors.pink.shade800 : Colors.blue.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSampleData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'サンプルデータを作成中...';
    });

    try {
      final batch = FirebaseFirestore.instance.batch();
      int successCount = 0;
      int errorCount = 0;

      for (final userData in _sampleUsers) {
        try {
          // 既存のユーザーをチェック
          final existingDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userData['uid'])
              .get();

          // タイムスタンプを設定
          final userDataWithTimestamp = Map<String, dynamic>.from(userData);
          userDataWithTimestamp['createdAt'] = Timestamp.now();
          userDataWithTimestamp['updatedAt'] = Timestamp.now();

          if (existingDoc.exists) {
            // 既存の場合は更新
            batch.update(
              FirebaseFirestore.instance.collection('users').doc(userData['uid']),
              userDataWithTimestamp,
            );
          } else {
            // 新規の場合は作成
            batch.set(
              FirebaseFirestore.instance.collection('users').doc(userData['uid']),
              userDataWithTimestamp,
            );
          }
          successCount++;
        } catch (e) {
          errorCount++;
          print('ユーザー作成エラー: ${userData['nickname']} - $e');
        }
      }

      // バッチ処理を実行
      await batch.commit();

      setState(() {
        _statusMessage = '✅ サンプルデータの作成が完了しました！\n'
            '成功: $successCount件\n'
            'エラー: $errorCount件';
      });

      // 3秒後にメッセージをクリア
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = '';
          });
        }
      });

    } catch (e) {
      setState(() {
        _statusMessage = '❌ エラーが発生しました: $e';
      });
      print('サンプルデータ作成エラー: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
