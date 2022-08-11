//
//  静态的TableKitCell.swift
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 285275534@qq.com All rights reserved.

import UIKit
import QTableKit

//这个Cell对应的Model，尽量用class，尽量不要用struct；因为struct会在TableKitRow里产生一个无用的深copy
class TableKitButtonModel {
    var title: String?
    
    convenience init(title: String){
        self.init()
        self.title = title
    }
}

//触发cell内部控件的事件的key；为了在ViewController里区分是哪个内部事件
let TableKitSingleButtonClicked = "TableKitSingleButtonClicked" //按钮点击事件key

//这是只有一个Button的Cell
class TableKitSingleButtonCell: UITableViewCell, TableKitCellDataSource {

    //声明该cell对应的model数据类型；你可以不用写这句，选择直接把下文中的T换成Model；也能运行但是那样不规范
    typealias T = TableKitButtonModel

    //当用户手动触发cell上的UI控件的各种事件
    //底层原理：把事件通过这个RowActionable回调给TableKitRow；然后TableKitRow收到回调后，再回调给vc的TableRowAction
    private var customRowAction: RowActionable?
    
    //cell上的控件
    @IBOutlet weak var singleButton: UIButton!
    
    //MARK: TableKitCellDataSource - 高度
    //本Cell固定高度就用这个方法；
    static var defaultHeight: CGFloat? {
        return 104
    }
    
    //MARK: TableKitCellDataSource - 用来绑定model 和 临时存储customRowAction
    //这个回调方法是由系统的cellForRowAtIndexPath触发的，所以要写的内容就跟cellForRowAtIndexPath一样
    func configureData(with tkModel: T , customRowAction : RowActionable) {
        self.customRowAction = customRowAction
        singleButton.setTitle(tkModel.title, for: UIControl.State.normal)
        singleButton.addTarget(self, action: #selector(singleButtonClicked), for: .touchUpInside)
        selectionStyle = UITableViewCell.SelectionStyle.none
    }
    
    //cell内部控件触发的事件，通过本cell的全局变量customRowAction传给TableKitRow，TableKitRow会再传回给vc
    @IBAction private func singleButtonClicked(_ sender: UIButton) {
        customRowAction?.onCustomerAction(customActionKey: TableKitSingleButtonClicked, cell: self, path: nil, userInfo: nil)
    }
    
    //移除TableViewStyleGroup下的分割线
    override func addSubview(_ view: UIView) {
        if NSStringFromClass(type(of: view)) != "_UITableViewCellSeparatorView" {
            super.addSubview(view)
        }
    }
}
