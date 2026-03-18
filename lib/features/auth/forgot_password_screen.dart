import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import 'auth_service.dart';

/// Mobile/5-Forgot Password Screen
/// 
/// 사용자가 비밀번호를 잊어버렸을 때 이메일을 입력하여 재설정 메일을 요청하는 화면입니다.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _handleResetRequest() async {
    if (_email.text.isEmpty) {
      _showMsg("이메일을 입력해주세요.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(_email.text.trim());
      if (mounted) {
        _showMsg("비밀번호 재설정 메일이 발송되었습니다. 메일함을 확인해주세요.");
        // 잠시 후 뒤로 이동
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
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
          KdsHeader(title: "비밀번호 초기화", onBack: () => Navigator.pop(context)),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                   KdsWindow(
                    title: "System Recovery",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: KDS.fontSm, color: KDS.espressoBlack, height: 1.5),
                        ),
                        SizedBox(height: 32),
                        
                        KdsInput(placeholder: "이메일 주소", controller: _email),
                        SizedBox(height: 24),
                        
                        _isLoading 
                          ? Center(child: CircularProgressIndicator(color: KDS.mochaBrown))
                          : KdsButton(
                              label: "초기화 메일 보내기",
                              style: KdsButtonStyle.active,
                              onTap: _handleResetRequest,
                            ),
                        SizedBox(height: 12),
                        
                        KdsButton(
                          label: "취소",
                          onTap: () => Navigator.pop(context),
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
