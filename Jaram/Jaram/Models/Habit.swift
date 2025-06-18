// Habit.swift
import UIKit

struct Habit: Codable {
    let id: UUID
    var name: String
    var colorHex: String
    var reminderTime: Date = Date()
    var checkedDates: [String] // 날짜별 체크 기록 ("yyyy-MM-dd")

    var color: UIColor {
        return UIColor(hex: colorHex) ?? .systemBlue
    }

    func isChecked(for date: Date) -> Bool {
        let key = Habit.dateFormatter.string(from: date)
        return checkedDates.contains(key)
    }

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

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    var totalCheckCount: Int {
        return checkedDates.count
    }

    var thisWeekCheckCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return checkedDates.compactMap { Habit.dateFormatter.date(from: $0) }
            .filter { calendar.isDate($0, equalTo: now, toGranularity: .weekOfYear) }
            .count
    }

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
