//
//  LibraryPagePresenter.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import Foundation
import UIKit.NSDiffableDataSourceSectionSnapshot

typealias LibraryPageSnapshot = NSDiffableDataSourceSnapshot<LibraryPageVCSections, LibraryPageCollectionModel>

protocol LibraryPagePresenterInterface {
    func load()
    func tappedCell(at indexPath: IndexPath)
}

protocol LibraryPageInteractorOutput: class {
    func handleSuggestedBooks(result: Result<[MainPageDataModel], Error>)
    func handleSuggestedAuthorData(result: Result<[LibraryPageAuthorDataModel], Error>)
}

class LibraryPagePresenter {
    private weak var view: LibraryPageVCInterface?
    private var interactor: LibraryPageInteractorInterface!
    private var router: LibraryPageRouterInterface!
    private(set) var snapshot: LibraryPageSnapshot!
    
    private var suggestedBooks: [MainPageDataModel] = []
    
    init(view: LibraryPageVCInterface, interactor: LibraryPageInteractorInterface, router: LibraryPageRouterInterface, snapshot: LibraryPageSnapshot = LibraryPageSnapshot()) {
        self.view = view
        self.interactor = interactor
        self.router = router
        
        self.snapshot = snapshot
        self.snapshot.appendSections([.suggestedAuthor, .suggestedBooks])
    }
}

// MARK: - MainPagePresenterInterface
extension LibraryPagePresenter: MainPagePresenterInterface {
    func load() {
        view?.prepareView()
        view?.configureCollectionView()
        interactor.getSuggestedAuthorData()
        interactor.getSuggestedBooks()
    }
    
    func tappedCell(at indexPath: IndexPath) {
        if indexPath.section == 1 {
            router.goBookDetail(book: suggestedBooks[indexPath.item])
        }
    }
}

// MARK: - MainPageInteractorOutput
extension LibraryPagePresenter: LibraryPageInteractorOutput {
    func handleSuggestedAuthorData(result: Result<[LibraryPageAuthorDataModel], Error>) {
        switch result {
        case .success(let books):
            self.snapshot.deleteItems(self.snapshot.itemIdentifiers(inSection: .suggestedAuthor))
            books.forEach({ self.snapshot.appendItems([.suggestedAuthor($0)], toSection: .suggestedAuthor) })
            view?.updateCollectionView(with: snapshot)
        case .failure(let error):
            view?.showError(errorDescription: error.localizedDescription)
        }
    }
    
    func handleSuggestedBooks(result: Result<[MainPageDataModel], Error>) {
        switch result {
        case .success(let books):
            self.suggestedBooks = books
            self.snapshot.deleteItems(self.snapshot.itemIdentifiers(inSection: .suggestedBooks))
            books.forEach({ self.snapshot.appendItems([.suggestedBooks($0)], toSection: .suggestedBooks) })
            view?.updateCollectionView(with: snapshot)
        case .failure(let error):
            view?.showError(errorDescription: error.localizedDescription)
        }
    }
}
