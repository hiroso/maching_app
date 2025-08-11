import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other }
enum ProfileCompletionLevel { basic, intermediate, complete }

class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? nickname;
  final Gender? gender;
  final int? age;
  final String? location; // 都道府県レベル
  final String? bio;
  final List<String> photos;
  final String? occupation;
  final List<String> interests;
  final String provider; // google, apple, anonymous
  final bool isGuest;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileCompletionLevel completionLevel;

  UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.nickname,
    this.gender,
    this.age,
    this.location,
    this.bio,
    this.photos = const [],
    this.occupation,
    this.interests = const [],
    required this.provider,
    this.isGuest = false,
    required this.createdAt,
    required this.updatedAt,
    required this.completionLevel,
  });

  // プロフィール完成度を計算
  static ProfileCompletionLevel calculateCompletionLevel({
    required bool hasGender,
    required bool hasAge,
    required bool hasNickname,
    required bool hasLocation,
    required bool hasBio,
    required bool hasPhotos,
  }) {
    int score = 0;
    if (hasGender) score += 1;
    if (hasAge) score += 1;
    if (hasNickname) score += 1;
    if (hasLocation) score += 1;
    if (hasBio) score += 1;
    if (hasPhotos) score += 1;

    if (score <= 2) return ProfileCompletionLevel.basic;
    if (score <= 4) return ProfileCompletionLevel.intermediate;
    return ProfileCompletionLevel.complete;
  }

  // 完成度スコアを取得（0-100）
  int get completionScore {
    int score = 0;
    if (gender != null) score += 17; // 性別
    if (age != null) score += 17; // 年齢
    if (nickname != null && nickname!.isNotEmpty) score += 17; // ニックネーム
    if (location != null && location!.isNotEmpty) score += 17; // 居住地
    if (bio != null && bio!.isNotEmpty) score += 16; // 自己紹介
    if (photos.isNotEmpty) score += 16; // 写真
    return score;
  }

  // マッチング可能かチェック
  bool get canMatch {
    return gender != null && age != null && nickname != null && nickname!.isNotEmpty;
  }

  // Firestoreからデータを作成
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserProfile(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      nickname: data['nickname'],
      gender: data['gender'] != null ? _parseGender(data['gender']) : null,
      age: data['age'],
      location: data['location'],
      bio: data['bio'],
      photos: List<String>.from(data['photos'] ?? []),
      occupation: data['occupation'],
      interests: List<String>.from(data['interests'] ?? []),
      provider: data['provider'] ?? 'unknown',
      isGuest: data['isGuest'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      completionLevel: _parseCompletionLevel(data['completionLevel']),
    );
  }

  // Firestore用のMapに変換
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'nickname': nickname,
      'gender': gender?.name,
      'age': age,
      'location': location,
      'bio': bio,
      'photos': photos,
      'occupation': occupation,
      'interests': interests,
      'provider': provider,
      'isGuest': isGuest,
      'completionLevel': completionLevel.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // コピーして更新
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? nickname,
    Gender? gender,
    int? age,
    String? location,
    String? bio,
    List<String>? photos,
    String? occupation,
    List<String>? interests,
    String? provider,
    bool? isGuest,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProfileCompletionLevel? completionLevel,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      occupation: occupation ?? this.occupation,
      interests: interests ?? this.interests,
      provider: provider ?? this.provider,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completionLevel: completionLevel ?? this.completionLevel,
    );
  }

  // ヘルパーメソッド
  static Gender _parseGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.other;
    }
  }

  static ProfileCompletionLevel _parseCompletionLevel(String? level) {
    switch (level) {
      case 'intermediate':
        return ProfileCompletionLevel.intermediate;
      case 'complete':
        return ProfileCompletionLevel.complete;
      default:
        return ProfileCompletionLevel.basic;
    }
  }
}
