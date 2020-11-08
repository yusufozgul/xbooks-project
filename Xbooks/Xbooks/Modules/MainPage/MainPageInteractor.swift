//
//  MainPageInteractor.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 6.11.2020.
//

import Foundation

enum MainPageCollectionModel: Hashable {
    case nowReadingBook(MainPageDataModel)
    case suggestedBooks(MainPageDataModel)
    case summaryReports(SummaryReportDataModel)
}

struct SummaryReportDataModel: Hashable {
    static func == (lhs: SummaryReportDataModel, rhs: SummaryReportDataModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id = UUID()
    var data = ReadingManager.shared.userData.readingData ?? []
}

struct MainPageDataModel: Hashable, Codable {
    let id = UUID()
    let bookName: String
    let author: String
    let explanation: String
    let bookImageURL: URL
    let bookURL: String
    let bookDetailURL: String
    let bookCost: Int
}

protocol MainPageInteractorInterface {
    func getNowReadingBook()
    func getSuggestedBooks()
    func getSummaryReportData()
}

class MainPageInteractor {
    weak var output: MainPageInteractorOutput?
    
    init() {
        ReadingManager.shared.get()
    }
}

//MARK: - MainPageInteractorInterface
extension MainPageInteractor: MainPageInteractorInterface {
    func getNowReadingBook() {
        if let currentBook = ReadingManager.shared.userData.currentBook {
            let book: MainPageDataModel = MainPageDataModel(bookName: currentBook.name, author: "", explanation: currentBook.description, bookImageURL: URL(string: "https://google.com")!, bookURL: "", bookDetailURL: "", bookCost: 0)
            output?.handleNowReadingBook(result: .success(book))
        }
    }
    
    func getSuggestedBooks() {
        ApiService<GenericResponse<[MainPageDataModel]>>().getData(request: GetBooksRequest()) { (result) in
            switch result {
            case .success(let data):
                if data.data != nil {
                    self.output?.handleSuggestedBooks(result: .success(data.data!))
                } else {
                    print(data.message)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getSummaryReportData() {
        output?.handleSummaryReportData(result: .success([SummaryReportDataModel(), SummaryReportDataModel()]))
    }
}

struct GetBooksRequest: ApiRequestProtocol {
    var method: HttpMethod
    var url: String
    var body: Encodable?
        
    init() {
        method = .GET
        url = Constant.baseUrl + "book"
        body = nil
    }
}
