//
//  LocalNewsTableViewCell.swift
//  Zeelben_Shekhaliya_FE_8939147
//
//  Created by Zeel Shekhaliya on 2023-12-07.
//

import UIKit

class LocalNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        bgView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        descriptionLabel.sizeToFit()
        
        let labelIntrinsicHeight = descriptionLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        bgView.frame.size.height = labelIntrinsicHeight + 32 // Add padding as needed
      
        // Configure the view for the selected state
    }
    
}
