import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import '../log/coffee_repository.dart';

/// Mobile/11-Map Screen
/// 
/// 커피 지도를 시각화하여 보여주는 화면입니다.
/// 지도 프리뷰, 주변 카페 정보, 그리고 오늘의 맥락(날씨/기분)을 
/// 종합적으로 표시하여 최적의 카페를 추천하거나 흔적을 보여줍니다.
class MapScreen extends ConsumerWidget {
  // Desktop 탭 내부에 포함되는지 여부
  final bool embedded;
  final VoidCallback? onBack;
  
  const MapScreen({super.key, this.embedded = false, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 임베디드 모드면 바로 본체 위젯 반환, 아니면 Scaffold로 감싸서 독립 화면으로 동작
    return embedded 
      ? _body(context, ref) 
      : Scaffold(backgroundColor: KDS.latteBeige, body: SafeArea(child: _body(context, ref)));
  }

  /// 화면의 핵심 콘텐츠 위젯
  Widget _body(BuildContext context, WidgetRef ref) {
    // 실제 로그 데이터 구독
    final allLogs = ref.watch(coffeeLogsProvider).where((l) => !l.isInTrash).toList();
    
    // 통계 계산
    final uniqueCafes = allLogs.map((l) => l.cafeName).toSet().length;
    
    // 이번 주 기록 계산
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final logsThisWeek = allLogs.where((l) => l.createdAt.isAfter(oneWeekAgo)).length;

    // 가장 최근 로그의 맥락 정보
    final latestLog = allLogs.isNotEmpty ? allLogs.first : null;

    return Column(children: [
      // ── 상단 헤더 ──
      KdsHeader(
        title: "커피 지도",
        onBack: onBack ?? (embedded ? null : () => Navigator.pop(context)),
        // 우상단 설정/필터 아이콘
        trailing: Icon(Icons.tune, size: 20, color: KDS.espressoBlack),
      ),
      
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          
          // ── Hero 카드: 지도 프리뷰 ──
          KdsWindow(
            title: "오늘의 지도 · 전체", 
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // 지도 캔버스 영역 (레드로 스타일 프리뷰)
              Container(
                height: 220,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: KDS.creamDark,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: KDS.espressoBlack, width: 2),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("📍 로컬 핀 $uniqueCafes · 프랜차이즈 제외", 
                    style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold, color: KDS.mochaBrown)),
                  // 실제 지도가 들어갈 자리 (현재는 텍스트 안내)
                  Text("1-bit map preview", style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
                ]),
              ),
              SizedBox(height: 10),
              
              // 지도 관련 통계/메타 정보 (실제 데이터 반영)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("최근 7일간 $logsThisWeek회 기록", style: TextStyle(fontSize: KDS.fontXs)),
                Text("반경 5km", style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
              ]),
              SizedBox(height: 10),
              
              // 태그 필터 (Chips)
              Wrap(spacing: 8, children: [
                _chip("로컬 전용", true),
                _chip("산미 낮음", false),
                _chip("조용한", false),
              ]),
            ])
          ),
          SizedBox(height: 12),
          
          // ── 주변 카페 리스트 카드 ──
          KdsWindow(
            title: "근처 로컬 카페", 
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _cafeRow("블루보틀 성수", "420m", "산미 적음 · 좌석 여유 · 조용"),
              SizedBox(height: 8),
              _cafeRow("어니언 성수", "680m", "디저트 강점 · 레트로 무드"),
            ])
          ),
          SizedBox(height: 12),
          
          // ── 오늘의 맥락 정보 카드 (최근 기록 기반) ──
          KdsWindow(
            title: "오늘의 맥락", 
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                latestLog != null 
                  ? "날씨: ${latestLog.weather.split(' ').last}   기분: ${latestLog.mood.split(' ').last}" 
                  : "기록된 맥락이 없습니다.", 
                style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)
              ),
              SizedBox(height: 6),
              Text(
                latestLog != null && latestLog.memo.isNotEmpty
                  ? "한 줄 메모: ${latestLog.memo}"
                  : "메모를 남기려면 새로운 .coffee 로그를 작성하세요.", 
                style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)
              ),
            ])
          ),
        ]),
      )),
    ]);
  }

  /// 지도 태그용 칩 위젯 빌더
  Widget _chip(String label, bool on) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: on ? KDS.mochaBrown : KDS.cream,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: KDS.espressoBlack, width: 2),
      ),
      child: Text(label, style: TextStyle(
        
        fontSize: KDS.fontXs, 
        color: on ? KDS.cream : KDS.espressoBlack
      )),
    );
  }

  /// 카페 리스트 한 행을 구성하는 빌더
  Widget _cafeRow(String name, String dist, String desc) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(dist, style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
      ]),
      SizedBox(height: 2),
      Text(desc, style: TextStyle(fontSize: KDS.fontXs, color: KDS.gray)),
    ]);
  }
}
