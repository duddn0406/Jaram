# Jaram - iOS Habit Tracker App

Jaram은 간단하고 직관적인 iOS 습관 관리 앱으로, 사용자가 자신의 습관을 생성하고, 추적하며, 알림을 통해 동기를 부여받을 수 있도록 설계되었습니다.

---

## 🚀 주요 기능

- ✅ 습관 추가, 수정, 삭제
- ☑️ 하루 체크 기능
- 🕒 리마인더 알림 (반복 알림)
- 📊 성공률 통계
- 🗓️ 캘린더 기반 성공/실패 표시
- 💾 JSON 기반 로컬 저장
- 🔔 포그라운드 & 백그라운드 알림 지원

---

## 📁 프로젝트 구조

```
Jaram/
├── Helpers/
│   ├── HabitStorage.swift       // 저장, 로드, 알림 관리
│   └── UIColor+Hex.swift        // HEX 색상 확장
├── Models/
│   ├── Habit.swift              // Habit 데이터 모델
│   └── CalendarView.swift       // 캘린더 뷰 커스텀
├── Views/
│   ├── ViewController.swift         // 메인 화면
│   └── AddHabitViewController.swift // 습관 추가/수정
├── Resources/
│   └── habit.json               // 초기 데이터 (옵션)
├── AppDelegate.swift
├── SceneDelegate.swift
└── Info.plist
```

---

## 🧠 작동 방식 요약

### 📌 1. Habit 모델
- `UUID` 기반 고유 id
- `reminderTime: Date` 로 알림 시간 저장
- `checkedDates: [String]` 으로 날짜별 체크 기록

### 📌 2. 데이터 저장
- `HabitStorage.swift`에서 JSON 파일로 인코딩/디코딩
- 앱 문서 디렉토리에 저장
- 최초 실행 시 `habit.json` 복사 가능

### 📌 3. 알림 시스템
- `UNCalendarNotificationTrigger` 로 매일 알림 등록
- 포그라운드에서도 배너/소리로 표시 (`delegate` 적용)
- `+` 버튼 옆 🔔 버튼으로 테스트 알림 10초 후 발송

### 📌 4. UI 화면 구성
- `ViewController`: 습관 목록 및 체크 화면
- `AddHabitViewController`: 습관 입력 및 수정
- 하단 탭: 통계 / 캘린더

---

## 🧪 테스트 팁

- 상단 🔔 버튼으로 테스트 알림 사용
- 습관 추가 시 `reminderTime`을 현재 시각 +1분으로 설정
- 실제 디바이스에서 알림 테스트 권장 (시뮬레이터는 제한 있음)

---

## 🌱 향후 개선 아이디어

- Core Data 도입
- iCloud 동기화
- 주간/월간 리포트 제공
- 습관 성공 streak 기능 추가

---

## 🙏 제작자

- 개발자: 이영우 (Lee Young Woo)
- 기술 스택: Swift, UIKit, UserNotifications, Xcode

---

##시현 영상 

https://youtu.be/KeGTblMxaaQ
