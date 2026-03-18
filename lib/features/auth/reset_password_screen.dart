import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import 'auth_service.dart';
import 'login_screen.dart';

/// Mobile/5-Reset Password Screen
/// 
/// 이메일 링크를 통해 전달받은 코드를 이용해 실제 비밀번호를 변경하는 화면입니다.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String code; // Firebase에서 보낸 oobCode
  const ResetPasswordScreen({super.key, required this.code});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _pw1 = TextEditingController();
  final _pw2 = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pw1.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (_pw1.text.isEmpty) {
      _showMsg("새 비밀번호를 입력해주세요.");
      return;
    }
    if (_pw1.text != _pw2.text) {
      _showMsg("비밀번호가 일치하지 않습니다.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).confirmPasswordReset(widget.code, _pw1.text.trim());
      if (mounted) {
        _showMsg("비밀번호가 성공적으로 변경되었습니다. 다시 로그인해주세요.");
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false
            );
          }
        });
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
      body: SafeArea(
        child: Column(children: [
          KdsHeader(title: "비밀번호 재설정", showBackButton: false),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  KdsWindow(
                    title: "Security Update",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "새로운 비밀번호를 입력해주세요.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: KDS.fontSm, color: KDS.espressoBlack),
                        ),
                        SizedBox(height: 32),
                        
                        KdsInput(placeholder: "새 비밀번호", controller: _pw1, obscure: true),
                        SizedBox(height: 12),
                        KdsInput(placeholder: "비밀번호 확인", controller: _pw2, obscure: true),
                        SizedBox(height: 24),
                        
                        _isLoading 
                          ? Center(child: CircularProgressIndicator(color: KDS.mochaBrown))
                          : KdsButton(
                              label: "비밀번호 변경하기",
                              style: KdsButtonStyle.active,
                              onTap: _handleReset,
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
