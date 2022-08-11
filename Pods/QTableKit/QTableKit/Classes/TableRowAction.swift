//
//  QAlertViewController
//
//  Created by QDong on 2021-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

import UIKit

open class TableRowActionCallback<TableViewCell: TableKitCellDataSource> where TableViewCell: UITableViewCell {

    public let dataModel: TableViewCell.CellDataT
    public let cell: TableViewCell?
    public let indexPath: IndexPath?
    public let userInfo: [AnyHashable: Any]?

    init(item: TableViewCell.CellDataT, cell: TableViewCell?, path: IndexPath?, userInfo: [AnyHashable: Any]?) {

        self.dataModel = item
        self.cell = cell
        self.indexPath = path
        self.userInfo = userInfo
    }
}

private enum TableRowActionHandler<TableViewCell: TableKitCellDataSource> where TableViewCell: UITableViewCell {

    case voidAction((TableRowActionCallback<TableViewCell>) -> Void)
    case action((TableRowActionCallback<TableViewCell>) -> Any?)

    func invoke(withOptions options: TableRowActionCallback<TableViewCell>) -> Any? {
        
        switch self {
        case .voidAction(let handler):
            return handler(options)
        case .action(let handler):
            return handler(options)
        }
    }
}

open class TableRowAction<CellType: TableKitCellDataSource> where CellType: UITableViewCell {

    open var id: String?
    public let type: TableRowActionType
    private let handler: TableRowActionHandler<CellType>
    
    public init(_ type: TableRowActionType, handler: @escaping (_ options: TableRowActionCallback<CellType>) -> Void) {

        self.type = type
        self.handler = .voidAction(handler)
    }
    
    public init(_ key: String, handler: @escaping (_ options: TableRowActionCallback<CellType>) -> Void) {
        
        self.type = .custom(key)
        self.handler = .voidAction(handler)
    }
    
    public init<T>(_ type: TableRowActionType, handler: @escaping (_ options: TableRowActionCallback<CellType>) -> T) {

        self.type = type
        self.handler = .action(handler)
    }

    public func invokeActionOn(cell: UITableViewCell?, item: CellType.CellDataT, path: IndexPath?, userInfo: [AnyHashable: Any]?) -> Any? {

        return handler.invoke(withOptions: TableRowActionCallback(item: item, cell: cell as? CellType, path: path, userInfo: userInfo))
    }

}
