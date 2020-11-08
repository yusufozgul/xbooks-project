//
//  ProfilePageRouter.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import UIKit

protocol ProfilePageRouterInterface {
    func goBookDetail(bookID: String)
    func goReports()
    func goUpdateProfile()
}

class ProfilePageRouter {
    var navigationController: UINavigationController?
    var readinfView: ReadingView?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    static func createModule(navigationController: UINavigationController?) -> ProfilePageVC {
        let view = ProfilePageVC()
        let interactor = ProfilePageInteractor()
        let router = ProfilePageRouter(navigationController: navigationController)
        let presenter = ProfilePagePresenter(view: view,
                                           interactor: interactor,
                                           router: router)
        interactor.output = presenter
        view.presenter = presenter
        return view
    }
}

//MARK: - MainPageRouterInterface
extension ProfilePageRouter: ProfilePageRouterInterface {
    func goBookDetail(bookID: String) {
        
    }
    
    func goReports() {
        
    }
    
    func goUpdateProfile() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "ProfileUpdate")
        navigationController?.pushViewController(vc, animated: true)
    }
}

