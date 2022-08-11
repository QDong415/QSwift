//
//  静态的TableKitCell.swift
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 285275534@qq.com All rights reserved.

import UIKit
import QTableKit

//触发cell内部控件的事件的key；用来区分是哪个内部事件
let TKSwitchValueChangedKey = "TKSwitchValueChangedKey"

//左label，右uiSwitch
class TableKitSwitchCell: UITableViewCell, TableKitCellDataSource {
    
    //声明该cell对应的model数据类型；你可以不用写这句，选择直接把下文中的T换成Model；也能运行但是那样不规范
    typealias T = TableKitSwitchModel
    
    //主model是在TableKitRow里强引用的，这里只是个副本
    private weak var weakModel: T!
    
    //当用户手动触发cell上的UI控件的各种事件
    //底层原理：把事件通过这个RowActionable回调给TableKitRow；然后TableKitRow收到回调后，再回调给vc的TableRowAction
    private var customRowAction: RowActionable?
    
    //cell上的控件
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var uiSwitch: UISwitch!
    
    //MARK: TableKitCellDataSource - 默认高度
    //这里的默认高度是第2优先级，如果在ViewController里设置本Cell高度属于第1优先级
    static var defaultHeight: CGFloat? {
        //返回0表示Cell高度为0，不写该方法表示Cell高度为automaticDimension
        return 54
    }
    
    //MARK: TableKitCellDataSource - 绑定model 和 临时存储customRowAction
    //这个回调方法是由系统的cellForRowAtIndexPath触发的，所以要写的内容就跟cellForRowAtIndexPath一样
    func configureData(with tkModel: T ,customRowAction : RowActionable) {
        
        self.weakModel = tkModel
        self.customRowAction = customRowAction
        
        titleLabel.text = tkModel.title
        uiSwitch.isOn = tkModel.isOn
        
        uiSwitch.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }
    
    //cell内部控件触发的事件，通过本cell的全局变量customRowAction传给TableKitRow，TableKitRow会再传回给vc
    @objc fileprivate func valueChanged(_ uiSwitch:UISwitch) {
        // 控件输入监听，监听cell上的UI控件的output值的改变，然后把新值设置回weakModel
        weakModel.isOn = uiSwitch.isOn;
        customRowAction?.onCustomerAction(customActionKey: TKSwitchValueChangedKey, cell: self, path: nil, userInfo: nil)
    }

}
