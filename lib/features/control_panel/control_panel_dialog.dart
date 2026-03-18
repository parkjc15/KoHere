import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/widgets/mac_widgets.dart';
import '../../core/theme/kohere_theme.dart';
import '../../providers/system_provider.dart';

class ControlPanelDialog extends ConsumerWidget {
  const ControlPanelDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ControlPanelDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemState = ref.watch(systemStateProvider);
    
    return MacDialog(
      title: '제어판 (환경 설정)',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('시스템 환경'),
          SizedBox(height: 12),
          
          // Weather Selection
          _buildLabel('시뮬레이션 날씨'),
          _buildOptionGroup(
            ['맑음', '흐림', '비', '눈'],
            systemState.weather,
            (val) => ref.read(systemStateProvider.notifier).setWeather(val),
          ),
          
          SizedBox(height: 20),
          
          // Mood Selection
          _buildLabel('현재 기분 매개변수'),
          _buildOptionGroup(
            ['평온함', '활기참', '차분함', '우울함'],
            systemState.mood,
            (val) => ref.read(systemStateProvider.notifier).setMood(val),
          ),
          
          SizedBox(height: 20),
          
          // Brightness Slider
          _buildLabel('화면 출력 해상도 (밝기)'),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: KohereTheme.espressoBlack,
              inactiveTrackColor: KohereTheme.espressoBlack.withAlpha(50),
              thumbColor: KohereTheme.espressoBlack,
              overlayColor: KohereTheme.espressoBlack.withAlpha(30),
            ),
            child: Slider(
              value: systemState.brightness,
              onChanged: (val) => ref.read(systemStateProvider.notifier).setBrightness(val),
            ),
          ),

          SizedBox(height: 12),
          
          // Custom Wallpaper Background
          _buildLabel('바탕화면 커스텀'),
          Row(
            children: [
              MacButton(
                label: '사진첩에서 불러오기',
                onPressed: () async {
                  final picker = ImagePicker();
                  final XFile? photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (photo != null) {
                    ref.read(systemStateProvider.notifier).setWallpaper(photo.path);
                  }
                },
              ),
              SizedBox(width: 8),
              if (systemState.wallpaperPath != null)
                MacButton(
                  label: '초기화',
                  onPressed: () {
                    ref.read(systemStateProvider.notifier).setWallpaper(null);
                  },
                ),
            ],
          ),
        ],
      ),
      actions: [
        MacButton(
          label: '닫기',
          isDefault: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: KohereTheme.espressoBlack, width: 1)),
      ),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildOptionGroup(List<String> options, String current, Function(String) onSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == current;
        return InkWell(
          onTap: () => onSelected(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? KohereTheme.espressoBlack : Colors.white,
              border: Border.all(color: KohereTheme.espressoBlack, width: 2),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? Colors.white : KohereTheme.espressoBlack,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
