// CalendarView.swift
import SwiftUI

// 전체 캘린더 및 선택된 날짜의 습관 성공/실패를 보여주는 뷰
struct CalendarView: View {
    @State private var selectedDate: Date? = nil
    @State private var habits: [Habit] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("캘린더")
                .font(.title2)
                .padding(.top)

            CalendarGrid(selectedDate: $selectedDate)

            // 선택된 날짜가 있을 경우 해당 날짜의 성공/실패 습관 표시
            if let selectedDate = selectedDate {
                let key = Habit.dateFormatter.string(from: selectedDate)
                let successful = habits.filter { $0.checkedDates.contains(key) }
                let failed = habits.filter { !$0.checkedDates.contains(key) }

                VStack(alignment: .leading, spacing: 8) {
                    Text("선택한 날짜: \(key)")
                        .font(.headline)

                    Text("성공한 습관")
                        .foregroundColor(.green)
                        .bold()
                    ForEach(successful, id: \.id) { habit in
                        Text("• \(habit.name)")
                    }

                    Text("실패한 습관")
                        .foregroundColor(.red)
                        .bold()
                    ForEach(failed, id: \.id) { habit in
                        Text("• \(habit.name)")
                    }
                }
                .padding()
            }

            Spacer()
        }
        .onAppear {
            habits = HabitStorage.shared.load()
        }
        .onChange(of: selectedDate) { _ in
            habits = HabitStorage.shared.load()
        }
    }
}

// 현재 달의 날짜를 계산하여 그리드 형태로 표시하는 캘린더 뷰
struct CalendarGrid: View {
    @Binding var selectedDate: Date?
    let calendar = Calendar.current
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        let currentDate = Date()
        let range = calendar.range(of: .day, in: .month, for: currentDate) ?? (1..<31)
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? Date()
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        let days = Array(repeating: nil, count: firstWeekday) + range.map { $0 }

        let allHabits = HabitStorage.shared.load()

        LazyVGrid(columns: columns, spacing: 8) {
            // 요일 헤더
            ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                Text(day)
                    .bold()
                    .frame(maxWidth: .infinity)
            }

            // 날짜 셀
            ForEach(0..<days.count, id: \.self) { index in
                if let day = days[index] {
                    let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) ?? Date()
                    let dateString = Habit.dateFormatter.string(from: date)
                    let isAnyChecked = allHabits.contains { $0.checkedDates.contains(dateString) }

                    Text("\(day)")
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(isAnyChecked ? Color.blue.opacity(0.7) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(isAnyChecked ? .white : .primary)
                        .onTapGesture {
                            selectedDate = date
                        }
                } else {
                    Color.clear.frame(height: 30)
                }
            }
        }
        .padding(.horizontal)
    }
}

// Preview 용
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
