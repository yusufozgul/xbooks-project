//
//  MainTabBar.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import UIKit

class MainTabbar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHomeTab()
        loadLibraryTab()
        loadProfileTab()
    }
}

extension MainTabbar {
    func loadHomeTab() {
        let navigationController = UINavigationController()
        let homeView = MainPageRouter.createModule(navigationController: navigationController)
        navigationController.viewControllers.append(homeView)
        navigationController.tabBarItem.image = UIImage(systemName: "book.fill")
        navigationController.tabBarItem.title = "Okuma"
        self.addChild(navigationController)
    }
    
    func loadLibraryTab() {
        let navigationController = UINavigationController()
        let libraryView = LibraryPageRouter.createModule(navigationController: navigationController)
        navigationController.viewControllers.append(libraryView)
        navigationController.tabBarItem.image = UIImage(systemName: "books.vertical.fill")
        navigationController.tabBarItem.title = "Kitaplık"
        self.addChild(navigationController)
    }
    
    func loadProfileTab() {
        let navigationController = UINavigationController()
        let libraryView = ProfilePageRouter.createModule(navigationController: navigationController)
        navigationController.viewControllers.append(libraryView)
        navigationController.tabBarItem.image = UIImage(systemName: "person.fill")
        navigationController.tabBarItem.title = "Profil"
        self.addChild(navigationController)
    }
}
