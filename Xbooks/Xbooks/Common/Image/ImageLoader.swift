//
//  ImageLoader.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 6.11.2020.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.main.async {
            ImageCache.default.cleanExpiredDiskCache()
        }
        let options: KingfisherOptionsInfo = [.diskCacheExpiration(.days(3))]
        self.kf.setImage(with: url, options: options)
    }
}
