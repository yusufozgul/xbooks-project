//
//  ReadingView.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import UIKit
import FolioReaderKit

class ReadingView {
    let folioReader = FolioReader()
    var bookPath: String = ""
    let startReading: Date! = Date()
    let parentVC: UIViewController
    
    init(viewController: UIViewController, bookPath: String) {
        self.parentVC = viewController
        self.bookPath = bookPath
        self.folioReader.presentReader(parentViewController: viewController, withEpubPath: bookPath, andConfig: readerConfiguration(name: bookPath))
        self.folioReader.delegate = self
        self.folioReader.readerCenter?.delegate = self
        
    }
    
    private func readerConfiguration(name: String) -> FolioReaderConfig {
        let config = FolioReaderConfig(withIdentifier: name)
        config.allowSharing = false
        config.tintColor = .systemRed
         return config
     }

}

// MARK: - FolioReaderDelegate
extension ReadingView: FolioReaderDelegate, FolioReaderCenterDelegate {
    func folioReaderDidClose(_ folioReader: FolioReader) {
        let endReading = Date()
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.second], from: startReading, to: endReading)
        let seconds = dateComponents.second ?? 0
        
        var point = 0
        if seconds > 3600 {
            point += Int(Double(seconds / 60) * 1.2)
        } else {
            point += Int(seconds / 60)
        }
        var data = ReadingManager.shared.userData.readingData ?? []
        data.append(ReadingData(date: String(describing: Date()), duration: seconds, bookName: bookPath, point: point))
        
        let totalDuration = (ReadingManager.shared.userData.currentBook?.totalDuration ?? 0) + seconds
        var totalPoint: Int = ReadingManager.shared.userData.currentBook?.totalPoint ?? 0
        
        if totalDuration > 3600 {
            totalPoint += Int(Double(seconds / 60) * 1.2)
        } else {
            totalPoint += Int(seconds / 60)
        }
        
        ReadingManager.shared.userData.readingData = data
        ReadingManager.shared.userData.currentBook?.totalDuration = totalDuration
        ReadingManager.shared.userData.currentBook?.totalPoint = totalPoint + point
        ReadingManager.shared.userData.userTotalPoint = ReadingManager.shared.userData.userTotalPoint! + point
        ReadingManager.shared.save()
    }
    
    func folioReader(_ folioReader: FolioReader, error: Error) {
        parentVC.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: "Bir hata oluştu", message: "Hata mesajı: \(error.localizedDescription)", preferredStyle: .alert)
        let closeButton = UIAlertAction(title: "Kapat", style: .cancel) { (_) in
            self.parentVC.dismiss(animated: true, completion: nil)
        }
        alert.addAction(closeButton)
        self.parentVC.present(alert, animated: true, completion: nil)
    }
}
