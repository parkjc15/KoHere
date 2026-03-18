import 'package:flutter/material.dart';
import '../../core/theme/kds.dart';

/// Mobile/Guest-Explore Screen
/// 
/// 회원가입 없이 앱의 주요 기능을 미리 볼 수 있는 화면입니다.
/// 가로 스크롤이 가능한 카드 형태의 간단한 슬라이드를 통해 
/// 앱의 디자인과 핵심 유스케이스를 소개합니다.
class GuestExploreScreen extends StatelessWidget {
  const GuestExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(child: Column(children: [
        // 상단 헤더
        KdsHeader(title: "게스트 둘러보기"),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // 안내 문구 (타이틀)
              Text("핵심 기능 미리보기 · 좌우로 스와이프", style: TextStyle(fontSize: KDS.fontXs, fontWeight: FontWeight.bold, color: KDS.espressoBlack)),
              SizedBox(height: 8),
              
              // ── 기능 소개 카드 리스트 (가로 스크롤) ──
              Expanded(child: ListView(
                scrollDirection: Axis.horizontal, 
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                _screenshotCard(
                  "assets/images/explore/desktop.png",
                  "데스크탑 허브", 
                  "모든 활동의 중심, 데스크탑 홈에서\n나만의 커피 세계를 관리하세요."
                ),
                SizedBox(width: 12),
                _screenshotCard(
                  "assets/images/explore/log_list.png",
                  "커피 로그 목록", 
                  "차곡차곡 쌓이는 커피의 기억,\n나만의 취향이 담긴 로그를 확인하세요."
                ),
                SizedBox(width: 12),
                _screenshotCard(
                  "assets/images/explore/log_detail.png",
                  "커피 로그 기록", 
                  "오늘의 온도와 분위기까지 상세하게\n기록하고 나만의 아카이브를 만드세요."
                ),
                SizedBox(width: 12),
                _screenshotCard(
                  "assets/images/explore/control_panel.png",
                  "제어판 & 테마 설정", 
                  "취향에 맞는 테마와 설정으로\nKoHere를 더욱 특별하게 만드세요."
                ),
                SizedBox(width: 12),
                _screenshotCard(
                  "assets/images/explore/me.png",
                  "마이 페이지", 
                  "당신의 커피 여정이 기록된 나 페이지에서\n활동 통계와 설정을 확인하세요."
                ),
                SizedBox(width: 12),
                _screenshotCard(
                  "assets/images/explore/map.png",
                  "커피 지도", 
                  "지도를 통해 주변의 로컬 카페를\n탐색하고 발자취를 남겨보세요."
                ),
                SizedBox(width: 12),
                _screenshotCard(
                  "assets/images/explore/share.png",
                  "플로피 디스크 공유", 
                  "내 기록을 플로피 QR로 생성해\n친구들과 소중한 경험을 공유하세요."
                ),
              ])),
            ]),
          ),
        ),
      ])),
    );
  }

  /// 스크린샷 이미지를 사용하는 카드 빌더
  Widget _screenshotCard(String imagePath, String title, String desc) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KDS.cream, 
        borderRadius: BorderRadius.circular(4), 
        border: Border.all(color: KDS.espressoBlack, width: 2)
      ),
      child: Container(
        decoration: BoxDecoration(
          color: KDS.espressoBlack, // 이미지가 돋보이게 검은 배경
          borderRadius: BorderRadius.circular(2), 
          border: Border.all(color: KDS.creamDark, width: 2)
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 실제 스크린샷 이미지
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            
            // 하단 텍스트 오버레이 (가독성을 위한 그라데이션)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      KDS.espressoBlack.withValues(alpha: 0.9),
                      KDS.espressoBlack.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title, 
                      style: TextStyle(
                        fontSize: KDS.fontMd, 
                        fontWeight: FontWeight.bold, 
                        color: KDS.cream,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      desc, 
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 11, 
                        color: KDS.cream.withValues(alpha: 0.8), 
                        height: 1.4,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
