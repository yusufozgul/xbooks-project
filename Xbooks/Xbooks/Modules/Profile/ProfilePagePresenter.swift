//
//  ProfilePagePresenter.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import Foundation
import UIKit.NSDiffableDataSourceSectionSnapshot

typealias ProfilePageSnapshot = NSDiffableDataSourceSnapshot<ProfilePageVCSections, ProfilePageCollectionModel>

protocol ProfilePagePresenterInterface {
    func load()
    func tappedCell(at indexPath: IndexPath)
    func updateProfile()
}

protocol ProfilePageInteractorOutput: class {
    func handleSuggestedBooks(result: Result<[MainPageDataModel], Error>)
    func handleSummaryReportData(result: Result<[SummaryReportDataModel], Error>)
}

class ProfilePagePresenter {
    private weak var view: ProfilePageVCInterface?
    private var interactor: ProfilePageInteractorInterface!
    private var router: ProfilePageRouterInterface!
    private(set) var snapshot: ProfilePageSnapshot!
    
    init(view: ProfilePageVCInterface, interactor: ProfilePageInteractorInterface, router: ProfilePageRouterInterface, snapshot: ProfilePageSnapshot = ProfilePageSnapshot()) {
        self.view = view
        self.interactor = interactor
        self.router = router
        
        self.snapshot = snapshot
        self.snapshot.appendSections([.userData, .suggestedBooks, .reports])
        self.snapshot.appendItems([.userData], toSection: .userData)
    }
}

// MARK: - MainPagePresenterInterface
extension ProfilePagePresenter: ProfilePagePresenterInterface {
    func load() {
        view?.prepareView()
        view?.configureCollectionView()
        interactor.getSuggestedBooks()
        interactor.getSummaryReportData()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "DATA_GETTED"), object: nil, queue: .main) { (_) in
            self.interactor.getSuggestedBooks()
            self.interactor.getSummaryReportData()
        }
    }
    
    func tappedCell(at indexPath: IndexPath) {
        if indexPath.item == 0 {
            
        }
    }
    
    func updateProfile() {
        router.goUpdateProfile()
    }
}

// MARK: - MainPageInteractorOutput
extension ProfilePagePresenter: ProfilePageInteractorOutput {
    func handleSuggestedBooks(result: Result<[MainPageDataModel], Error>) {
        switch result {
        case .success(let books):
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
