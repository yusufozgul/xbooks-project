//
//  NowReadingView.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 6.11.2020.
//

import UIKit

class NowReadingView: UICollectionViewCell {
    static let reuseIdentifier: String = "NowReadingView"
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var dailyPointLabel: UILabel!
    @IBOutlet weak var dailyPointLabelView: UIView!
    @IBOutlet weak var dailyReadingDurationView: UIView!
    @IBOutlet weak var dailyReadingDurationLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dailyPointLabelView.layer.cornerRadius = 5
        dailyReadingDurationView.layer.cornerRadius = 5
    }

    func configure(title: String, dailyPoint: String, dailyDuration: String) {
        bookName.text = title
        dailyPointLabel.text = dailyPoint
        dailyReadingDurationLabel.text = dailyDuration
    }
}
