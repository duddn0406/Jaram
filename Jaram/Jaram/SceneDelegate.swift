//
//  SceneDelegate.swift
//  Jaram
//
//  Created by fourword on 6/11/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

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

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // 씬이 시스템에 의해 해제될 때 호출됩니다.
        // 이는 씬이 백그라운드로 들어가거나 세션이 폐기된 직후에 발생합니다.
        // 씬이 다시 연결될 때 재생성할 수 있는 리소스를 해제하세요.
        // 씬의 세션이 반드시 폐기된 것은 아니기 때문에 나중에 다시 연결될 수도 있습니다 (application:didDiscardSceneSessions 참조).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 씬이 비활성 상태에서 활성 상태로 전환될 때 호출됩니다.
        // 이 메서드를 사용하여 씬이 비활성 상태일 때 일시 중지되었거나 아직 시작하지 않은 작업을 다시 시작하세요.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 씬이 활성 상태에서 비활성 상태로 전환될 때 호출됩니다.
        // 이는 일시적인 중단(예: 전화 수신)으로 인해 발생할 수 있습니다.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 씬이 백그라운드에서 포그라운드로 전환될 때 호출됩니다.
        // 이 메서드를 사용하여 백그라운드 진입 시 수행한 변경 사항을 되돌리세요.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 씬이 포그라운드에서 백그라운드로 전환될 때 호출됩니다.
        // 데이터를 저장하고, 공유 리소스를 해제하며, 씬의 상태 정보를 저장하여
        // 씬을 현재 상태로 복원할 수 있도록 하세요.
    }


}
