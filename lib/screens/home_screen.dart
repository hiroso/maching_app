import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController controller = CardSwiperController();

  List<UserCard> users = [
    UserCard(
      name: 'さくら',
      age: 25,
      bio: 'こんにちは！映画鑑賞と料理が好きです。',
      imageUrl: 'https://picsum.photos/300/400?random=1',
    ),
    UserCard(
      name: 'みき',
      age: 23,
      bio: 'アウトドアが好きです！一緒に山登りしませんか？',
      imageUrl: 'https://picsum.photos/300/400?random=2',
    ),
    UserCard(
      name: 'ゆい',
      age: 27,
      bio: 'カフェ巡りが趣味です。おいしいコーヒーを飲みながらお話しましょう。',
      imageUrl: 'https://picsum.photos/300/400?random=3',
    ),
    UserCard(
      name: 'あやか',
      age: 24,
      bio: 'ヨガとフィットネスが好きです。健康的な生活を心がけています。',
      imageUrl: 'https://picsum.photos/300/400?random=4',
    ),
    UserCard(
      name: 'なな',
      age: 26,
      bio: '読書と音楽が好きです。新しい本や音楽を教えてください。',
      imageUrl: 'https://picsum.photos/300/400?random=5',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マッチング'),
        centerTitle: true,
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: users.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 100, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'もうマッチできる人がいません',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: CardSwiper(
                      controller: controller,
                      cardsCount: users.length,
                      onSwipe: _onSwipe,
                      cardBuilder:
                          (
                            context,
                            index,
                            horizontalThreshold,
                            verticalThreshold,
                          ) {
                            return _buildCard(users[index]);
                          },
                    ),
                  ),
                  _buildActionButtons(),
                ],
              ),
      ),
    );
  }

  Widget _buildCard(UserCard user) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 背景画像
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(user.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // グラデーション
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                    '${user.name}, ${user.age}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.bio,
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
            onPressed: () => controller.swipe(),
            backgroundColor: Colors.grey,
            child: const Icon(Icons.close, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: 'super_like',
            onPressed: () => controller.swipe(),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.star, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: 'like',
            onPressed: () => controller.swipe(),
            backgroundColor: Colors.pink,
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final user = users[previousIndex];

    switch (direction) {
      case CardSwiperDirection.left:
        _showMessage('${user.name}をパスしました');
        break;
      case CardSwiperDirection.right:
        _showMessage('${user.name}にいいね！しました');
        break;
      case CardSwiperDirection.top:
        _showMessage('${user.name}にスーパーいいね！しました');
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
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}

class UserCard {
  final String name;
  final int age;
  final String bio;
  final String imageUrl;

  UserCard({
    required this.name,
    required this.age,
    required this.bio,
    required this.imageUrl,
  });
}
