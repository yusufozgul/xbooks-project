//
//  BookDetailVC.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import UIKit
import WebKit

class BookDetailVC: UIViewController {
    var bookDetail: MainPageDataModel!
    var allowBookAddToProfile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        if let link = URL(string: bookDetail.bookDetailURL) {
            let request = URLRequest(url: link)
            webView.load(request)
        }
        
        if allowBookAddToProfile {
            let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(getBook))
            navigationItem.setRightBarButton(button, animated: true)
        }
    }
    
    convenience init(bookDetail: MainPageDataModel, allowBookAddToProfile: Bool = false){
        self.init()
        self.bookDetail = bookDetail
        self.allowBookAddToProfile = allowBookAddToProfile
    }
    
    @objc
    func getBook() {
        let alert = UIAlertController(title: "Kitabı alıyorsunuz", message: "Bu kitabı almak için hesabınızdaki \(bookDetail.bookCost) puan kullanılacaktır. Emin misiniz", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Tamam", style: .default) { [self] (_) in
            if ReadingManager.shared.userData.userTotalPoint ?? 0 < self.bookDetail.bookCost {
                let errorAlert = UIAlertController(title: "Üzgünüz", message: "Bu kitabı alabilmek için hesabınızda yeteri kadar puan bulunmamaktadır.", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Kapat", style: .default) { (_) in
                    
                }
                errorAlert.addAction(cancel)
                self.present(errorAlert, animated: true)
            } else {
                downloadAndSaveBook()
            }
        }
        let cancel = UIAlertAction(title: "İptal", style: .default) { (_) in
            
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    func downloadAndSaveBook() {
        guard let url = URL(string: bookDetail.bookURL) else { return }
        let alert = UIAlertController(title: "", message: "Kitap İndiriliyor", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        FileDownloader.loadFileAsync(url: url) { (filePath, error) in
            DispatchQueue.main.async {
                alert.dismiss(animated: true, completion: nil)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if error != nil {
                    let errorAlert = UIAlertController(title: "Hata", message: "Kitap indirilirken bir hata oluştu", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Kapat", style: .default) { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }
                    let reTry = UIAlertAction(title: "Tekrar dene", style: .default) { (_) in
                        self.downloadAndSaveBook()
                        return
                    }
                    errorAlert.addAction(cancel)
                    errorAlert.addAction(reTry)
                    self.present(errorAlert, animated: true)
                } else {
                    self.saveBook(bookPath: filePath ?? "")
                }
            }
            
        }
    }
    
    func saveBook(bookPath: String) {
        ReadingManager.shared.userData.currentBook = CurrentBookData(bookURL: bookPath,
                                                                     bookImageUrl: bookDetail.bookImageURL.absoluteString,
                                                                     bookDetailURL: bookDetail.bookDetailURL,
                                                                     description: bookDetail.explanation,
                                                                     name: bookDetail.bookName,
                                                                     totalDuration: 0,
                                                                     totalPoint: 0)
        ReadingManager.shared.userData.readedBooks = ReadingManager.shared.userData.readedBooks ?? []
        ReadingManager.shared.userData.readedBooks?.append(ReadedBookData(bookURL: bookDetail.bookURL,
                                                                          bookImageUrl: bookDetail.bookImageURL.absoluteString,
                                                                          bookDetailURL: bookDetail.bookDetailURL,
                                                                          description: bookDetail.explanation,
                                                                          name: bookDetail.bookName))
        ReadingManager.shared.userData.userTotalPoint = ReadingManager.shared.userData.userTotalPoint ?? 0
        ReadingManager.shared.userData.userTotalPoint! -= self.bookDetail.bookCost
        ReadingManager.shared.save()
        let successAlert = UIAlertController(title: "Teşekkürler", message: "Kitabınızı ana sayfaya dönüp okuyabilirsiniz :), ayrıca profilinizden bu kitabınızı ve eski kitaplarınızı görüntüleyebilirsiniz.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Kapat", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        successAlert.addAction(cancel)
        self.present(successAlert, animated: true)
    }
}
