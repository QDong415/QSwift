//
//  MeTabCell.swift
//  QSwift
//
//  Created by QDong on 1/15/19.
//  Copyright © 2019 285275534@qq.com All rights reserved.
//

import UIKit


//“我的”tab上的的Header
class MeTabHeaderCell: UITableViewCell  {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fansLabel: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        if #available(iOS 11.0, *) {//适配黑夜模式
            bgView.backgroundColor =  UIColor(named: "cell");
            nameLabel.textColor = UIColor(named: "black_white");
            fansLabel.textColor = UIColor(named: "text_black_gray");
            followLabel.textColor = UIColor(named: "text_black_gray");
        }
        super.awakeFromNib()
    }

}
