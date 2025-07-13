import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'あなたの名前',
  );
  final TextEditingController _ageController = TextEditingController(
    text: '25',
  );
  final TextEditingController _bioController = TextEditingController(
    text: 'よろしくお願いします！',
  );

  final ImagePicker _picker = ImagePicker();
  final List<String> _photos = [
    'https://picsum.photos/300/400?random=10',
    'https://picsum.photos/300/400?random=11',
    'https://picsum.photos/300/400?random=12',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        centerTitle: true,
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotosSection(),
            const SizedBox(height: 20),
            _buildBasicInfoSection(),
            const SizedBox(height: 20),
            _buildBioSection(),
            const SizedBox(height: 20),
            _buildInterestsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '写真',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length + 1,
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                return _buildAddPhotoCard();
              }
              return _buildPhotoCard(_photos[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String photo, int index) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(photo), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              radius: 15,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 15),
                onPressed: () => _removePhoto(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoCard() {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: InkWell(
        onTap: _addPhoto,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('写真を追加', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '基本情報',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '名前',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _ageController,
          decoration: const InputDecoration(
            labelText: '年齢',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '自己紹介',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _bioController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '自己紹介文',
            border: OutlineInputBorder(),
            hintText: 'あなたについて教えてください...',
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '趣味・興味',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            _buildInterestChip('映画'),
            _buildInterestChip('料理'),
            _buildInterestChip('旅行'),
            _buildInterestChip('音楽'),
            _buildInterestChip('読書'),
            _buildInterestChip('スポーツ'),
            _buildInterestChip('アート'),
            _buildInterestChip('ファッション'),
          ],
        ),
      ],
    );
  }

  Widget _buildInterestChip(String interest) {
    return FilterChip(
      label: Text(interest),
      selected: true,
      selectedColor: Colors.pink.withOpacity(0.3),
      onSelected: (bool selected) {
        // TODO: 興味の選択状態を管理
      },
    );
  }

  void _addPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos.add(image.path);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('プロフィールを保存しました'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
