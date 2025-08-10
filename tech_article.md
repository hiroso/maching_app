# 35年目の挑戦：熟年エンジニアがCursor AIでFlutterマッチングアプリを作ってみた

## はじめに：人工無能からAI駆動開発へ

こんにちは！IT業界35年の熟年エンジニアです。

初仕事は原子力発電所の設備管理システムで、アセンブラやFORTRANを使ってプログラム開発していました。新人の頃は「人工無能」というコマンドシェルで言葉を覚えさせて、上司の目を盗んで遊んでいた記憶があります。

そんな私が、2024年の最新技術「Cursor AI」を使ってFlutterマッチングアプリを開発してみました。果たして35年の経験は通用するのか？それともAIに完敗するのか？

## 🎯 挑戦：Flutterマッチングアプリ開発

### 目標
- Tinderライクなスワイプ機能
- プロフィール管理
- マッチング機能
- チャット機能
- 設定画面

### 技術スタック
```yaml
Flutter + Dart
State Management: Provider + Riverpod
Navigation: GoRouter
UI Components: flutter_card_swiper
```

## 🤖 Cursor AIとの初対面

### メリット1：コード生成の神速さ
**従来の開発**
```
私：「このボタンのスタイル、どう書くんだっけ？」
→ ドキュメント調べる（30分）
→ Stack Overflow検索（20分）
→ 試行錯誤（1時間）
→ 完成（合計1時間50分）
```

**Cursor AI使用時**
```
私：「FloatingActionButtonでいいねボタンを作って」
Cursor：「はい、ピンク色のハートアイコン付きボタンですね」
→ 完成（30秒）
```

**衝撃の事実：** 35年の経験より、AIの方が速い（涙）

### メリット2：エラー解決の即座性
**従来の開発**
```
エラー：「CardSwiperDirection.none case missing」
私：「なんだこれ？ドキュメント見てもわからん...」
→ 2時間悩む
→ 結局GitHubのissue見つける
```

**Cursor AI使用時**
```
私：「このエラー何？」
Cursor：「switch文にCardSwiperDirection.noneのケースを追加してください」
→ 即座に解決
```

**学んだこと：** エラー解決は経験より情報量が重要

## 😅 デメリット：AIとの格闘

### デメリット1：依存関係の地獄
```yaml
# 最初のpubspec.yaml（AI提案）
dependencies:
  firebase_auth: ^4.0.0
  firebase_storage: ^11.0.0
  # ... 20個の依存関係

# 結果：コンパイルエラー地獄
# 解決策：AIに「シンプルにしろ」と指示
```

**教訓：** AIは「全部入り」を提案するが、実際は「必要最小限」が正解

### デメリット2：ファイル管理の混乱
```
私：「コードどこ行った？」
AI：「maching_flutter/lib/にあります」
私：「いや、matching_app/lib/じゃないの？」
AI：「あ、すみません。コピーしましょう」
```

**35年の経験が活きた瞬間：** ファイル構造の重要性を理解していたため、混乱を最小限に抑えられた

### デメリット3：API変更への対応
```dart
// AI提案（古いAPI）
controller.swipe(CardSwiperDirection.right)

// 実際のAPI（変更済み）
controller.swipe()
```

**学んだこと：** AIは最新情報を持っていない場合がある

## 🚀 実際の開発フロー

### 1. プロジェクト作成
```bash
# 従来の方法
flutter create my_app
cd my_app
# 手動でファイル構造確認（30分）

# Cursor AI使用
flutter create matching_app
# AIが自動で必要なファイル構造を提案
```

### 2. UI実装
```dart
// AIが提案したCardSwiper実装
CardSwiper(
  cardsCount: users.length,
  cardBuilder: (context, index) => UserCard(user: users[index]),
  onSwipe: (previousIndex, currentIndex, direction) {
    // AIが自動でスワイプ処理を生成
  },
)
```

**驚き：** 35年で培ったUI設計の知識が、AIの提案と一致していた

### 3. 状態管理
```dart
// AI提案のProvider実装
class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  
  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }
}
```

**発見：** AIは「ベストプラクティス」を理解している

## 📱 完成したアプリの機能

### ホーム画面
- ✅ カードスワイプ機能
- ✅ いいね/パス/スーパーいいね
- ✅ リアルタイムフィードバック

### プロフィール画面
- ✅ 写真アップロード
- ✅ 基本情報編集
- ✅ 興味・関心設定

### マッチ画面
- ✅ マッチした相手一覧
- ✅ プロフィール表示
- ✅ チャット開始

### 設定画面
- ✅ 通知設定
- ✅ 位置情報設定
- ✅ アカウント管理

## 🎭 AI駆動開発の真実

### メリット
1. **開発速度の劇的向上** - 従来の1/3の時間
2. **エラー解決の即座性** - 経験不要
3. **最新技術への対応** - 学習コスト削減
4. **コード品質の向上** - ベストプラクティス自動適用

### デメリット
1. **依存関係の複雑化** - 過剰な提案
2. **ファイル管理の混乱** - AIの勘違い
3. **API変更への脆弱性** - 古い情報
4. **思考停止のリスク** - 理解せずコピペ

## 🤔 35年目の気づき

### AIは「優秀な新人エンジニア」
- 知識は豊富だが、経験が浅い
- 提案は的確だが、文脈を理解していない
- 速いが、時々間違える

### 熟年エンジニアの役割
- **プロジェクト全体の設計**
- **AI提案の取捨選択**
- **品質管理とリスク管理**
- **チーム全体の調整**

## 🎯 結論：AI駆動開発の未来

### 成功の秘訣
1. **AIを「優秀な新人」として扱う**
2. **経験でAI提案を評価・修正**
3. **全体設計は人間が担当**
4. **継続的な学習と適応**

### 35年目の挑戦結果
- ✅ マッチングアプリ完成
- ✅ 最新技術習得
- ✅ 開発効率向上
- ✅ 新しい開発手法の確立

## 🚀 次の挑戦

次は**Firebase統合**に挑戦します！
- Authentication（Google、Apple認証）
- Firestore Database
- Storage（画像保存）

35年の経験 + AIの力 = 無限の可能性

---

**熟年エンジニアの皆さん、AIを恐れず、味方につけましょう！**

*「人工無能」から「AI駆動開発」へ - 35年のIT人生の新しい章が始まりました。*

---

## 📚 参考リンク
- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Cursor AI](https://cursor.sh/)
- [GitHubリポジトリ](https://github.com/hiroso/maching_app)

---

*この記事は、35年のIT経験を持つ熟年エンジニアが、Cursor AIを使ってFlutterマッチングアプリを開発した実体験に基づいて書かれています。* 