//
//  MainPagePresenter.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 6.11.2020.
//

import Foundation
import UIKit.NSDiffableDataSourceSectionSnapshot

typealias MainPageSnapshot = NSDiffableDataSourceSnapshot<MainPageVCSections, MainPageCollectionModel>


protocol MainPagePresenterInterface {
    func load()
    func tappedCell(at indexPath: IndexPath)
}

protocol MainPageInteractorOutput: class {
    func handleNowReadingBook(result: Result<MainPageDataModel, Error>)
    func handleSuggestedBooks(result: Result<[MainPageDataModel], Error>)
    func handleSummaryReportData(result: Result<[SummaryReportDataModel], Error>)
}

class MainPagePresenter {
    private weak var view: MainPageVCInterface?
    private var interactor: MainPageInteractorInterface!
    private var router: MainPageRouterInterface!
    private(set) var snapshot: MainPageSnapshot!
    
    private(set) var nowReading: MainPageDataModel?
    private var suggestedBooks: [MainPageDataModel] = []
    
    init(view: MainPageVCInterface, interactor: MainPageInteractorInterface, router: MainPageRouterInterface, snapshot: MainPageSnapshot = MainPageSnapshot()) {
        self.view = view
        self.interactor = interactor
        self.router = router
        
        self.snapshot = snapshot
        self.snapshot.appendSections([.nowReading, .suggestedBooks, .reports])
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "DATA_GETTED"), object: nil, queue: .main) { (_) in
            self.interactor.getNowReadingBook()
            self.interactor.getSummaryReportData()
        }
    }
}

// MARK: - MainPagePresenterInterface
extension MainPagePresenter: MainPagePresenterInterface {
    func load() {
        view?.prepareView()
        view?.configureCollectionView()
        interactor.getNowReadingBook()
        interactor.getSuggestedBooks()
        interactor.getSummaryReportData()
    }
    
    func tappedCell(at indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let book = nowReading {
                router.goNowReading(bookPath: book.bookURL)
            }
        } else if indexPath.section == 1 {
            router.goBookDetail(book: suggestedBooks[indexPath.item])
        }
    }
}

// MARK: - MainPageInteractorOutput
extension MainPagePresenter: MainPageInteractorOutput {
    func handleNowReadingBook(result: Result<MainPageDataModel, Error>) {
        switch result {
        case .success(let book):
            self.nowReading = book
            self.snapshot.deleteItems(self.snapshot.itemIdentifiers(inSection: .nowReading))
            self.snapshot.appendItems([.nowReadingBook(book)], toSection: .nowReading)
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
    
    func handleSummaryReportData(result: Result<[SummaryReportDataModel], Error>) {
        switch result {
        case .success(let data):
            self.snapshot.deleteItems(self.snapshot.itemIdentifiers(inSection: .reports))
            data.forEach({ self.snapshot.appendItems([.summaryReports($0)], toSection: .reports) })
            view?.updateCollectionView(with: snapshot)
        case .failure(let error):
            view?.showError(errorDescription: error.localizedDescription)
        }
    }
}
