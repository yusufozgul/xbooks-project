//
//  ReadingManager.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import Foundation

class ReadingManager {
    static let shared: ReadingManager = ReadingManager()
    var userData = UserData()
    
    init() {
        get()
    }
    
    func save() {
        let req = SetDailyReadingDataRequest(data: userData)
        ApiService<GenericResponse<String>>().getData(request: req) { (result) in
            switch result {
            case .success(let data):
                print(data.message)
            case .failure(let error):
                print(error.localizedDescription)
            }
            self.get()
        }
    }
    
    func get() {
        let req = GetDailyReadingDataRequest()
        ApiService<GenericResponse<UserData>>().getData(request: req) { (result) in
            switch result {
            case .success(let data):
                if data.data != nil {
                    self.userData = data.data!
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DATA_GETTED"), object: nil)
                }
                print(data.message)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct GetDailyReadingDataRequest: ApiRequestProtocol {
    var method: HttpMethod
    var url: String
    var body: Encodable?
        
    init() {
        method = .GET
        url = Constant.baseUrl + "userData"
        body = nil
    }
}

struct SetDailyReadingDataRequest: ApiRequestProtocol {
    var method: HttpMethod
    var url: String
    var body: Encodable?
        
    init(data: Encodable) {
        method = .POST
        url = Constant.baseUrl + "userDataSave"
        body = data
    }
}

struct UserData: Codable {
    var currentBook: CurrentBookData?
    var readingData: [ReadingData]?
    var readedBooks: [ReadedBookData]?
    var userTotalPoint: Int?
}

struct CurrentBookData: Codable {
    var bookURL: String
    var bookImageUrl: String
    var bookDetailURL: String
    var description: String
    var name: String
    var totalDuration: Int
    var totalPoint: Int
}

struct ReadedBookData: Codable {
    var bookURL: String
    var bookImageUrl: String
    var bookDetailURL: String
    var description: String
    var name: String
}

struct ReadingData: Codable, Hashable {
    var date: String
    var duration: Int
    var bookName: String
    var point: Int
}
