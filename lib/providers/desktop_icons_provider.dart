import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class IconPosition {
  final String id;
  final String name;
  final IconData icon;
  final Offset position;

  IconPosition({
    required this.id,
    required this.name,
    required this.icon,
    required this.position,
  });

  IconPosition copyWith({Offset? position}) {
    return IconPosition(
      id: id,
      name: name,
      icon: icon,
      position: position ?? this.position,
    );
  }
}

class DesktopIconsNotifier extends StateNotifier<List<IconPosition>> {
  DesktopIconsNotifier() : super([
    IconPosition(id: 'my_brews', name: "나의 커피", icon: Icons.folder, position: const Offset(20, 60)),
    IconPosition(id: 'map', name: "커피 지도", icon: Icons.map, position: const Offset(20, 150)),
    IconPosition(id: 'me', name: "나", icon: Icons.person, position: const Offset(20, 240)),
    IconPosition(id: 'trash', name: "쓰레기통", icon: Icons.delete_outline, position: const Offset(300, 60)), // Fixed right pos roughly
    IconPosition(id: 'new_record', name: "새 기록", icon: Icons.add_box_outlined, position: const Offset(20, 600)),
    IconPosition(id: 'control_panel', name: "제어판", icon: Icons.settings, position: const Offset(300, 600)),
  ]);

  void updatePosition(String id, Offset newPos) {
    state = [
      for (final icon in state)
        if (icon.id == id) icon.copyWith(position: newPos) else icon,
    ];
  }
}

final desktopIconsProvider = StateNotifierProvider<DesktopIconsNotifier, List<IconPosition>>((ref) {
  return DesktopIconsNotifier();
});
