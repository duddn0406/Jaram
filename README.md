주요 기능
	•	습관 추가/수정/삭제
	•	체크 및 체크 해제
	•	리마인더 알림 (포그라운드 지원)
	•	통계 / 캘린더 탭
	•	JSON 기반 저장
 
⸻

폴더 구조 설명
	•	Helpers/ → 저장 및 유틸
	•	Models/ → Habit.swift, CalendarView.swift
	•	Views/ → 주요 화면 컨트롤러
	•	Resources/ → 초기 데이터 (선택사항)

⸻

작동 방식
	•	UUID와 reminderTime 기반 알림
	•	UserDefaults + JSON 파일 저장
	•	UNCalendarNotificationTrigger 반복 알림
	•	포그라운드에서도 알림 배너 표시됨

⸻

테스트 팁
	•	🔔 버튼으로 테스트 알림 확인
	•	습관 시간 1~2분 뒤로 설정해서 알림 테스트 (작동 x)

⸻
향후 추가 아이디어
	•	iCloud 동기화
	•	CoreData 확장
	•	주간/월간 리포트

⸻
개선 사항
  •	알림이 현재 제대로 오지 않음
	•	통계 라이브러리가 작동하지 않아 숫자로만 표시되어 있음
