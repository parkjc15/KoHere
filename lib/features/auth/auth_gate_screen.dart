import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import '../desktop/desktop_screen.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'guest_explore_screen.dart';
import 'email_verification_screen.dart';

/// Mobile/2-AuthGate Screen
/// 
/// 인증 상태에 따라 화면을 분기합니다.
/// 1. 로그인 되어 있고 이메일 인증됨 -> DesktopScreen
/// 2. 로그인 되어 있으나 이메일 인증 안됨 -> EmailVerificationScreen
/// 3. 로그인 안됨 -> 시작하기 선택 화면
class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  Future<bool>? _sessionFuture;
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authService = ref.read(authServiceProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // 동일한 유저일 경우 Future를 재사용하여 'waiting' 상태 진입(깜박임) 방지
          if (_lastUserId != user.uid) {
            _sessionFuture = authService.isSessionExpired();
            _lastUserId = user.uid;
          }

          return FutureBuilder<bool>(
            future: _sessionFuture,
            builder: (context, snapshot) {
              // 최초 로딩 시에만 로딩 화면 표시 (이미 결과가 있거나 데스크탑이 보이고 있었다면 로딩을 건너뜀)
              if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                return _buildLoading();
              }
              
              if (snapshot.data == true) {
                // 30일 경과 시 로그아웃 처리 (빌드 종료 후 수행)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  authService.signOut();
                });
                return _buildChoiceUI(context);
              }

              if (user.emailVerified) {
                return const DesktopScreen();
              } else {
                return EmailVerificationScreen(email: user.email ?? "");
              }
            },
          );
        }
        // 로그아웃 시 세션 미래값 초기화
        _sessionFuture = null;
        _lastUserId = null;
        return _buildChoiceUI(context);
      },
      loading: () => _buildLoading(),
      error: (err, stack) => _buildChoiceUI(context),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: KDS.espressoBlack,
      body: Center(child: CircularProgressIndicator(color: KDS.cream)),
    );
  }

  Widget _buildChoiceUI(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(
        child: Column(children: [
          KdsHeader(title: "시작하기", showBackButton: false, trailing: SizedBox(width: 20)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                KdsWindow(
                  title: "Welcome to Kohere", 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: "KoHere", style: TextStyle(fontSize: KDS.fontMd, fontWeight: FontWeight.bold, color: KDS.espressoBlack)),
                            TextSpan(text: "는 당신의 하루와 커피 향을 담습니다.", style: TextStyle(fontSize: KDS.fontSm, color: KDS.mochaBrown)),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text("기록과 지도가 모여 당신의 취향이 쌓입니다.", style: TextStyle(fontSize: KDS.fontSm, color: KDS.mochaBrown)),
                      SizedBox(height: 12),
                      Text("나만의 커피 라이프 로그를 완성하세요.", style: TextStyle(fontSize: KDS.fontMd, fontWeight: FontWeight.bold, color: KDS.espressoBlack)),
                      SizedBox(height: 24),
                    ],
                  )
                ),
                SizedBox(height: 14),
                KdsButton(
                  label: "로그인으로 계속", 
                  style: KdsButtonStyle.active, 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()))
                ),
                SizedBox(height: 14),
                KdsButton(
                  label: "회원가입으로 시작", 
                  style: KdsButtonStyle.brown, 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()))
                ),
                SizedBox(height: 14),
                KdsButton(
                  label: "게스트로 둘러보기", 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuestExploreScreen()))
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
