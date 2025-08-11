import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../main.dart';
import '../screens/main_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // 基本情報
  Gender? _selectedGender;
  int? _selectedBirthYear;
  int? _selectedBirthMonth;
  int? _selectedBirthDay;
  String _nickname = 'ユーザー名';
  String? _selectedLocation;
  
  // 追加情報（オプション）
  String _bio = '';
  String _occupation = '';
  List<String> _interests = [];
  
  bool _isLoading = false;
  bool _showBirthDatePickerInline = false;
  bool _showLocationPickerInline = false;

  // 都道府県リスト
  static const List<String> _prefectures = [
    '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
    '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
    '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
    '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
    '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
    '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
    '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'
  ];

  // 生年月日のリスト
  static List<int> get _birthYears {
    final currentYear = DateTime.now().year;
    return List.generate(63, (index) => currentYear - 18 - index); // 18歳以上
  }
  
  static const List<int> _birthMonths = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]; // 1-12月
  static const List<int> _birthDays = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]; // 1-31日

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink, Colors.purple],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              _buildHeader(),
              
              // プログレスバー
              _buildProgressBar(),
              
              // メインコンテンツ
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildBasicInfoPage(),
                    _buildAdditionalInfoPage(),
                    _buildCompletionPage(),
                  ],
                ),
              ),
              
              // ナビゲーションボタン
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        'プロフィール設定',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LinearProgressIndicator(
        value: (_currentPage + 1) / 3,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 性別選択
          _buildSectionTitle('性別 *'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGenderButton(Gender.male, '男性'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderButton(Gender.female, '女性'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderButton(Gender.other, 'その他'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // 生年月日選択
          _buildSectionTitle('生年月日 *'),
          const SizedBox(height: 16),
          
          // 生年月日が選択されている場合の表示
          if (_selectedBirthYear != null && _selectedBirthMonth != null && _selectedBirthDay != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '選択中: ${_selectedBirthYear}年${_selectedBirthMonth}月${_selectedBirthDay}日',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => _showBirthDatePicker(context),
                    child: const Text('変更', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            )
          else
            // 生年月日選択ボタン
            GestureDetector(
              onTap: () => _showBirthDatePicker(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '生年月日を選択してください',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          
          // インライン生年月日選択UI
          if (_showBirthDatePickerInline)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダー
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '生年月日を選択',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showBirthDatePickerInline = false;
                          });
                        },
                        icon: const Icon(Icons.close, color: Color(0xFF6A1B9A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 年選択
                  const Text('年: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _birthYears.map((year) {
                      final isSelected = _selectedBirthYear == year;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBirthYear = year;
                            _selectedBirthDay = 1; // 年が変更されたら日付をリセット
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$year年',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  // 月選択
                  const Text('月: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _birthMonths.map((month) {
                      final isSelected = _selectedBirthMonth == month;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBirthMonth = month;
                            _selectedBirthDay = 1; // 月が変更されたら日付をリセット
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$month月',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  // 日選択
                  const Text('日: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getValidDaysForYearMonth(
                      _selectedBirthYear ?? (DateTime.now().year - 18),
                      _selectedBirthMonth ?? DateTime.now().month,
                    ).map((day) {
                      final isSelected = _selectedBirthDay == day;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBirthDay = day;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$day日',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 確定ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showBirthDatePickerInline = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '確定',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          
          // ニックネーム
          _buildSectionTitle('ニックネーム *'),
          const SizedBox(height: 16),
          TextFormField(
            onChanged: (value) {
              setState(() {
                _nickname = value;
              });
            },
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'ニックネームを入力',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white24,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 32),
          
          // 居住地
          _buildSectionTitle('居住地（推奨）'),
          const SizedBox(height: 16),
          
          // 居住地が選択されている場合の表示
          if (_selectedLocation != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedLocation!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => _showLocationPicker(context),
                    child: const Text('変更', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            )
          else
            // 居住地選択ボタン
            GestureDetector(
              onTap: () => _showLocationPicker(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '都道府県を選択してください',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.location_on, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          
          // インライン居住地選択UI
          if (_showLocationPickerInline)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダー
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '都道府県を選択',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showLocationPickerInline = false;
                          });
                        },
                        icon: const Icon(Icons.close, color: Color(0xFF6A1B9A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 都道府県選択
                  SizedBox(
                    height: 300,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _prefectures.length,
                      itemBuilder: (context, index) {
                        final prefecture = _prefectures[index];
                        final isSelected = _selectedLocation == prefecture;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLocation = prefecture;
                              _showLocationPickerInline = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                prefecture,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 自己紹介
          _buildSectionTitle('自己紹介（オプション）'),
          const SizedBox(height: 16),
          TextFormField(
            onChanged: (value) {
              setState(() {
                _bio = value;
              });
            },
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: '自己紹介を入力してください',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white24,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 32),
          
          // 職業
          _buildSectionTitle('職業（オプション）'),
          const SizedBox(height: 16),
          TextFormField(
            onChanged: (value) {
              setState(() {
                _occupation = value;
              });
            },
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: '職業を入力してください',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white24,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionPage() {
    final completionScore = _calculateCompletionScore();
    final age = _calculateAge();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 完了メッセージ
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'プロフィール設定完了！',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'プロフィール完成度: $completionScore%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                if (age != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '年齢: ${age}歳',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // 設定内容の確認
          _buildSectionTitle('設定内容の確認'),
          const SizedBox(height: 16),
          _buildInfoCard('性別', _selectedGender?.name ?? '未設定'),
          _buildInfoCard('生年月日', _selectedBirthYear != null && _selectedBirthMonth != null && _selectedBirthDay != null
              ? '${_selectedBirthYear}年${_selectedBirthMonth}月${_selectedBirthDay}日'
              : '未設定'),
          _buildInfoCard('ニックネーム', _nickname.isNotEmpty ? _nickname : '未設定'),
          _buildInfoCard('居住地', _selectedLocation ?? '未設定'),
          if (_bio.isNotEmpty) _buildInfoCard('自己紹介', _bio),
          if (_occupation.isNotEmpty) _buildInfoCard('職業', _occupation),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGenderButton(Gender gender, String label) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
        print('性別が選択されました: $label');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white30,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.purple : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '戻る',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed() ? Colors.white : Colors.white24,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == 2 ? '完了' : '次へ',
                style: TextStyle(
                  color: _canProceed() ? Colors.purple : Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGender != null &&
               _selectedBirthYear != null &&
               _selectedBirthMonth != null &&
               _selectedBirthDay != null &&
               _nickname.isNotEmpty;
      case 1:
        return true; // 追加情報はオプション
      case 2:
        return true; // 完了ページ
      default:
        return false;
    }
  }

  void _handleNext() async {
    if (_currentPage == 2) {
      // プロフィール保存
      await _saveProfile();
    } else {
      // 次のページへ
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('ユーザーが認証されていません');
        return;
      }

             final userProfile = UserProfile(
         uid: user.uid,
         email: user.email,
         displayName: user.displayName,
         nickname: _nickname,
         gender: _selectedGender,
         age: _calculateAge(),
         location: _selectedLocation,
         bio: _bio.isNotEmpty ? _bio : null,
         occupation: _occupation.isNotEmpty ? _occupation : null,
         interests: _interests,
         provider: user.providerData.isNotEmpty ? user.providerData.first.providerId : 'unknown',
         isGuest: user.isAnonymous,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
         completionLevel: UserProfile.calculateCompletionLevel(
           hasGender: _selectedGender != null,
           hasAge: _calculateAge() != null,
           hasNickname: _nickname.isNotEmpty,
           hasLocation: _selectedLocation != null,
           hasBio: _bio.isNotEmpty,
           hasPhotos: false, // 写真は現在実装していない
         ),
       );

      final firestoreData = userProfile.toFirestore();
      print('=== プロフィール保存時の詳細 ===');
      print('保存するユーザーID: ${user.uid}');
      print('保存するデータ: $firestoreData');
      print('completionLevel: ${firestoreData['completionLevel']}');
      print('nickname: ${firestoreData['nickname']}');
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(firestoreData);

      print('プロフィールが保存されました');
      print('=== プロフィール保存時の詳細 終了 ===');
      
      // メイン画面に遷移
      if (mounted) {
        // NavigatorKeyを使って遷移
        MyApp.navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('プロフィール保存でエラーが発生しました: $e');
      print('スタックトレース: $stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  // 有効な日数を取得（うるう年と月の日数を考慮）
  List<int> _getValidDays() {
    if (_selectedBirthYear == null || _selectedBirthMonth == null) {
      return _birthDays;
    }
    
    final year = _selectedBirthYear!;
    final month = _selectedBirthMonth!;
    
    // 各月の日数
    final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
    // うるう年の判定
    bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    
    // 2月の場合はうるう年を考慮
    if (month == 2 && isLeapYear) {
      return List.generate(29, (index) => index + 1);
    }
    
    return List.generate(daysInMonth[month - 1], (index) => index + 1);
  }

  // 年と月に基づいて有効な日数を取得（ダイアログ用）
  List<int> _getValidDaysForYearMonth(int year, int month) {
    // 各月の日数
    final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
    // うるう年の判定
    bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    
    // 2月の場合はうるう年を考慮
    if (month == 2 && isLeapYear) {
      return List.generate(29, (index) => index + 1);
    }
    
    return List.generate(daysInMonth[month - 1], (index) => index + 1);
  }

  // 年齢を計算
  int? _calculateAge() {
    if (_selectedBirthYear == null || _selectedBirthMonth == null || _selectedBirthDay == null) {
      return null;
    }
    
    final now = DateTime.now();
    final birthDate = DateTime(_selectedBirthYear!, _selectedBirthMonth!, _selectedBirthDay!);
    
    int age = now.year - birthDate.year;
    
    // 今年の誕生日がまだ来ていない場合は1歳引く
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  // 最もシンプルな生年月日選択UI（完全にインライン）
  void _showBirthDatePicker(BuildContext context) {
    print('=== _showBirthDatePicker 開始 ===');
    print('context: $context');
    print('mounted: $mounted');
    
    if (!mounted) {
      print('mountedがfalseのため、メソッドを終了します');
      return;
    }
    
    // 現在の日付を取得
    final now = DateTime.now();
    print('現在の日付: $now');
    
    // 初期値の設定
    int tempYear = _selectedBirthYear ?? (now.year - 18);
    int tempMonth = _selectedBirthMonth ?? now.month;
    int tempDay = _selectedBirthDay ?? now.day;
    
    print('初期値設定:');
    print('  _selectedBirthYear: $_selectedBirthYear');
    print('  _selectedBirthMonth: $_selectedBirthMonth');
    print('  _selectedBirthDay: $_selectedBirthDay');
    print('  tempYear: $tempYear');
    print('  tempMonth: $tempMonth');
    print('  tempDay: $tempDay');
    
    // 完全にインラインで生年月日選択UIを表示
    print('インラインUIを表示します');
    
    setState(() {
      print('setState開始');
      _showBirthDatePickerInline = true;
      print('setState内で値を更新:');
      print('  _showBirthDatePickerInline: $_showBirthDatePickerInline');
    });
    print('setState完了');
    
    print('=== _showBirthDatePicker 終了 ===');
  }

  // 居住地選択ピッカー
  void _showLocationPicker(BuildContext context) {
    print('=== _showLocationPicker 開始 ===');
    print('context: $context');
    print('mounted: $mounted');
    
    if (!mounted) {
      print('mountedがfalseのため、メソッドを終了します');
      return;
    }
    
    print('インラインUIを表示します');
    
    setState(() {
      print('setState開始');
      _showLocationPickerInline = true;
      print('setState内で値を更新:');
      print('  _showLocationPickerInline: $_showLocationPickerInline');
    });
    print('setState完了');
    
    print('=== _showLocationPicker 終了 ===');
  }

  int _calculateCompletionScore() {
    int score = 0;
    if (_selectedGender != null) score += 17; // 性別
    if (_selectedBirthYear != null && _selectedBirthMonth != null && _selectedBirthDay != null) score += 17; // 生年月日
    if (_nickname.isNotEmpty) score += 17; // ニックネーム
    if (_selectedLocation != null) score += 17; // 居住地
    if (_bio.isNotEmpty) score += 16; // 自己紹介
    if (_occupation.isNotEmpty) score += 16; // 職業
    return score;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
