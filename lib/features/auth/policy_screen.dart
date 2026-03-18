import 'package:flutter/material.dart';
import '../../core/theme/kds.dart';

/// Policy types supported by the PolicyScreen
enum PolicyType { service, privacy }

/// Mobile/5-Policy Screen
/// 
/// 네이버 정책 페이지(policy.naver.com) 스타일의 통합 정책 화면입니다.
/// 상단 탭을 통해 이용약관과 개인정보처리방침을 전환하며 확인할 수 있습니다.
class PolicyScreen extends StatefulWidget {
  final PolicyType initialType;
  
  const PolicyScreen({
    super.key, 
    this.initialType = PolicyType.service
  });

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  late PolicyType _currentType;

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(
        child: Column(
          children: [
            // ── 상단 헤더 ──
            KdsHeader(
              title: "서비스 정책",
              onBack: () => Navigator.pop(context),
            ),
            
            // ── 정책 탭 선택 (네이버 스타일 탭 바) ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: KDS.espressoBlack, width: 2)),
              ),
              child: Row(
                children: [
                  _tabButton("이용약관", PolicyType.service),
                  _tabButton("개인정보처리방침", PolicyType.privacy),
                ],
              ),
            ),
            
            // ── 정책 본문 영역 ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: KdsWindow(
                  title: _currentType == PolicyType.service ? "KoHere 이용약관" : "개인정보처리방침",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getPolicyContent(),
                  ),
                ),
              ),
            ),
            
            // ── 하단 확인 버튼 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: KdsButton(
                label: "확인하였습니다",
                style: KdsButtonStyle.brown,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, PolicyType type) {
    final bool active = _currentType == type;
    return GestureDetector(
      onTap: () => setState(() => _currentType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? KDS.espressoBlack : Colors.transparent,
          border: active ? null : Border(bottom: BorderSide(color: Colors.transparent, width: 2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: KDS.fontSm,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? KDS.cream : KDS.espressoBlack,
          ),
        ),
      ),
    );
  }

  List<Widget> _getPolicyContent() {
    if (_currentType == PolicyType.service) {
      return [
        Text("제1장 총칙", style: TextStyle(fontSize: KDS.fontMd, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text("제1조 (목적)", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("본 약관은 'KoHere'(이하 '서비스')가 제공하는 모든 서비스의 이용조건 및 절차, 이용자와 서비스 운영자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다."),
        SizedBox(height: 12),
        Text("제2조 (약관의 효력 및 변경)", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("1. 본 약관은 서비스 화면에 게시하거나 기타의 방법으로 이용자에게 공지함으로써 효력이 발생합니다.\n2. 서비스는 필요하다고 인정되는 경우 이 약관을 변경할 수 있으며, 변경된 약관은 제1항과 같은 방법으로 공지합니다."),
        SizedBox(height: 12),
        Text("제2장 서비스 이용 및 가입", style: TextStyle(fontSize: KDS.fontMd, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text("제3조 (회원가입 및 계정)", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("1. 이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후 이 약관에 동의한다는 의사표시를 함으로서 회원가입을 신청합니다.\n2. 회사는 가입 신청자가 본 약관을 준수하며 부정한 목적(타인 명의 도용 등) 없이 신청한 경우 승낙함을 원칙으로 합니다."),
        SizedBox(height: 12),
        Text("제4조 (개인정보의 수집 항목)", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("서비스 이용을 위해 수집하는 정보는 다음과 같습니다:\n\n[필수 수집 항목]\n- 계정 식별 및 통신: 이메일 주소, 비밀번호\n- 서비스 이용 품질 개선: 기기 정보, 서비스 접속 및 이용 로그\n\n[선택 수집 항목]\n- 위치 기반 서비스: 지도 탐색 시 현재 위치 정보\n- 맞춤형 콘텐츠: 선호 커피 취향 데이터(원두, 맛 지표)\n※ 선택 항목 수집에 동의하지 않아도 기본적인 서비스 이용은 가능합니다."),
        SizedBox(height: 12),
        Text("제5조 (서비스의 제공 및 변경)", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("서비스는 다음과 같은 업무를 수행합니다:\n- 커피 로그 기록 및 보관\n- 위치 기반 카페 탐색 및 지도 서비스\n- 사용자 취향 분석 및 통계 제공\n- 디지털 플로피 디스크 형태의 QR 공유 서비스"),
        SizedBox(height: 12),
        Text("제6조 (사용자 콘텐츠의 저작권)", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("1. 이용자가 서비스 내에 게시한 콘텐츠(커피 기록, 평점, 사진 등)의 저작권은 해당 게시자에게 귀속됩니다.\n2. 서비스는 운영, 홍보, 개선을 위해 이용자의 콘텐츠를 익명화된 상태로 활용하거나 통계 자료로 사용할 수 있는 권리를 갖습니다."),
        SizedBox(height: 12),
        Text("제3장 계약 해지 및 이용 제한", style: TextStyle(fontSize: KDS.fontMd, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text("제7조 (계약 해지)", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("이용자는 언제든지 서비스 내 설정 메뉴를 통하여 이용계약 해지(탈퇴)를 신청할 수 있으며, 서비스는 관련 법령이 정하는 바에 따라 이를 즉시 처리합니다."),
        SizedBox(height: 24),
        Text("공고일자: 2026년 3월 9일\n시행일자: 2026년 3월 9일", style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
      ];
    } else {
      return [
        Text("개인정보처리방침", style: TextStyle(fontSize: KDS.fontMd, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text("KoHere는 이용자의 개인정보를 보호하고 관련 법령을 준수하기 위하여 다음과 같은 정책을 수립하여 시행하고 있습니다."),
        SizedBox(height: 12),
        Text("1. 개인정보 수집 및 이용 목적", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("- 회원 가입 및 관리: 이용자 식별, 가입의사 확인, 불량회원 부정이용 방지\n- 서비스 제공: 로그 기록 백업, 위치 기반 검색, 맞춤형 카페 추천\n- 신규 서비스 개발 및 마케팅: 통계적 특성에 따른 서비스 제공, 이벤트 정보 전달"),
        SizedBox(height: 12),
        Text("2. 수집하는 개인정보 항목", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("- 필수 항목: 이메일 주소, 비밀번호, 서비스 이용 기록, 기기 정보\n- 선택 항목: 위치 정보(지도 이용 시), 커피 취향 정보"),
        SizedBox(height: 12),
        Text("3. 개인정보의 보유 및 이용 기간", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("이용자의 개인정보는 원칙적으로 개인정보의 수집 및 이용목적이 달성되면 지체 없이 파기합니다. 단, 관계 법령에 따라 일정 기간 보관해야 하는 경우 해당 법령을 따릅니다."),
        SizedBox(height: 12),
        Text("4. 개인정보의 파기 절차 및 방법", style: TextStyle(fontSize: KDS.fontSm, fontWeight: FontWeight.bold)),
        Text("전자적 파일 형태의 정보는 기록을 재생할 수 없는 기술적 방법을 사용하여 삭제하며, 종이에 출력된 개인정보는 분쇄기로 분쇄하거나 소각하여 파기합니다."),
        SizedBox(height: 24),
        Text("본 방침은 2026년 3월 9일부터 시행됩니다.", style: TextStyle(fontSize: KDS.fontXs, color: KDS.mochaBrown)),
      ];
    }
  }
}
