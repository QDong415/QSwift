//
//  MeTabCell.swift
//  QSwift
//
//  Created by QDong on 1/15/19.
//  Copyright © 2019 285275534@qq.com All rights reserved.
//

import UIKit
import QTableKit

//这个Cell对应的Model，尽量用class，尽量不要用struct；因为struct会在TableKitRow里产生一个无用的复制
class MeTabModel {
    var imageName: String?
    var title: String?
    var right: String?
    
    convenience init(imageName: String ,title: String ,right: String = ""){
        self.init()
        self.imageName = imageName
        self.title = title
        self.right = right
    }
}

//“我的”tab上的的每栏cell
class MeTabCell: UITableViewCell ,TableKitCellDataSource {

    //你可以不用写这句，而是直接把下文中的T换成Model；但是那样不规范
    typealias T = MeTabModel
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        if #available(iOS 11.0, *) {//适配黑夜模式
            bgView.backgroundColor = UIColor(named: "cell")
            titleLabel.textColor = UIColor(named: "text_black_gray")
            rightLabel.textColor = UIColor(named: "text_black_gray")
        }
        super.awakeFromNib()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if #available(iOS 11.0, *) {
            bgView.backgroundColor = highlighted ? UIColor(named: "background") : UIColor(named: "cell")
        } else {
            bgView.backgroundColor = highlighted ? backgroundColor : UIColor.white
        }
    }
    
    //MARK: TableKitCellDataSource - 默认高度
    //这里的默认高度是第2优先级，如果在ViewController里设置本Cell高度属于第1优先级
    static var defaultHeight: CGFloat? {
        return 50
    }
    
    //MARK: TableKitCellDataSource - 绑定model 和 临时存储customRowAction
    //这个回调方法是由系统的cellForRowAtIndexPath触发的，所以要写的内容就跟cellForRowAtIndexPath一样
    func configureData(with tkModel: T , customRowAction : RowActionable) {
        iconImageView.image = UIImage(named: tkModel.imageName ?? "")
        titleLabel.text = tkModel.title
        rightLabel.text = tkModel.right
        bgView.layer.cornerRadius = 12
    }

}
