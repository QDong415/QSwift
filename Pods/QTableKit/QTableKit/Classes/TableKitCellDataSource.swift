//
//  QAlertViewController
//
//  Created by QDong on 2021-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

import UIKit

public protocol TableKitCellDataSource {

    associatedtype CellDataT
    
    static var reuseIdentifier: String { get }
    static var estimatedHeight: CGFloat? { get }
    static var defaultHeight: CGFloat? { get }

    func configureData(with _: CellDataT ,customRowAction : RowActionable)
    
}

//缺省的实现
public extension TableKitCellDataSource where Self: UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var estimatedHeight: CGFloat? {
        return nil
    }
    
    static var defaultHeight: CGFloat? {
        return nil
    }
    
}
