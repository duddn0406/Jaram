import Foundation
import UserNotifications

class HabitStorage {
    static let shared = HabitStorage()
    private let fileName = "habits.json"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    init() {
        initializeDataIfNeeded()
    }

    private func initializeDataIfNeeded() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "hasInitializedData") {
            return
        }

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path),
           let bundleURL = Bundle.main.url(forResource: "habit", withExtension: "json") {
            do {
                try fileManager.copyItem(at: bundleURL, to: fileURL)
                defaults.set(true, forKey: "hasInitializedData")
                print("✅ 초기 habit.json 복사 완료")
            } catch {
                print("❌ 초기 habit.json 복사 실패: \(error)")
            }
        } else {
            print("⚠️ 번들에 habit.json 없음 또는 파일 이미 존재")
        }
    }

    func save(_ habits: [Habit]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(habits)
            try data.write(to: fileURL)
        } catch {
            print("❌ 저장 실패: \(error)")
        }
    }

    func load() -> [Habit] {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let habits = try decoder.decode([Habit].self, from: data)
            print("✅ JSON 로딩 성공: \(habits.count)개 로드됨")
            return habits
        } catch {
            print("❌ JSON 로딩 실패: \(error)")
            return []
        }
    }
    func update(_ habit: Habit, at index: Int) {
        var habits = load()
        guard index >= 0 && index < habits.count else { return }
        habits[index] = habit
        save(habits)
    }

    func scheduleNotification(for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "습관 리마인더"
        content.body = "\"\(habit.name)\" 할 시간이에요!"
        content.sound = .default

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: habit.reminderTime)

        // 로그로 시간 확인
        print("⏰ [\(habit.name)] 알림 예약 시간: \(dateComponents.hour ?? -1):\(dateComponents.minute ?? -1)")

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // 중복 방지 위해 기존 알림 제거
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])

        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 등록 실패: \(error)")
            } else {
                print("✅ [\(habit.name)] 알림 등록 성공")
            }
        }
    }
}
