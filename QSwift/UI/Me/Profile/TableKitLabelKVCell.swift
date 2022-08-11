//
//  静态的TableKitCell.swift
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 285275534@qq.com All rights reserved.

import UIKit
import QTableKit

//左label
class TableKitLabelKVCell: UITableViewCell, TableKitCellDataSource {
    
    //声明该cell对应的model数据类型；你可以不用写这句，选择直接把下文中的T换成Model；也能运行但是那样不规范
    typealias T = TableKitLabelKVModel

    //cell上的控件
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    //MARK: TableKitCellDataSource - 绑定model
    //这个回调方法是由系统的cellForRowAtIndexPath触发的，所以要写的内容就跟cellForRowAtIndexPath一样
    func configureData(with tkModel: T ,customRowAction : RowActionable) {
        
        titleLabel.text = tkModel.title
        valueLabel.text = tkModel.value
    }
    
    deinit {
        print("TableKitLabelXibAutoCell deinitialized")
    }
}
