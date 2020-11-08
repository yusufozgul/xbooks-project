//
//  MainPageRouter.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 6.11.2020.
//

import UIKit

protocol MainPageRouterInterface {
    func goNowReading()
    func goBookDetail(book: MainPageDataModel)
    func goReports()
}

class MainPageRouter {
    var navigationController: UINavigationController?
    var readinfView: ReadingView?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    static func createModule(navigationController: UINavigationController?) -> MainPageVC {
        let view = MainPageVC()
        let interactor = MainPageInteractor()
        let router = MainPageRouter(navigationController: navigationController)
        let presenter = MainPagePresenter(view: view,
                                           interactor: interactor,
                                           router: router)
        interactor.output = presenter
        view.presenter = presenter
        return view
    }
}

//MARK: - MainPageRouterInterface
extension MainPageRouter: MainPageRouterInterface {
    func goNowReading() {
        readinfView = ReadingView(viewController: navigationController!)
    }
    
    func goBookDetail(book: MainPageDataModel) {
        let vc = BookDetailVC(bookDetail: book, allowBookAddToProfile: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goReports() {
        
    }
}
