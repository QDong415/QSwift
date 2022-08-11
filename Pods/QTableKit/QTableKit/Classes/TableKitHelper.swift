//
//  QAlertViewController
//
//  Created by QDong on 2021-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

import Foundation
import UIKit

open class TableKitHelper: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private(set) open var tableKitSections = [TableKitSection]()
    
    //TableViewCell的自动注册器，在CellForRowAtIndexPath里发挥作用
    private var cellRegisterer: TableCellRegisterer?
    
    //“替补Delegate”。作用：如果本类没实现Delegate里的某个方法，可以让vc实现。
    private weak var alterTableViewDelegate: UITableViewDelegate?
    private weak var alterTableViewDataSource: UITableViewDataSource?
    
    convenience public init(tableView: UITableView ,alterTableViewDelegate: UITableViewDelegate? = nil, alterTableViewDataSource: UITableViewDataSource? = nil) {
        
        self.init()
        
        //注意这里一定要注意顺序：先写这两句，再设置tableview的delegate,dataSource
        self.alterTableViewDelegate = alterTableViewDelegate
        self.alterTableViewDataSource = alterTableViewDataSource
        
        tableView.delegate = self
        tableView.dataSource = self
        //系统走完上面两句tableView.delegate.dataSource = self，就会立刻回调responds。然后才继续往下走代码
        
        self.cellRegisterer = TableCellRegisterer(tableView: tableView)
    }
    
    //设置完delegate\dataSource会立刻触发到这里。我们要告诉系统要消化哪些delegate\dataSource的方法
    open override func responds(to selector: Selector) -> Bool {
        //如果 本类实现了Delegate or vc实现了Delegate，那么就由本类处理
        return super.responds(to: selector) || alterTableViewDelegate?.responds(to: selector) == true
             || alterTableViewDataSource?.responds(to: selector) == true
    }

    //如果本类就已经实现了delegate里的方法，那么压根就不会进入这里，我们没判断的机会
    open override func forwardingTarget(for selector: Selector) -> Any? {
        
        if alterTableViewDelegate?.responds(to: selector) == true  {
           //外部vc实现了delegate的方法，交给vc来处理
            return alterTableViewDelegate
            
        } else if alterTableViewDataSource?.responds(to: selector) == true  {
            //外部vc实现了dateSource的方法，交给vc来处理
             return alterTableViewDataSource
            
         } else {
            //目前尚不清楚什么情况下会走这里
            return super.forwardingTarget(for: selector)
        }
    }
    
    // MARK: - Private
    private func row(at indexPath: IndexPath) -> Row? {
        if indexPath.section < tableKitSections.count && indexPath.row < tableKitSections[indexPath.section].rows.count {
            return tableKitSections[indexPath.section].rows[indexPath.row]
        }
        return nil
    }
    
    @discardableResult
    private func invoke(
        action: TableRowActionType,
        cell: UITableViewCell?, indexPath: IndexPath,
        userInfo: [AnyHashable: Any]? = nil) -> Any? {
        guard let row = row(at: indexPath) else { return nil }
        return row.invoke(
            action: action,
            cell: cell,
            path: indexPath,
            userInfo: userInfo
        )
    }
    
    private func hasAction(_ action: TableRowActionType, atIndexPath indexPath: IndexPath) -> Bool {
        guard let row = row(at: indexPath) else { return false }
        return row.has(action: action)
    }
    
    // MARK: - Height
    // ios11系统的回调顺序是：第一步：先从0到count-1，全回调一次estimatedHeightForRowAt。ios10是相反的
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        let row = tableKitSections[indexPath.section].rows[indexPath.row]

        let rowHeight = invoke(action: .height, cell: nil, indexPath: indexPath) as? CGFloat

        //注意这里，由于swift的特性，即便是0，也会返回；只有nil才会走下面的??
        return rowHeight
            ?? row.defaultHeight
            ?? row.estimatedHeight
            ?? UITableView.automaticDimension
    }
    
    // ios11系统的回调顺序是：第二步：一个row回调1次cellForRowAt，然后回调3次heightForRowAt。ios10是相反的
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row = tableKitSections[indexPath.section].rows[indexPath.row]
   
        let rowHeight = invoke(action: .height, cell: nil, indexPath: indexPath) as? CGFloat

        //注意这里，由于swift的特性，即便是0，也会返回；只有nil才会走下面的??
        return rowHeight
            ?? row.defaultHeight
            ?? UITableView.automaticDimension
    }
    
    // MARK: UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return tableKitSections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < tableKitSections.count else { return 0 }
        
        return tableKitSections[section].numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = tableKitSections[indexPath.section].rows[indexPath.row]
        
        cellRegisterer?.register(cellType: row.cellType, forCellReuseIdentifier: row.reuseIdentifier)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        
        row.configure(cell)
        
        return cell
    }
    
    // MARK: UITableViewDataSource - section setup
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //如果外部vc实现了本方法，移交到外部vc
        if alterTableViewDataSource?.responds(to: #selector(tableView(_:titleForHeaderInSection:))) == true  {
            return alterTableViewDataSource!.tableView?(tableView, titleForHeaderInSection: section)
        }
        
        guard section < tableKitSections.count else { return nil }

        return tableKitSections[section].headerTitle
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        //如果外部vc实现了本方法，移交到外部vc
        if alterTableViewDataSource?.responds(to: #selector(tableView(_:titleForFooterInSection:))) == true  {
            return alterTableViewDataSource!.tableView?(tableView, titleForFooterInSection: section)
        }
        
        guard section < tableKitSections.count else { return nil }

        return tableKitSections[section].footerTitle
    }

    // MARK: UITableViewDelegate - section setup
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //如果外部vc实现了本方法，移交到外部vc
        if alterTableViewDelegate?.responds(to: #selector(tableView(_:viewForHeaderInSection:))) == true  {
            return alterTableViewDelegate!.tableView?(tableView, viewForHeaderInSection: section)
        }
        
        guard section < tableKitSections.count else { return nil }

        return tableKitSections[section].headerView
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //如果外部vc实现了本方法，移交到外部vc
        if alterTableViewDelegate?.responds(to: #selector(tableView(_:viewForFooterInSection:))) == true  {
            return alterTableViewDelegate!.tableView?(tableView, viewForFooterInSection: section)
        }
        
        guard section < tableKitSections.count else { return nil }

        return tableKitSections[section].footerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < tableKitSections.count else { return 0 }

        let tkSection = tableKitSections[section]
        return tkSection.headerHeight ?? tkSection.headerView?.frame.size.height ?? UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section < tableKitSections.count else { return 0 }

        let tkSection = tableKitSections[section]
        return tkSection.footerHeight
            ?? tkSection.footerView?.frame.size.height
            ?? UITableView.automaticDimension
    }
    
    // MARK: UITableViewDelegate - actions
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        invoke(action: .click, cell: cell, indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TableKitHelper {
    
    @discardableResult
    open func append(section: TableKitSection) -> Self {
        
        append(sections: [section])
        return self
    }
    
    @discardableResult
    open func append(sections: [TableKitSection]) -> Self {
        
        self.tableKitSections.append(contentsOf: sections)
        return self
    }
    
    @discardableResult
    open func append(rows: [Row]) -> Self {
        
        append(section: TableKitSection(rows: rows))
        return self
    }
    
    @discardableResult
    open func insert(section: TableKitSection, atIndex index: Int) -> Self {
        
        tableKitSections.insert(section, at: index)
        return self
    }
    
    @discardableResult
    open func replaceSection(at index: Int, with section: TableKitSection) -> Self {
        
        if index < tableKitSections.count {
            tableKitSections[index] = section
        }
        return self
    }
    
    @discardableResult
    open func remove(sectionAt index: Int) -> Self {
        
        tableKitSections.remove(at: index)
        return self
    }
    
    @discardableResult
    open func clear() -> Self {
        
        tableKitSections.removeAll()
        
        return self
    }
}
