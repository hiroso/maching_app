import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // アプリロゴ・タイトル
                const Icon(Icons.favorite, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Matching App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '素敵な出会いを見つけましょう',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 60),

                // Google Sign-In ボタン
                _buildSignInButton(
                  'Googleでサインイン',
                  'assets/google_logo.png',
                  Colors.white,
                  Colors.black87,
                  _signInWithGoogle,
                ),
                const SizedBox(height: 24),

                // Apple Sign-In ボタン
                _buildSignInButton(
                  'Appleでサインイン',
                  'assets/apple_logo.png',
                  Colors.black,
                  Colors.white,
                  _signInWithApple,
                ),
                const SizedBox(height: 24),

                // Apple Sign-In ボタン (一時的に無効化)
                // _buildSignInButton(
                //   'Appleでサインイン',
                //   'assets/apple_logo.png',
                //   Colors.black,
                //   Colors.white,
                //   _signInWithApple,
                // ),
                // const SizedBox(height: 24),

                // ゲストログインボタン
                TextButton(
                  onPressed: _isLoading ? null : _signInAnonymously,
                  child: const Text(
                    'ゲストとして続ける',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),


                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(
    String text,
    String iconPath,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              text.contains('Google') ? Icons.g_mobiledata : Icons.apple,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Googleサインインがキャンセルされました');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null && auth.currentUser!.isAnonymous) {
        await auth.currentUser!.linkWithCredential(credential);
      } else {
        await auth.signInWithCredential(credential);
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'provider': 'google',
        }, SetOptions(merge: true));
      }

      print('Google認証成功: ${user?.email ?? 'email不明'}');
      _navigateToMain();
    } catch (e) {
      print('Google認証エラー: $e');
      if (mounted) {
        _showErrorDialog('Googleサインインに失敗しました: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final available = await SignInWithApple.isAvailable();
      if (!available) {
        if (mounted) {
          _showErrorDialog(
            'このデバイスではAppleサインインが利用できません。\n(iCloudに未サインイン、またはアプリに"Sign in with Apple"権限未付与の可能性)',
          );
        }
        return;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null && auth.currentUser!.isAnonymous) {
        await auth.currentUser!.linkWithCredential(oauthCredential);
      } else {
        await auth.signInWithCredential(oauthCredential);
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'provider': 'apple',
        }, SetOptions(merge: true));
      }

      print('Apple認証成功: ${user?.email ?? 'email不明'}');
      _navigateToMain();
    } catch (e) {
      print('Apple認証エラー: $e');
      if (mounted) {
        _showErrorDialog('Appleサインインに失敗しました: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> _signInWithApple() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );

  //     final oauthCredential = OAuthProvider('apple.com').credential(
  //       idToken: credential.identityToken,
  //       accessToken: credential.authorizationCode,
  //     );

  //     await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  //     _navigateToMain();
  //   } catch (e) {
  //     _showErrorDialog('Appleサインインに失敗しました: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInAnonymously();
      print('ゲストログイン成功');
      _navigateToMain();
    } catch (e) {
      print('ゲストログインエラー: $e');
      if (mounted) {
        _showErrorDialog('ゲストログインに失敗しました: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToMain() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _showErrorDialog(String message) {
    // Navigatorコンテキストの問題を回避
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
