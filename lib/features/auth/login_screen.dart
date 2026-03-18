import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import '../desktop/desktop_screen.dart';
import 'signup_screen.dart';
import 'auth_service.dart';
import 'email_verification_screen.dart';

/// Mobile/3-Login Screen
/// 
/// 기존 회원이 시스템에 접속하기 위한 로그인 화면입니다.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // 텍스트 입력 제어를 위한 컨트롤러
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _resetEmail = TextEditingController();
  
  // 상태 제어
  bool _autoLogin = true;
  bool _isLoading = false;
  bool _isResetLoading = false;
  bool _showResetWindow = false;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    _resetEmail.dispose();
    super.dispose();
  }

  /// 로그인 처리 로직 (Firebase 연동)
  Future<void> _handleLogin() async {
    if (_email.text.isEmpty || _pw.text.isEmpty) {
      _showMsg("이메일과 비밀번호를 입력해주세요.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final credential = await authService.login(
        _email.text.trim(), 
        _pw.text.trim(),
        autoLogin: _autoLogin,
      );
      
      final user = credential.user;
      if (user != null) {
        if (user.emailVerified) {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => const DesktopScreen()), 
              (_) => false
            );
          }
        } else {
          if (mounted) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(
                builder: (_) => EmailVerificationScreen(email: user.email ?? _email.text.trim())
              )
            );
          }
        }
      }
    } catch (e) {
      if (mounted) _showMsg(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 생체 인증 로그인 처리
  Future<void> _handleBiometricLogin() async {
    final authService = ref.read(authServiceProvider);
    
    // 1. 생체 인증 실행
    final bool authenticated = await authService.authenticateBiometrically();
    
    if (authenticated) {
      // 2. 이미 로그인되어 있는지 확인 (Firebase 세션)
      final user = authService.currentUser;
      if (user != null) {
        if (user.emailVerified) {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => const DesktopScreen()), 
              (_) => false
            );
          }
        } else {
          _showMsg("이메일 인증이 필요합니다.");
        }
      } else {
        _showMsg("이메일로 한번 로그인한 후 생체 인증을 사용할 수 있습니다.");
      }
    } else {
      _showMsg("생체 인증에 실패했거나 지원되지 않는 기기입니다.");
    }
  }

  /// 비밀번호 초기화 메일 발송 로직
  Future<void> _handleResetEmail() async {
    if (_resetEmail.text.isEmpty) {
      _showMsg("이메일을 입력해주세요.");
      return;
    }

    setState(() => _isResetLoading = true);

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(_resetEmail.text.trim());
      if (mounted) {
        _showMsg("비밀번호 재설정 메일이 발송되었습니다.");
        setState(() => _showResetWindow = false);
      }
    } catch (e) {
      if (mounted) _showMsg(e.toString());
    } finally {
      if (mounted) setState(() => _isResetLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(
        child: Stack(
          children: [
            Column(children: [
            KdsHeader(title: "로그인"),
            
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                KdsWindow(
                  title: "Kohere System Login", 
                  child: Text(
                    "반가워요! 오늘은 어떤 이야기가 기다리고 있나요?\n당신만의 특별한 기록들을\n이곳에서 다시 이어가 보세요. :)",
                    style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown, height: 1.5),
                  )
                ),
                  SizedBox(height: 12),
                  
                  KdsInput(placeholder: "이메일", controller: _email),
                  SizedBox(height: 12),
                  KdsInput(placeholder: "비밀번호", controller: _pw, obscure: true),
                  SizedBox(height: 12),
                  
                  KdsCheckbox(
                    label: "자동 로그인 (30일 유지)", 
                    value: _autoLogin, 
                    onChanged: (v) => setState(() => _autoLogin = v)
                  ),
                  SizedBox(height: 12),
                  
                  _isLoading 
                    ? Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: KDS.mochaBrown),
                      ))
                    : Column(children: [
                        KdsButton(
                          label: "로그인", 
                          style: KdsButtonStyle.active, 
                          onTap: _handleLogin,
                        ),
                        SizedBox(height: 12),
                        KdsButton(
                          label: "생체 인증으로 로그인 (Touch/Face ID)", 
                          style: KdsButtonStyle.brown,
                          onTap: _handleBiometricLogin,
                        ),
                      ]),
                  SizedBox(height: 12),
                  
                  KdsButton(
                    label: "비밀번호 초기화", 
                    onTap: () => setState(() => _showResetWindow = true)
                  ),
                  SizedBox(height: 16),
                  
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("아직 계정이 없나요? ", style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                      child: Text("회원가입", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold, color: KDS.mochaBrown)),
                    ),
                  ]),
                ]),
              )),
            ]),

            // ── 비밀번호 초기화 윈도우 오버레이 ──
            if (_showResetWindow)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: KdsWindow(
                      title: "Password Recovery",
                      onClose: () => setState(() => _showResetWindow = false),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "가입하신 이메일을 입력하시면\n초기화 링크를 보내드립니다.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: KDS.fontSm, color: KDS.espressoBlack),
                          ),
                          SizedBox(height: 20),
                          KdsInput(placeholder: "이메일 주소", controller: _resetEmail),
                          SizedBox(height: 20),
                          _isResetLoading
                            ? Center(child: CircularProgressIndicator(color: KDS.mochaBrown))
                            : KdsButton(
                                label: "메일 발송",
                                style: KdsButtonStyle.active,
                                onTap: _handleResetEmail,
                              ),
                          SizedBox(height: 8),
                          KdsButton(
                            label: "닫기",
                            onTap: () => setState(() => _showResetWindow = false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
