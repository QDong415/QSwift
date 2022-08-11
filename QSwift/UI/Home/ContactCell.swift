//
//  ContactCell.swift
//  SwiftHub
//
//  Created by Khoren Markosyan on 1/15/19.
//  Copyright © 2019 Khoren Markosyan. All rights reserved.
//

import UIKit
import Kingfisher

class ContactCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(model: UserSimpleModel) {
        nameLabel.text = model.name
        avatarImageView.setImageWithURLString(fileUrlString(model.avatar), placeholderImage: UIImage(named: "user_photo"))
    }
    
    //系统经常会连续回调两次layoutSubviews
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}
