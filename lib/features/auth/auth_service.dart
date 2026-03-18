import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase Authentication Service
/// 
/// Firebase를 이용한 회원가입, 로그인, 이메일 인증, 생체 인증 및 세션 관리를 담당합니다.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  static const String _sessionKey = 'auth_session_time';

  // 현재 사용자 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  /// 이메일/비밀번호로 회원가입
  Future<UserCredential> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<UserCredential> login(String email, String password, {bool autoLogin = false}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (autoLogin) {
        await _saveSessionTime();
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// 생체 인증 로그인 (Local Auth)
  Future<bool> authenticateBiometrically() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      
      if (!canAuthenticate) return false;

      return await _localAuth.authenticate(
        localizedReason: '생체 인증을 통해 안전하게 로그인합니다.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    return _auth.signOut();
  }

  /// 세션 시간 저장 (현재 시간)
  Future<void> _saveSessionTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// 세션 만료 여부 확인 (30일)
  Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final int? loginTime = prefs.getInt(_sessionKey);
    if (loginTime == null) return false; // 자동 로그인이 아니면 무시

    final loginDateTime = DateTime.fromMillisecondsSinceEpoch(loginTime);
    final now = DateTime.now();
    final difference = now.difference(loginDateTime).inDays;
    
    return difference >= 30;
  }

  /// 이메일 인증 메일 재발송
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// 사용자 데이터 새로고침 (인증 상태 확인용)
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// 비밀번호 재설정 메일 발송
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// 비밀번호 재설정 확인 및 적용
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Firebase 에러 메시지 한글화 처리
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return '유효하지 않은 이메일 형식입니다.';
      case 'user-disabled': return '해당 계정은 비활성화되었습니다.';
      case 'user-not-found': return '등록되지 않은 이메일입니다.';
      case 'wrong-password': return '비밀번호가 일치하지 않습니다.';
      case 'email-already-in-use': return '이미 사용 중인 이메일입니다.';
      default: return e.message ?? '인증 오류가 발생했습니다.';
    }
  }
}

// Riverpod Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 사용자 인증 상태를 추적하는 스트림 프로바이더
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
