import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  double _maxDistance = 50.0;
  int _minAge = 18;
  int _maxAge = 35;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('通知設定', [
            _buildSwitchTile(
              title: 'プッシュ通知',
              subtitle: '新しいマッチやメッセージの通知を受け取る',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ]),
          _buildSection('位置情報設定', [
            _buildSwitchTile(
              title: '位置情報の使用',
              subtitle: 'より正確なマッチングのために位置情報を使用',
              value: _locationEnabled,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
            _buildSliderTile(
              title: '最大距離',
              subtitle: '${_maxDistance.toInt()}km以内のユーザーを表示',
              value: _maxDistance,
              min: 1.0,
              max: 100.0,
              onChanged: (value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
          ]),
          _buildSection('年齢設定', [
            _buildRangeSliderTile(
              title: '年齢範囲',
              subtitle: '${_minAge}歳 - ${_maxAge}歳',
              minValue: _minAge.toDouble(),
              maxValue: _maxAge.toDouble(),
              onChanged: (values) {
                setState(() {
                  _minAge = values.start.toInt();
                  _maxAge = values.end.toInt();
                });
              },
            ),
          ]),
          _buildSection('アカウント', [
            _buildListTile(
              title: 'プロフィール編集',
              subtitle: 'プロフィール情報を編集',
              leading: Icons.edit,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('プロフィール編集画面を開きます')),
                );
              },
            ),
            _buildListTile(
              title: 'アカウント削除',
              subtitle: 'アカウントを完全に削除',
              leading: Icons.delete,
              textColor: Colors.red,
              onTap: () => _showDeleteAccountDialog(),
            ),
          ]),
          _buildSection('サポート', [
            _buildListTile(
              title: 'ヘルプ',
              subtitle: 'よくある質問とサポート',
              leading: Icons.help,
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('ヘルプページを開きます')));
              },
            ),
            _buildListTile(
              title: 'お問い合わせ',
              subtitle: 'フィードバックやお問い合わせ',
              leading: Icons.email,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('お問い合わせフォームを開きます')),
                );
              },
            ),
            _buildListTile(
              title: 'プライバシーポリシー',
              subtitle: 'プライバシーポリシーと利用規約',
              leading: Icons.privacy_tip,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('プライバシーポリシーを開きます')),
                );
              },
            ),
          ]),
          _buildSection('その他', [
            _buildListTile(
              title: 'ログアウト',
              subtitle: 'アカウントからログアウト',
              leading: Icons.logout,
              onTap: () => _showLogoutDialog(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.pink,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
            activeColor: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSliderTile({
    required String title,
    required String subtitle,
    required double minValue,
    required double maxValue,
    required Function(RangeValues) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          RangeSlider(
            values: RangeValues(minValue, maxValue),
            min: 18,
            max: 100,
            divisions: 82,
            onChanged: onChanged,
            activeColor: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData leading,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(leading, color: textColor ?? Colors.grey),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text('本当にアカウントを削除しますか？この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('アカウントを削除しました')));
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('ログアウトしました')));
            },
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }
}
