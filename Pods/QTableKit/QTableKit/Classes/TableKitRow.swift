//
//  QAlertViewController
//
//  Created by QDong on 2021-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

import UIKit

open class TableKitRow<TableViewCell: TableKitCellDataSource>: Row where TableViewCell: UITableViewCell {
    
    public let dataModel: TableViewCell.CellDataT //Cell对应的Model
    
    private lazy var actions = [String: [TableRowAction<TableViewCell>]]()
    
    open var reuseIdentifier: String {
        return TableViewCell.reuseIdentifier
    }
    
    open var estimatedHeight: CGFloat? {
        return TableViewCell.estimatedHeight
    }
    
    open var defaultHeight: CGFloat? {
        return TableViewCell.defaultHeight
    }
    
    open var cellType: AnyClass {
        return TableViewCell.self
    }
    
    public init(item: TableViewCell.CellDataT, actions: [TableRowAction<TableViewCell>]? = nil) {
        
        self.dataModel = item
        actions?.forEach { addAction($0) }
    }
    
    // MARK: - RowConfigurable
    open func configure(_ cell: UITableViewCell) {
        
        (cell as? TableViewCell)?.configureData(with: dataModel ,customRowAction: self)
    }
    
    // MARK: - RowActionable
    open func invoke(action: TableRowActionType, cell: UITableViewCell?, path: IndexPath?, userInfo: [AnyHashable: Any]? = nil) -> Any? {
        //这个方法调用非常频繁
        return actions[action.key]?.compactMap({ $0.invokeActionOn(cell: cell, item: dataModel, path: path, userInfo: userInfo) }).last
    }
    
    open func has(action: TableRowActionType) -> Bool {
        return actions[action.key] != nil
    }

    open func onCustomerAction(customActionKey: String, cell: UITableViewCell , path: IndexPath?, userInfo: [AnyHashable: Any]? = nil) {
        _ = invoke(action: .custom(customActionKey), cell: cell, path: path, userInfo: userInfo)
    }
    
    // MARK: - actions -
    
    @discardableResult
    open func addAction(_ action: TableRowAction<TableViewCell>) -> Self {

        if actions[action.type.key] == nil {
            actions[action.type.key] = [TableRowAction<TableViewCell>]()
        }
        actions[action.type.key]?.append(action)
        
        return self
    }

    @discardableResult
    open func addAction<T>(_ type: TableRowActionType, handler: @escaping (_ options: TableRowActionCallback<TableViewCell>) -> T) -> Self {
        
        return addAction(TableRowAction<TableViewCell>(type, handler: handler))
    }
    
    @discardableResult
    open func addAction(_ key: String, handler: @escaping (_ options: TableRowActionCallback<TableViewCell>) -> ()) -> Self {
        
        return addAction(TableRowAction<TableViewCell>(.custom(key), handler: handler))
    }

    open func removeAllActions() {
        
        actions.removeAll()
    }
    
    open func removeAction(forActionId actionId: String) {

        for (key, value) in actions {
            if let actionIndex = value.firstIndex(where: { $0.id == actionId }) {
                actions[key]?.remove(at: actionIndex)
            }
        }
    }

}
