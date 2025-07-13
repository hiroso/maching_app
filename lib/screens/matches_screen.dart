import 'package:flutter/material.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final List<Match> matches = [
    Match(
      name: 'さくら',
      age: 25,
      imageUrl: 'https://picsum.photos/300/400?random=20',
      matchedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Match(
      name: 'みき',
      age: 23,
      imageUrl: 'https://picsum.photos/300/400?random=21',
      matchedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Match(
      name: 'ゆい',
      age: 27,
      imageUrl: 'https://picsum.photos/300/400?random=22',
      matchedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Match(
      name: 'あやか',
      age: 24,
      imageUrl: 'https://picsum.photos/300/400?random=23',
      matchedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マッチ'),
        centerTitle: true,
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: matches.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'まだマッチがありません',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'いいね！を送ってマッチを作りましょう',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return _buildMatchCard(matches[index]);
              },
            ),
    );
  }

  Widget _buildMatchCard(Match match) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(match.imageUrl),
        ),
        title: Text(
          '${match.name}, ${match.age}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _getTimeAgo(match.matchedAt),
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.pink),
              onPressed: () => _startChat(match),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreOptions(match),
            ),
          ],
        ),
        onTap: () => _viewProfile(match),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  void _startChat(Match match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${match.name}とのチャットを開始します'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewProfile(Match match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${match.name}のプロフィールを表示します'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions(Match match) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('報告'),
              onTap: () {
                Navigator.pop(context);
                _reportUser(match);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('ブロック'),
              onTap: () {
                Navigator.pop(context);
                _blockUser(match);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _reportUser(Match match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${match.name}を報告しました'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _blockUser(Match match) {
    setState(() {
      matches.remove(match);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${match.name}をブロックしました'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class Match {
  final String name;
  final int age;
  final String imageUrl;
  final DateTime matchedAt;

  Match({
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.matchedAt,
  });
}
