//
//  CommonTableKitViewController.swift
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 gamin.com. All rights reserved.
//

import UIKit
import QTableKit

// 静态Cell的TableView封装类
// 主要的4个部分：自己定义的TableViewCell，自己定义的对应Cell的model，框架里的TableKitRow，TableRowAction
// 目前做法：TableKitRow持有 其他3个部分，并且做响应的参数分发
class CommonTableKitViewController: CommonUITableViewController {
    
    open var tableKitSections = [TableKitSection]()
    
    //TableViewCell的自动注册器，在CellForRowAtIndexPath里发挥作用
    private var cellRegisterer: TableCellRegisterer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {//适配黑夜模式
            view.backgroundColor = UIColor(named: "background")
        } else {
            view.backgroundColor = commonBackgroundColor
        }
        
        self.cellRegisterer = TableCellRegisterer(tableView: tableView)
        
        tableView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.onDrag
    }
    
    override func tableViewStyle() -> UITableView.Style {
        //tableViewStyle，由子类重写
        return UITableView.Style.grouped
    }
    
    override func refreshEnable() -> Bool{
        //是否支持下拉刷新，由子类重写
        return false
    }
    
    override func loadMoreEnable() -> Bool{
        //是否支持底部自动加载更多，由子类重写
        return false
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
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        let row = tableKitSections[indexPath.section].rows[indexPath.row]

        let rowHeight = invoke(action: .height, cell: nil, indexPath: indexPath) as? CGFloat

        //注意这里，由于swift的特性，即便是0，也会返回；只有nil才会走下面的??
        return rowHeight
            ?? row.defaultHeight
            ?? row.estimatedHeight
            ?? UITableView.automaticDimension
    }
    
    // ios11系统的回调顺序是：第二步：一个row回调1次cellForRowAt，然后回调3次heightForRowAt。ios10是相反的
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row = tableKitSections[indexPath.section].rows[indexPath.row]
   
        let rowHeight = invoke(action: .height, cell: nil, indexPath: indexPath) as? CGFloat

        //注意这里，由于swift的特性，即便是0，也会返回；只有nil才会走下面的??
        return rowHeight
            ?? row.defaultHeight
            ?? UITableView.automaticDimension
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableKitSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < tableKitSections.count else { return 0 }
        
        return tableKitSections[section].numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = tableKitSections[indexPath.section].rows[indexPath.row]
        
        cellRegisterer?.register(cellType: row.cellType, forCellReuseIdentifier: row.reuseIdentifier)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        
        row.configure(cell)

        return cell
    }
    
    // MARK: UITableViewDataSource - section setup
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < tableKitSections.count else { return nil }

        return tableKitSections[section].headerTitle
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section < tableKitSections.count else { return nil }

        return tableKitSections[section].footerTitle
    }

    // MARK: UITableViewDelegate - section setup
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < tableKitSections.count else { return nil }

        return tableKitSections[section].headerView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section < tableKitSections.count else { return nil }

        return tableKitSections[section].footerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < tableKitSections.count else {
            return tableView.style == UITableView.Style.plain ? 0 : CGFloat.leastNormalMagnitude
        }

        let tkSection = tableKitSections[section]
        return tkSection.headerHeight
            ?? tkSection.headerView?.frame.size.height
            ?? (tableView.style == UITableView.Style.plain ? 0 : CGFloat.leastNormalMagnitude)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section < tableKitSections.count else {
            return tableView.style == UITableView.Style.plain ? 0 : 8;
        }

        let tkSection = tableKitSections[section]
        return tkSection.footerHeight
            ?? tkSection.footerView?.frame.size.height
            ?? (tableView.style == UITableView.Style.plain ? 0 : 8);
    }
    
    // MARK: UITableViewDelegate - actions
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        invoke(action: .click, cell: cell, indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

