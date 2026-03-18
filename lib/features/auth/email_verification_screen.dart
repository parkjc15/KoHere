import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import '../desktop/desktop_screen.dart';

/// Mobile/5-Email Verification Screen
/// 
/// 가입 후 이메일 인증이 완료될 때까지 대기하는 화면입니다.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  Timer? _timer;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    // 3초마다 서버와 통신하여 인증 여부 확인
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 이메일 인증 여부 실시간 확인
  Future<void> _checkEmailVerified() async {
    final authService = ref.read(authServiceProvider);
    await authService.reloadUser();
    
    if (authService.currentUser?.emailVerified ?? false) {
      if (mounted) {
        setState(() => _isVerified = true);
        _timer?.cancel();
        
        // 인증 성공 시 잠시 후 메인 화면으로 이동
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => const DesktopScreen()),
              (_) => false
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(
        child: Column(children: [
          KdsHeader(title: "계정 활성화", showBackButton: false),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KdsWindow(
                    title: _isVerified ? "Success" : "Pending Verification",
                    child: Column(children: [
                      // 상태 아이콘
                      Icon(
                        _isVerified ? Icons.check_circle_outline : Icons.mark_email_unread_outlined, 
                        size: 64, 
                        color: _isVerified ? Colors.green : KDS.mochaBrown
                      ),
                      SizedBox(height: 24),
                      
                      // 안내 메시지
                      Text(
                        _isVerified ? "인증이 완료되었습니다!" : "${widget.email}\n주소로 인증 메일을 보냈습니다.", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: KDS.fontMd, fontWeight: FontWeight.bold)
                      ),
                      SizedBox(height: 16),
                      
                      Text(
                        _isVerified 
                          ? "잠시 후 데스크탑 홈으로 이동합니다."
                          : "메일함의 링크를 클릭하여 계정을 활성화해주세요.\n인증 완료 시 이 화면이 자동으로 전환됩니다.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: KDS.fontXs, color: KDS.grayDark, height: 1.5)
                      ),
                      SizedBox(height: 32),
                      
                      if (!_isVerified) ...[
                        // 재발송 버튼
                        KdsButton(
                          label: "인증 메일 재발송",
                          onTap: () async {
                            await ref.read(authServiceProvider).sendVerificationEmail();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("인증 메일이 재발송되었습니다."))
                              );
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        
                        // 취소/로그인 이동 버튼
                        KdsButton(
                          label: "로그인 화면으로 돌아가기",
                          style: KdsButtonStyle.cream,
                          onTap: () {
                            ref.read(authServiceProvider).signOut();
                            Navigator.pushAndRemoveUntil(
                              context, 
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (_) => false
                            );
                          },
                        ),
                      ],
                    ]),
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
