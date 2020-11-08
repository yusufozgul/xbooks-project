//
//  ProfileInfoCell.swift
//  Xbooks
//
//  Created by Yusuf Özgül on 7.11.2020.
//

import UIKit

class ProfileInfoCell: UICollectionViewCell {
    static let reuseIdentifier: String = "ProfileInfoCell"
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalPoint: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(name: String, totalPoint: String) {
        nameLabel.text = name
        self.totalPoint.text = totalPoint
    }
}
