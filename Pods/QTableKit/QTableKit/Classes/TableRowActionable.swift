//
//  QAlertViewController
//
//  Created by QDong on 2021-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

import UIKit


public protocol RowActionable {
    
    func invoke(
        action: TableRowActionType,
        cell: UITableViewCell?,
        path: IndexPath?,
        userInfo: [AnyHashable: Any]?) -> Any?
    
    func has(action: TableRowActionType) -> Bool
    
    func onCustomerAction(customActionKey: String, cell: UITableViewCell, path: IndexPath?, userInfo: [AnyHashable: Any]?)
}


public protocol Row: RowActionable {
    
    var reuseIdentifier: String { get }
    var cellType: AnyClass { get }
    
    var estimatedHeight: CGFloat? { get }
    var defaultHeight: CGFloat? { get }
    
    func configure(_ cell: UITableViewCell)
}

public enum TableRowActionType {
    
    case click
    case height
    case custom(String)
    
    var key: String {
        
        switch (self) {
        case .custom(let key):
            return key
        default:
            return "_\(self)"
        }
    }
}
