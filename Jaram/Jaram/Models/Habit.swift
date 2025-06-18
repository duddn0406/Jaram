// Habit.swift
import UIKit

/// 사용자의 습관 정보를 나타내는 구조체
struct Habit: Codable {
    let id: UUID                 // 고유 식별자
    var name: String             // 습관 이름
    var colorHex: String         // 색상 값 (16진수 문자열)
    var reminderTime: Date = Date() // 리마인더 알림 시간
    var checkedDates: [String]   // 체크된 날짜 목록 ("yyyy-MM-dd")

    /// UIColor로 변환된 색상
    var color: UIColor {
        return UIColor(hex: colorHex) ?? .systemBlue
    }

    /// 주어진 날짜에 체크되어 있는지 여부 확인
    func isChecked(for date: Date) -> Bool {
        let key = Habit.dateFormatter.string(from: date)
        return checkedDates.contains(key)
    }

    /// 체크 여부를 토글한 새로운 Habit 인스턴스를 반환
    func toggled(for date: Date) -> Habit {
        let key = Habit.dateFormatter.string(from: date)
        var updated = checkedDates
        if updated.contains(key) {
            updated.removeAll { $0 == key }
        } else {
            updated.append(key)
        }
        return Habit(id: id, name: name, colorHex: colorHex, reminderTime: reminderTime, checkedDates: updated)
    }

    /// 날짜 형식: "yyyy-MM-dd"
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// 전체 체크 횟수
    var totalCheckCount: Int {
        return checkedDates.count
    }

    /// 이번 주 체크 횟수
    var thisWeekCheckCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return checkedDates.compactMap { Habit.dateFormatter.date(from: $0) }
            .filter { calendar.isDate($0, equalTo: now, toGranularity: .weekOfYear) }
            .count
    }

    /// 연속 체크 일수 계산
    var consecutiveDaysCount: Int {
        let calendar = Calendar.current
        let sortedDates = checkedDates
            .compactMap { Habit.dateFormatter.date(from: $0) }
            .sorted(by: >)

        var count = 0
        var current = Date()

        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: current) {
                count += 1
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: current),
                      calendar.isDate(date, inSameDayAs: yesterday) {
                count += 1
                current = yesterday
            } else {
                break
            }
        }

        return count
    }
}
