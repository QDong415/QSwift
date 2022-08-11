//
//  ContactCell.swift
//  SwiftHub
//
//  Created by Khoren Markosyan on 1/15/19.
//  Copyright © 2019 Khoren Markosyan. All rights reserved.
//

import UIKit
import Kingfisher

class TopicCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
//    override func awakeFromNib() {
//        print("TopicCell awakeFromNib")
//        super.awakeFromNib()
//    }
//
//    deinit {
//        print("TopicCell deinit")
//    }
    
    //为了使用systemLayoutSizeFitting自动计算Cell高度，我们在xib里拉好约束后，还需要设置可变高度label的maxWidth
    //方案1：在xib里把label的DesireWidth设置为auto。就不用写代码了
    //方案2：用代码设置preferredMaxLayoutWidth。个人感觉效率应该会比方案1的auto要快。
    func setLabelPreferredMaxLayoutWidth(cellWith: CGFloat) {
        contentLabel.preferredMaxLayoutWidth = cellWith - contentLabel.frame.minX - 12 // 12是marginRight，要和xib里约束一致
    }
    
    //设置数据，onlyForGetHeight ：只设置会影响Cell高度的数据，以方便systemLayoutSizeFitting算Cell高度
    func setData(model: TopicModel, _ onlyForGetHeight: Bool = false) {
        
        if !onlyForGetHeight {
            //如果只是为了计算estimatedHeightForRowAt，就不走这些无用代码了
            nameLabel.text = model.name
            
            let url = URL(string: QINIU_URL + (model.avatar ?? ""))
            avatarImageView.setImageWithURL(url, placeholderImage: UIImage(named: "user_photo"), options: [
                .transition(.fade(1))
            ])
        }
        
        contentLabel.text = model.content
    }
}
