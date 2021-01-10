//
//  Downloader.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 12.12.2020.
//

import Foundation

class FileDownloader {
    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: {
                data, response, error in
                if error == nil {
                    if let data = data {
                        if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic) {
                            completion(destinationUrl.path, error)
                        } else {
                            completion(destinationUrl.path, error)
                        }
                    } else {
                        completion(destinationUrl.path, error)
                    }
                } else {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
}
