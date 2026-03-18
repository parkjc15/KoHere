import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import '../../core/theme/kds.dart';
import '../auth/auth_gate_screen.dart';
import '../log/coffee_repository.dart';

/// Mobile/1-Boot Screen
/// 
/// 앱 초기 구동 시 표시되는 스플래시 화면입니다.
/// 클래식 컴퓨터 부팅 시퀀스를 모티브로 디자인되었으며, 
/// CRT 모니터의 스캔라인 효과와 로딩 바 애니메이션을 포함합니다.
class BootScreen extends ConsumerStatefulWidget {
  const BootScreen({super.key});
  @override ConsumerState<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends ConsumerState<BootScreen> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _steamCtrl; // 수증기 전용 루핑 컨트롤러
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // 3초 동안 진행되는 로딩 애니메이션 설정
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..forward();
    
    // 수증기 애니메이션: 1.5초 주기로 무한 반복
    _steamCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();

    // 초기화 로직 실행
    _initApp();

    // 애니메이션 완료 및 초기화 완료 시 다음 화면(AuthGateScreen)으로 전환
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _checkAndNavigate();
      }
    });
  }

  Future<void> _initApp() async {
    try {
      // Firebase 초기화
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // 로컬 데이터베이스 초기화
      final repository = ref.read(coffeeRepositoryProvider);
      await repository.init();
      
      // 상태 데이터 로드
      ref.read(coffeeLogsProvider.notifier).loadLogs();
      
      if (mounted) {
        setState(() => _isInitialized = true);
        _checkAndNavigate();
      }
    } catch (e) {
      // 초기화 실패 시 처리 (실제 서비스에서는 에러 다이얼로그 등을 고려 가능)
      debugPrint("Initialization Error: $e");
    }
  }

  void _checkAndNavigate() {
    if (_ctrl.isCompleted && _isInitialized && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, _) => const AuthGateScreen(),
          transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override void dispose() { 
    _ctrl.dispose(); 
    _steamCtrl.dispose();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.espressoBlack,
      body: Stack(children: [
        // 메인 부팅 레이아웃
        // ── HappyMacFrame (KDS AppIcon + Steam Animation) ──
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── HappyMacFrame (KDS AppIcon + Steam Animation) ──
              KdsAppIcon(size: 96, steamAnimation: _steamCtrl, hasBorder: true),
              SizedBox(height: 24),
              
              // ── 앱 타이틀 및 태그라인 ──
              Text("KoHere", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: KDS.cream)),
              SizedBox(height: 24),
              Text("コーヒー · Here", style: TextStyle(fontSize: 16, color: KDS.latteBeige)),
              SizedBox(height: 24),
              
              // ── ProgressBar (애니메이션 연동) ──
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) => Container(
                  width: 200, height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333), 
                    borderRadius: BorderRadius.circular(2), 
                    border: Border.all(color: KDS.creamDark, width: 1)
                  ),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 200 * _ctrl.value, 
                    height: 12, 
                    decoration: BoxDecoration(color: KDS.cream, borderRadius: BorderRadius.circular(2))
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // ── 시스템 안내 ──
              Text("커피 향을 불러오는 중...", style: TextStyle(fontSize: 13, color: KDS.gray)),
              SizedBox(height: 24),
              Text("KoHere OS v1.0 - 2026", style: TextStyle(fontSize: 12, color: KDS.grayDark)),
            ]),
          ),
        ),
      ]),
    );
  }
}
