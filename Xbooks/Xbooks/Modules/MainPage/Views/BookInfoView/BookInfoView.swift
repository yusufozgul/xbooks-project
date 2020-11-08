//
//  BookInfoView.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 6.11.2020.
//

import UIKit

class BookInfoView: UICollectionViewCell {
    static let reuseIdentifier: String = "BookInfoView"
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setView(title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }

}
