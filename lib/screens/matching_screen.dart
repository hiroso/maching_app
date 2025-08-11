import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/user_profile.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  final CardSwiperController _controller = CardSwiperController();
  List<UserProfile> _potentialMatches = [];
  final List<UserProfile> _likedUsers = [];
  final List<UserProfile> _matchedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPotentialMatches();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPotentialMatches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // 現在のユーザーのプロフィールを取得
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!currentUserDoc.exists) return;

      final currentUserProfile = UserProfile.fromFirestore(currentUserDoc);

      // 他のユーザーを取得（基本的な条件のみ）
      final otherUsersQuery = FirebaseFirestore.instance
          .collection('users');

      final otherUsersSnapshot = await otherUsersQuery.get();
      
      // デバッグ: 生データを確認
      print('=== 生データ確認 ===');
      for (final doc in otherUsersSnapshot.docs) {
        final data = doc.data();
        print('ドキュメントID: ${doc.id}');
        print('生データ: $data');
        print('nickname: ${data['nickname']}');
        print('age: ${data['age']}');
        print('gender: ${data['gender']}');
        print('---');
      }
      
      final otherUsers = otherUsersSnapshot.docs
          .map((doc) {
            final profile = UserProfile.fromFirestore(doc);
            print('変換後: ${profile.nickname} (${profile.age}歳, ${profile.gender})');
            return profile;
          })
          .toList();

      // フィルタリング（基本的な条件のみ）
      final filteredUsers = otherUsers.where((user) {
        // 自分以外のユーザーのみ
        if (user.uid == currentUser.uid) return false;
        
        // プロフィールが不完全なユーザーを除外
        if (user.nickname == null || user.age == null || user.gender == null) return false;
        
        // 性別が異なる（異性愛を想定）
        if (currentUserProfile.gender == user.gender) return false;
        
        // 年齢差が15歳以内（条件を緩和）
        if (currentUserProfile.age != null && user.age != null) {
          final ageDiff = (currentUserProfile.age! - user.age!).abs();
          if (ageDiff > 15) return false;
        }
        
        // 既にいいねしたユーザーを除外
        if (_likedUsers.any((liked) => liked.uid == user.uid)) return false;
        
        return true;
      }).toList();

      setState(() {
        _potentialMatches = filteredUsers;
        _isLoading = false;
      });

      // デバッグ情報を追加
      print('=== マッチング結果 ===');
      print('全ユーザー数: ${otherUsers.length}人');
      print('フィルタリング後: ${filteredUsers.length}人');
      print('現在のユーザー: ${currentUserProfile.nickname} (${currentUserProfile.age}歳, ${currentUserProfile.gender})');
      print('フィルタリング条件:');
      print('  - 自分以外: 除外');
      print('  - 性別が異なる: ${currentUserProfile.gender == 'male' ? '女性のみ' : '男性のみ'}');
      print('  - 年齢差15歳以内: ${currentUserProfile.age != null ? '${currentUserProfile.age! - 15}歳〜${currentUserProfile.age! + 15}歳' : '年齢不明'}');
      print('潜在的なマッチ: ${_potentialMatches.length}人');
      if (filteredUsers.isNotEmpty) {
        for (final user in filteredUsers) {
          print('  - ${user.nickname} (${user.age}歳, ${user.gender})');
        }
      }
      print('=== マッチング結果 終了 ===');
    } catch (e) {
      print('潜在的なマッチの読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSwipeRight(UserProfile user) {
    print('右スワイプ（いいね）: ${user.nickname}');
    
    setState(() {
      _likedUsers.add(user);
      // インデックスベースの削除は削除（CardSwiperが自動管理）
    });

    // いいねをFirestoreに保存
    _saveLike(user);
    
    // マッチングをチェック
    _checkForMatch(user);
  }

  void _onSwipeLeft(UserProfile user) {
    print('左スワイプ（スキップ）: ${user.nickname}');
    
    // インデックスベースの削除は削除（CardSwiperが自動管理）
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final user = _potentialMatches[previousIndex];

    switch (direction) {
      case CardSwiperDirection.left:
        _onSwipeLeft(user);
        break;
      case CardSwiperDirection.right:
        _onSwipeRight(user);
        break;
      case CardSwiperDirection.top:
        // スーパーいいね（TODO: 実装予定）
        _showMessage('${user.nickname ?? 'ユーザー'}にスーパーいいね！しました');
        break;
      case CardSwiperDirection.bottom:
        break;
      case CardSwiperDirection.none:
        break;
    }

    return true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Future<void> _saveLike(UserProfile likedUser) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance
          .collection('likes')
          .doc('${currentUser.uid}_${likedUser.uid}')
          .set({
        'likerId': currentUser.uid,
        'likedUserId': likedUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('いいねを保存: ${likedUser.nickname}');
    } catch (e) {
      print('いいねの保存エラー: $e');
    }
  }

  Future<void> _checkForMatch(UserProfile likedUser) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // 相手が自分をいいねしているかチェック
      final mutualLikeDoc = await FirebaseFirestore.instance
          .collection('likes')
          .doc('${likedUser.uid}_${currentUser.uid}')
          .get();

      if (mutualLikeDoc.exists) {
        // マッチング成立！
        print('マッチング成立！: ${likedUser.nickname}');
        
        setState(() {
          _matchedUsers.add(likedUser);
        });

        // マッチング通知を表示
        _showMatchNotification(likedUser);
      }
    } catch (e) {
      print('マッチングチェックエラー: $e');
    }
  }

  void _showMatchNotification(UserProfile matchedUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 マッチング成立！'),
        content: Text('${matchedUser.nickname ?? 'ユーザー'}さんとマッチしました！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マッチング'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // マッチしたユーザー一覧を表示
              _showMatchedUsers();
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _potentialMatches.isEmpty
                ? _buildNoMoreUsers()
                : _buildCardSwiper(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildNoMoreUsers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sentiment_dissatisfied,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 32),
          const Text(
            '現在表示できるユーザーがいません',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'しばらく待ってから再度お試しください',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loadPotentialMatches,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.pink,
            ),
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSwiper() {
    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: _controller,
            cardsCount: _potentialMatches.length,
            onSwipe: _onSwipe,
            cardBuilder: (context, index, horizontalThreshold, verticalThreshold) {
              return _buildUserCard(_potentialMatches[index]);
            },
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 背景画像（プレースホルダー）
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/300/400?random=${user.uid.hashCode}'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // グラデーションオーバーレイ
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
            // ユーザー情報
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.nickname ?? 'ユーザー'}, ${user.age ?? '??'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Text(
                      user.bio!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    )
                  else if (user.location != null)
                    Text(
                      user.location!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'pass',
            onPressed: () => _controller.swipe(CardSwiperDirection.left),
            backgroundColor: Colors.grey,
            child: const Icon(Icons.close, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: 'super_like',
            onPressed: () => _controller.swipe(CardSwiperDirection.top),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.star, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: 'like',
            onPressed: () => _controller.swipe(CardSwiperDirection.right),
            backgroundColor: Colors.pink,
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      currentIndex: 0, // マッチング画面が選択されている
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'マッチング',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'マッチ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'チャット',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'プロフィール',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // マッチング画面（現在の画面）
            break;
          case 1:
            // マッチしたユーザー一覧
            _showMatchedUsers();
            break;
          case 2:
            // チャット画面（TODO: 実装予定）
            _showComingSoon('チャット機能');
            break;
          case 3:
            // プロフィール画面（TODO: 実装予定）
            _showComingSoon('プロフィール編集');
            break;
        }
      },
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureは近日公開予定です！'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMatchedUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('マッチしたユーザー'),
        content: SizedBox(
          width: double.maxFinite,
          child: _matchedUsers.isEmpty
              ? const Text('まだマッチしたユーザーがいません')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _matchedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _matchedUsers[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                                             title: Text(user.nickname ?? 'ユーザー'),
                      subtitle: Text('${user.age}歳'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // TODO: チャット画面に遷移
                          Navigator.of(context).pop();
                        },
                        child: const Text('チャット'),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
