import SwiftUI
import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    /// 습관 목록을 저장하는 배열
    var habits: [Habit] = []
    
    /// 습관을 표시하는 테이블 뷰
    let tableView = UITableView()
    
    /// 뷰가 나타나기 직전에 호출됨. 습관 데이터 로드 및 일일 초기화 로직을 처리함.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let defaults = UserDefaults.standard
        let todayKey = Habit.dateFormatter.string(from: Date())
        let lastKey = defaults.string(forKey: "lastLaunchDate")
        
        // 마지막 실행 날짜와 비교하여 새로운 날에 앱이 실행되었는지 확인
        if lastKey != todayKey {
            // 새로운 날이 감지되면 모든 습관의 체크 날짜를 초기화
            var updatedHabits = habits
            for i in 0..<updatedHabits.count {
                var habit = updatedHabits[i]
                habit.checkedDates.removeAll()
                updatedHabits[i] = habit
            }
            HabitStorage.shared.save(updatedHabits)
            defaults.set(todayKey, forKey: "lastLaunchDate")
            habits = HabitStorage.shared.load()
        } else {
            // 같은 날이면 습관을 초기화하지 않고 불러옴
            habits = HabitStorage.shared.load()
        }
        
        // 모든 대기 중인 알림을 제거하고, 갱신된 습관을 기준으로 다시 예약
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for habit in habits {
            HabitStorage.shared.scheduleNotification(for: habit)
        }

        // 변경 사항을 반영하기 위해 테이블 뷰 데이터 갱신
        tableView.reloadData()
    }

    /// 컨트롤러의 뷰가 메모리에 로드된 후 호출됨. UI 구성 요소와 옵저버를 설정함.
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = HabitStorage.shared

        // 앱이 포그라운드 상태일 때 알림을 처리하기 위해 UNUserNotificationCenter의 delegate를 self로 설정
        UNUserNotificationCenter.current().delegate = self

        // 테이블 뷰 추가 및 설정
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

        // 습관 편집을 위한 롱 프레스 제스처 인식기 추가
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
        
        // 습관 추가 및 알림 테스트를 위한 네비게이션 바 버튼 추가
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addHabit))
        let testButton = UIBarButtonItem(title: "🔔", style: .plain, target: self, action: #selector(testNotification))
        navigationItem.rightBarButtonItems = [addButton, testButton]
        
        // 습관 목록 업데이트를 감지하는 노티피케이션 옵저버 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshHabits),
            name: Notification.Name("HabitListUpdated"),
            object: nil
        )
    }
    
    /// 저장소에서 습관 목록을 다시 불러오고 테이블 뷰를 갱신함
    @objc func refreshHabits() {
        habits = HabitStorage.shared.load()
        tableView.reloadData()
    }
    
    /// 새로운 습관을 생성하기 위해 AddHabitViewController를 표시함
    @objc func addHabit() {
        let addVC = AddHabitViewController()
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
    
    // MARK: - UITableViewDataSource 메서드
    
    /// 테이블 뷰에 표시할 습관의 개수를 반환함
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }

    /// 주어진 인덱스 경로에 대한 셀을 구성하여 반환함
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let habit = habits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // 최근 7일간 성공률 계산
        let totalDays = 7
        let successDays = habit.checkedDates
            .compactMap { Habit.dateFormatter.date(from: $0) }
            .filter {
                let diff = Calendar.current.dateComponents([.day], from: $0, to: Date()).day ?? 0
                return diff >= 0 && diff < totalDays
            }
            .count
        let percentage = Int((Double(successDays) / Double(totalDays)) * 100)
        
        // 셀 텍스트에 습관 이름과 완료 퍼센트 표시
        cell.textLabel?.text = "\(habit.name) (\(percentage)%)"

        // 셀 이미지에 습관 색상 적용
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let circleImage = UIImage(systemName: "circle.fill", withConfiguration: config)
        cell.imageView?.image = circleImage
        cell.imageView?.tintColor = habit.color

        // 오늘 체크된 습관이면 체크마크 표시
        let today = Date()
        cell.accessoryType = habit.isChecked(for: today) ? .checkmark : .none

        return cell
    }
    
    // MARK: - UITableViewDelegate 메서드
    
    /// 습관 셀 선택 시 오늘의 체크 상태를 토글함
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let today = Date()
        var habit = habits[indexPath.row]
        habit = habit.toggled(for: today)
        habits[indexPath.row] = habit

        HabitStorage.shared.save(habits)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    /// 습관 셀을 길게 눌렀을 때 해당 습관을 편집할 수 있도록 처리
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
    
    /// 알림 기능을 확인하기 위해 10초 후 테스트 알림을 전송함
    @objc func testNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This notification arrives after 10 seconds."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Notification registration failed: \(error)")
            } else {
                print("Test notification registered successfully.")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension ViewController: UNUserNotificationCenterDelegate {
    /// 앱이 포그라운드 상태일 때 알림 표시를 처리함
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

// MARK: - CalendarHostController
/// SwiftUI 캘린더 뷰를 호스팅하는 뷰 컨트롤러
class CalendarHostController: UIViewController {
    private var hostingController: UIHostingController<CalendarView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        view.backgroundColor = .systemBackground

        // "HabitListUpdated" 노티피케이션을 감지하여 캘린더 뷰 갱신
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshCalendarView),
            name: Notification.Name("HabitListUpdated"),
            object: nil
        )
        
        // 최초 캘린더 뷰 삽입
        embedCalendarView()
    }

    /// 최신 습관 데이터를 반영하여 CalendarView를 삽입 또는 갱신
    @objc private func embedCalendarView() {
        // 기존 호스팅 컨트롤러 제거
        if let hostingController = hostingController {
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }

        // 최신 습관 데이터를 불러와 CalendarView에 전달 (필요시)
        // 여기서는 CalendarView 초기화 시점에 최신 데이터를 반영하도록 가정
        let calendarView = CalendarView()

        // 새로운 호스팅 컨트롤러 생성 및 추가
        let newHostingController = UIHostingController(rootView: calendarView)
        addChild(newHostingController)
        newHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newHostingController.view)
        NSLayoutConstraint.activate([
            newHostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            newHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newHostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        newHostingController.didMove(toParent: self)
        hostingController = newHostingController
    }

    /// 노티피케이션 수신 시 캘린더 뷰 갱신
    @objc private func refreshCalendarView() {
        embedCalendarView()
    }
}
