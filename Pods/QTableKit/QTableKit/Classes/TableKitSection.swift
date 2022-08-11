//
//  QAlertViewController
//
//  Created by QDong on 2021-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

import UIKit

open class TableKitSection {

    open private(set) var rows = [Row]()
    
    open var headerTitle: String?
    open var footerTitle: String?
    open var indexTitle: String?
    
    open var headerView: UIView?
    open var footerView: UIView?
    
    open var headerHeight: CGFloat? = nil
    open var footerHeight: CGFloat? = nil
    
    open var numberOfRows: Int {
        return rows.count
    }
    
    open var isEmpty: Bool {
        return rows.isEmpty
    }
    
    public init(rows: [Row]? = nil) {
        
        if let initialRows = rows {
            self.rows.append(contentsOf: initialRows)
        }
    }
    
    public convenience init(headerTitle: String?, footerTitle: String?, rows: [Row]? = nil) {
        self.init(rows: rows)
        
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
    }
    
    public convenience init(headerView: UIView?, footerView: UIView?, rows: [Row]? = nil) {
        self.init(rows: rows)
        
        self.headerView = headerView
        self.footerView = footerView
    }

    // MARK: - Public -
    
    open func clear() {
        rows.removeAll()
    }
    
    open func append(row: Row) {
        append(rows: [row])
    }
    
    open func append(rows: [Row]) {
        self.rows.append(contentsOf: rows)
    }
    
    open func insert(row: Row, at index: Int) {
        rows.insert(row, at: index)
    }
    
    open func insert(rows: [Row], at index: Int) {
        self.rows.insert(contentsOf: rows, at: index)
    }

    open func replace(rowAt index: Int, with row: Row) {
        rows[index] = row
    }
    
    open func swap(from: Int, to: Int) {
        rows.swapAt(from, to)
    }
    
    open func delete(rowAt index: Int) {
        rows.remove(at: index)
    }
    
    open func remove(rowAt index: Int) {
        rows.remove(at: index)
    }

}
