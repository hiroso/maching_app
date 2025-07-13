import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatRoom> chatRooms = [
    ChatRoom(
      name: 'さくら',
      imageUrl: 'https://picsum.photos/300/400?random=30',
      lastMessage: 'こんにちは！よろしくお願いします',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 2,
    ),
    ChatRoom(
      name: 'みき',
      imageUrl: 'https://picsum.photos/300/400?random=31',
      lastMessage: 'おつかれさまでした！',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
    ),
    ChatRoom(
      name: 'ゆい',
      imageUrl: 'https://picsum.photos/300/400?random=32',
      lastMessage: '今度お茶しませんか？',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
        centerTitle: true,
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: chatRooms.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'まだチャットがありません',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'マッチした人とチャットを始めましょう',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                return _buildChatRoomCard(chatRooms[index]);
              },
            ),
    );
  }

  Widget _buildChatRoomCard(ChatRoom chatRoom) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(chatRoom.imageUrl),
            ),
            if (chatRoom.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    chatRoom.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chatRoom.name,
          style: TextStyle(
            fontWeight: chatRoom.unreadCount > 0
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          chatRoom.lastMessage,
          style: TextStyle(
            color: chatRoom.unreadCount > 0 ? Colors.black : Colors.grey,
            fontWeight: chatRoom.unreadCount > 0
                ? FontWeight.w500
                : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getTimeString(chatRoom.lastMessageTime),
              style: TextStyle(
                color: chatRoom.unreadCount > 0 ? Colors.pink : Colors.grey,
                fontSize: 12,
              ),
            ),
            if (chatRoom.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        onTap: () => _openChat(chatRoom),
      ),
    );
  }

  String _getTimeString(DateTime dateTime) {
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

  void _openChat(ChatRoom chatRoom) {
    // チャットルームの未読数をリセット
    setState(() {
      chatRoom.unreadCount = 0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chatRoom: chatRoom),
      ),
    );
  }
}

class ChatRoom {
  final String name;
  final String imageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  int unreadCount;

  ChatRoom({
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailScreen({super.key, required this.chatRoom});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _messages.addAll([
        Message(
          text: 'こんにちは！',
          isFromMe: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        Message(
          text: 'こんにちは！よろしくお願いします',
          isFromMe: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        Message(
          text: 'プロフィールを見させていただきました',
          isFromMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoom.name),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isFromMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromMe)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.chatRoom.imageUrl),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isFromMe ? Colors.pink : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isFromMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (message.isFromMe) const SizedBox(width: 8),
          if (message.isFromMe)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.pink,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'メッセージを入力...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.pink),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          text: _messageController.text,
          isFromMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
  }
}

class Message {
  final String text;
  final bool isFromMe;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isFromMe,
    required this.timestamp,
  });
}
