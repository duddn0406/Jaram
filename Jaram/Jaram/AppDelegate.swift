import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("🔔 알림 권한 허용됨")
            } else {
                print("🚫 알림 권한 거부됨")
            }
        }

        let window = UIWindow(frame: UIScreen.main.bounds)

        let listVC = ViewController()
        listVC.title = "습관 목록"
        let nav1 = UINavigationController(rootViewController: listVC)
        nav1.tabBarItem = UITabBarItem(title: "목록", image: UIImage(systemName: "list.bullet"), tag: 0)

        let calendarVC = CalendarHostController()
        calendarVC.title = "캘린더"
        let nav2 = UINavigationController(rootViewController: calendarVC)
        nav2.tabBarItem = UITabBarItem(title: "캘린더", image: UIImage(systemName: "calendar"), tag: 1)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nav1, nav2]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    // MARK: UIScene 세션 생명주기

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "기본 구성", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}
