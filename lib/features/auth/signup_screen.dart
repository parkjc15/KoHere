import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import 'login_screen.dart';
import 'policy_screen.dart';
import 'auth_service.dart';
import 'email_verification_screen.dart';

/// Mobile/4-SignUp Screen
/// 
/// 새로운 사용자가 계정을 생성하는 회원가입 화면입니다.
/// 이메일, 비밀번호(중복 확인 포함), 그리고 필수 약관 동의 절차를 포함합니다.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});
  @override ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // 입력 필드 제어를 위한 컨트롤러
  final _email = TextEditingController();
  final _pw1 = TextEditingController(); // 비밀번호
  final _pw2 = TextEditingController(); // 비밀번호 확인용
  
  // 약관 동의 상태값 (이용약관 및 개인정보처리방침 통합)
  bool _agreedAll = false;
  // 로딩 상태 제어
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _pw1.dispose();
    _pw2.dispose();
    super.dispose();
  }

  /// 회원가입 처리 로직 (Firebase 연동)
  Future<void> _handleSignUp() async {
    // 1. 유효성 검사
    if (_email.text.isEmpty || _pw1.text.isEmpty) {
      _showMsg("이메일과 비밀번호를 입력해주세요.");
      return;
    }
    if (_pw1.text != _pw2.text) {
      _showMsg("비밀번호가 일치하지 않습니다.");
      return;
    }
    if (!_agreedAll) {
      _showMsg("이용약관에 동의해주세요.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Firebase 가입 요청
      final authService = ref.read(authServiceProvider);
      await authService.signUp(_email.text.trim(), _pw1.text.trim());

      // 3. 성공 시 이메일 인증 대기 화면으로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(email: _email.text.trim()),
          ),
        );
      }
    } catch (e) {
      if (mounted) _showMsg(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(child: Column(children: [
        // 상단 헤더: 제목 '회원가입'
        KdsHeader(title: "회원가입"),
        
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── 가입 안내 윈도우 ──
            KdsWindow(
              title: "Create .coffee Account", 
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("개인화 추천과 로그 백업을 시작하세요.", style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
                SizedBox(height: 8),
                Text("가입 시 커피 단어 기반 랜덤 닉네임이 부여돼요.", style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
                SizedBox(height: 8),
                Text("예: 모카트래블러_27", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold, color: KDS.mochaBrown)),
              ])
            ),
            SizedBox(height: 12),
            
            // ── 입력 필드 그룹 ──
            KdsInput(placeholder: "이메일", controller: _email),
            SizedBox(height: 12),
            KdsInput(placeholder: "비밀번호", controller: _pw1, obscure: true),
            SizedBox(height: 12),
            KdsInput(placeholder: "비밀번호 확인", controller: _pw2, obscure: true),
            SizedBox(height: 12),
            
            // ── 약관 동의 영역 (Helper 메서드 사용) ──
            _termsRow("KoHere 이용약관", _agreedAll, (v) => setState(() => _agreedAll = v)),
            SizedBox(height: 12),
            
            // ── 가입 버튼 ──
            _isLoading
              ? Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: KDS.mochaBrown),
                ))
              : KdsButton(
                  label: "가입하고 시작하기", 
                  style: KdsButtonStyle.brown, 
                  onTap: _handleSignUp,
                ),
            SizedBox(height: 16),
            
            // ── 로그인 전환 유도 ──
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("이미 계정이 있나요? ", style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text("로그인", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold, color: KDS.mochaBrown)),
              ),
            ]),
          ]),
        )),
      ])),
    );
  }

  /// 약관 동의 행(Row)을 생성하는 Helper 메서드
  /// 체크박스와 약관 상세보기 버튼을 포함합니다.
  Widget _termsRow(String label, bool val, ValueChanged<bool> onChange) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      // KDS 체크박스 위젯
      KdsCheckbox(label: label, value: val, onChanged: onChange),
      
      // 약관 보기 버튼 (작은 클래식 스타일)
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PolicyScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: KDS.cream, 
            borderRadius: BorderRadius.circular(2), 
            border: Border.all(color: KDS.espressoBlack, width: 2)
          ),
          child: Text("약관보기", style: TextStyle(fontSize: KDS.fontXs, color: KDS.espressoBlack)),
        ),
      ),
    ]);
  }
}
