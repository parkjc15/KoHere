# Kohere 개발 트러블슈팅 및 에러 로그

추후 같은 실수를 반복하지 않도록, 개발 과정에서 발생한 에러 현상과 조치 내역을 여기에 기록합니다.

## 1. iOS 버전에 대한 `IPHONEOS_DEPLOYMENT_TARGET` 불일치 에러 (2026-03-05)

### 에러 증상
- iOS 시뮬레이터 빌드 과정 중 에러 발생: `warning: The iOS Simulator deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 11.0, but the range of supported deployment target versions is 12.0 to 26.2.99.`
- 이와 함께 위치 기반 처리 및 이미지 접근에 관련된 라이브러리가 호환되지 못해 컴파일 실패.

### 원인
새로 추가한 라이브러리(`geolocator_apple` 등)들이 최소 iOS 12.0 이상을 필요로 하는데, 현재 Flutter iOS 프로젝트(`Runner`)가 구버전인 iOS 11.0을 타겟으로 잡고 있었음.

### 해결책
`ios/Podfile` 을 열고 아래 두 가지를 수정:
1. `platform :ios, '13.0'` 으로 명시 (안전하게 13.0 으로 올림).
2. `post_install` 단계에서 모든 패키지의 `['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'` 속성을 강제로 맞추는 구문 삽입.
이후 `flutter clean && flutter pub get && cd ios && pod install --repo-update` 로 클린 셋업 완료.

---

## 2. Riverpod `StateNotifier` Import 및 널 안정성 누락 에러 (2026-03-05)

### 에러 증상
- `Error: Type 'StateNotifier' not found.`
- `Error: Method not found: 'StateNotifierProvider'.`
- `Error: Expected a declaration, but got '}'.` (괄호 개수 밸런스 안맞음)
- `Error: The argument type 'String?' can't be assigned to the parameter type 'String'.`

### 원인 & 해결책
1. **Riverpod 구버전 패턴 누락**: `flutter_riverpod`가 최신 버전으로 업데이트하면서, `StateNotifier`가 `state_notifier` 패키지로 완전히 쪼개어졌음. 
   - 조치: `import 'package:state_notifier/state_notifier.dart';` 와 `import 'package:flutter_riverpod/legacy.dart';` 구문을 `window_manager_provider.dart` 등에 명시적으로 추가하여 해결.
2. **괄호 밸런스 에러**: 위젯을 다중으로 감싸거나 복사/붙여넣기 시 닫치지 않은 소괄호나 불필요한 중괄호 발생.
   - 조치: `desktop_screen.dart`의 비정상적인 `}` 삭제 및 `mac_window.dart` 내 `GestureDetector` 컴포넌트에 닫는 괄호 `)` 보충.
3. **Null Safety**: nullable 변수인 `folderName`(String?)을 Null 불가능 타입을 요구하는 메서드에 넘기려 할 때 빌드 거부.
   - 조치: `widget.log.folderName ?? "알 수 없음"` 과 같이 기본값(Fallback) 지정 등 Null 병합 연산자(`??`)를 사용하여 널 안정성 달성.
