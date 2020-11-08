//
//  LibraryPageRouter.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import UIKit

protocol LibraryPageRouterInterface {
    func goBookDetail(book: MainPageDataModel)
    func goAuthorDetail(authorID: String)
}

class LibraryPageRouter {
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    static func createModule(navigationController: UINavigationController?) -> LibraryPageVC {
        let view = LibraryPageVC()
        let interactor = LibraryPageInteractor()
        let router = LibraryPageRouter(navigationController: navigationController)
        let presenter = LibraryPagePresenter(view: view,
                                           interactor: interactor,
                                           router: router)
        interactor.output = presenter
        view.presenter = presenter
        return view
    }
}

//MARK: - LibraryPageRouterInterface
extension LibraryPageRouter: LibraryPageRouterInterface {
    func goAuthorDetail(authorID: String) {
        
    }
    func goBookDetail(book: MainPageDataModel) {
        let vc = BookDetailVC(bookDetail: book, allowBookAddToProfile: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
