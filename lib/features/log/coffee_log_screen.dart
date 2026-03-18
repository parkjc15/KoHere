import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/kds.dart';
import 'coffee_repository.dart';

/// Mobile/7-CoffeeLog Screen
/// 
/// 새로운 커피 로그를 작성하는 화면입니다.
/// 카페 이름, 메뉴, 지역, 날씨, 기분, 분위기 등 다양한 메타데이터를
/// 디자인 시스템 가이드에 맞춰 입력받고 저장합니다.
class CoffeeLogScreen extends ConsumerStatefulWidget {
  final bool isWindow;
  final VoidCallback? onSave;
  const CoffeeLogScreen({super.key, this.isWindow = false, this.onSave});
  @override ConsumerState<CoffeeLogScreen> createState() => _CoffeeLogScreenState();
}

class _CoffeeLogScreenState extends ConsumerState<CoffeeLogScreen> {
  // 텍스트 입력 컨트롤러
  final _cafe = TextEditingController();
  final _menu = TextEditingController();
  final _note = TextEditingController();
  
  // 선택형 항목(Chips) 상태값
  String _loc = '', _weather = '', _mood = '', _ambiance = '';

  @override
  void dispose() {
    _cafe.dispose();
    _menu.dispose();
    _note.dispose();
    super.dispose();
  }

  /// 로그 저장 처리
  Future<void> _handleSave() async {
    final cafe = _cafe.text.trim();
    final menu = _menu.text.trim();
    final note = _note.text.trim();

    // 필수 입력값 검증
    if (cafe.isEmpty || menu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("카페 이름과 메뉴를 입력해 주세요."),
          backgroundColor: KDS.mochaBrown,
        ),
      );
      return;
    }

    // Provider를 통해 데이터 저장
    await ref.read(coffeeLogsProvider.notifier).addLog(
      cafeName: cafe,
      menu: menu,
      weather: _weather.isEmpty ? "☀️ 맑음" : _weather,
      mood: _mood.isEmpty ? "😊 기쁨" : _mood,
      ambiance: _ambiance.isEmpty ? "🤫 조용" : _ambiance,
      memo: note,
      folderName: _loc.isEmpty ? "성수" : _loc,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("커피 로그가 저장되었습니다.")),
      );
      if (widget.onSave != null) {
        widget.onSave!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 윈도우 모드인 경우 Scaffold 없이 내부 콘텐츠만 반환
    if (widget.isWindow) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: _buildForm(),
      );
    }

    return Scaffold(
      backgroundColor: KDS.latteBeige,
      body: SafeArea(child: Column(children: [
        // 상단 헤더
        KdsHeader(title: "새 .coffee 로그"),
        
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          // ── 메인 입력 윈도우 (KDS 컴포넌트) ──
          child: KdsWindow(
            title: "log_20250306.coffee", 
            child: _buildForm()
          ),
        )),
      ])),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 카페 입력
        _field("☕ 카페", KdsInput(placeholder: "블루보틀 성수", controller: _cafe)),
        SizedBox(height: 14),
        
        // 지역 선택 (Chips)
        _field("📍 지역", _chips(["성수", "합정", "연남", "이태원"], _loc, (v) => setState(() => _loc = v))),
        SizedBox(height: 14),
        
        // 날씨 선택 (Chips)
        _field("🌤️ 날씨", _chips(["☀️ 맑음", "⛅ 흐림", "🌧️ 비", "❄️ 눈"], _weather, (v) => setState(() => _weather = v))),
        SizedBox(height: 14),
        
        // 기분 선택 (Chips)
        _field("😊 기분", _chips(["😊 기쁨", "😌 평온", "🔥 활력", "😴 피곤"], _mood, (v) => setState(() => _mood = v))),
        SizedBox(height: 14),
        
        // 메뉴 입력
        _field("🍵 메뉴", KdsInput(placeholder: "아이스 아메리카노", controller: _menu)),
        SizedBox(height: 14),
        
        // 분위기 선택 (Chips)
        _field("🎵 분위기", _chips(["🤫 조용", "🎵 음악", "💬 대화", "📖 독서"], _ambiance, (v) => setState(() => _ambiance = v))),
        SizedBox(height: 14),
        
        // 메모 입력 (멀티라인/높이 조절)
        _field("📝 메모", KdsInput(placeholder: "오늘의 커피 한 줄 메모...", controller: _note, maxLines: 3, height: 72)),
        SizedBox(height: 14),
        
        // 저장 버튼
        KdsButton(
          label: "저장하기", 
          style: KdsButtonStyle.brown, 
          onTap: _handleSave,
        ),
      ],
    );
  }

  /// 필드 레이블과 콘텐츠 위젯을 묶어주는 래퍼
  Widget _field(String label, Widget child) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: KDS.espressoBlack)),
      SizedBox(height: 4),
      child,
    ]);
  }

  /// 디자인 스타일에 맞는 칩(Chips) 선택 위젯 생성기
  Widget _chips(List<String> opts, String sel, ValueChanged<String> onTap) {
    return Wrap(spacing: 6, runSpacing: 6, children: opts.map((o) {
      final on = sel == o; // 선택 여부 확인
      return GestureDetector(
        onTap: () => onTap(o),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: on ? KDS.mochaBrown : KDS.cream, // 선택 시 브라운 배경
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: KDS.espressoBlack, width: 2),
          ),
          child: Text(o, style: TextStyle(
            
            fontSize: KDS.fontXs, 
            color: on ? KDS.cream : KDS.espressoBlack
          )),
        ),
      );
    }).toList());
  }
}
