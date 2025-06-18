import SwiftUI
import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var habits: [Habit] = []
    let tableView = UITableView()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let defaults = UserDefaults.standard
        let todayKey = Habit.dateFormatter.string(from: Date())
        let lastKey = defaults.string(forKey: "lastLaunchDate")
        print("🧪 오늘 키: \(todayKey), 마지막 실행 키: \(lastKey ?? "nil")")

        print("🕒 오늘 날짜 키: \(todayKey)")
        print("🕒 마지막 실행 키: \(lastKey ?? "없음")")

        if lastKey != todayKey {
            print("🌅 날짜 변경 감지됨 → 체크 초기화 시작")

            var updatedHabits = habits
            for i in 0..<updatedHabits.count {
                var habit = updatedHabits[i]
                print("🧹 초기화 중: \(habit.name)")
                habit.checkedDates.removeAll()
                updatedHabits[i] = habit
            }
            HabitStorage.shared.save(updatedHabits)
            defaults.set(todayKey, forKey: "lastLaunchDate")
            habits = HabitStorage.shared.load()
        } else {
            print("✅ 같은 날 → 초기화 생략")
            habits = HabitStorage.shared.load()
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for habit in habits {
            HabitStorage.shared.scheduleNotification(for: habit)
        }
        print("📦 최종 습관 개수: \(habits.count)")
        print("🧾 checkedDates: \(habits.map { "\($0.name): \($0.checkedDates)" })")

        tableView.reloadData()
    }

    override func viewDidLoad() {
        _ = HabitStorage.shared
        super.viewDidLoad()

        // Set UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addHabit))
        let testButton = UIBarButtonItem(title: "🔔", style: .plain, target: self, action: #selector(testNotification))
        navigationItem.rightBarButtonItems = [addButton, testButton]
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshHabits),
            name: Notification.Name("HabitListUpdated"),
            object: nil
        )
    }
    
    @objc func refreshHabits() {
        habits = HabitStorage.shared.load()
        tableView.reloadData()
    }
    
    @objc func addHabit() {
        let addVC = AddHabitViewController()
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let totalDays = 7
        let successDays = habit.checkedDates
            .compactMap { Habit.dateFormatter.date(from: $0) }
            .filter {
                let diff = Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 0
                return diff >= 0 && diff < totalDays
            }
            .count
        let percentage = Int((Double(successDays) / Double(totalDays)) * 100)
        cell.textLabel?.text = "\(habit.name) (\(percentage)%)"

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let circleImage = UIImage(systemName: "circle.fill", withConfiguration: config)
        cell.imageView?.image = circleImage
        cell.imageView?.tintColor = habit.color

        let today = Date()
        cell.accessoryType = habit.isChecked(for: today) ? .checkmark : .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let today = Date()
        var habit = habits[indexPath.row]
        habit = habit.toggled(for: today)
        habits[indexPath.row] = habit

        HabitStorage.shared.save(habits)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        let point = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            let selectedHabit = habits[indexPath.row]
            let editVC = AddHabitViewController()
            editVC.existingHabit = selectedHabit
            editVC.indexToEdit = indexPath.row
            let nav = UINavigationController(rootViewController: editVC)
            present(nav, animated: true)
        }
    }
    
    @objc func testNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "테스트 알림"
        content.body = "10초 뒤 도착한 알림입니다."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("❌ 알림 등록 실패: \(error)")
            } else {
                print("✅ 테스트 알림이 등록되었습니다.")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

// MARK: - CalendarHostController
class CalendarHostController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "캘린더"
        view.backgroundColor = .systemBackground

        let sampleHabit = HabitStorage.shared.load().first ?? Habit(
            id: UUID(),
            name: "샘플 습관",
            colorHex: "#007AFF",
            reminderTime: Date(),
            checkedDates: []
        )
        let calendarView = CalendarView()

        let hostingController = UIHostingController(rootView: calendarView)

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
