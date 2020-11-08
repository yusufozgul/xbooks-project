//
//  ProfilePageInteractor.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import Foundation

enum ProfilePageCollectionModel: Hashable {
    case userData
    case suggestedBooks(MainPageDataModel)
    case summaryReports(SummaryReportDataModel)
}

protocol ProfilePageInteractorInterface {
    func getSuggestedBooks()
    func getSummaryReportData()
}

class ProfilePageInteractor {
    weak var output: ProfilePageInteractorOutput?
}

//MARK: - MainPageInteractorInterface
extension ProfilePageInteractor: ProfilePageInteractorInterface {
    func getSuggestedBooks() {
        
        var data: [MainPageDataModel] = []
        
        ReadingManager.shared.userData.readedBooks?.forEach({ book in
            data.append(MainPageDataModel(bookName: book.name,
                                               author: "",
                                               explanation: book.description,
                                               bookImageURL: URL(string: book.bookImageUrl) ?? URL(string: "https://google.com")!,
                                               bookURL: book.bookURL,
                                               bookDetailURL: book.bookDetailURL,
                                               bookCost: 0))
        })
        
        
        output?.handleSuggestedBooks(result: .success(data))
    }
    
    func getSummaryReportData() {
        output?.handleSummaryReportData(result: .success([SummaryReportDataModel(), SummaryReportDataModel()]))
    }
}
