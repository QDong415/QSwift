//
//  GAMessageViewController.swift
//  GASimpleStructDemo
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 gamin.com. All rights reserved.
//

import UIKit


private let reuseIdentifier = "UITableViewCell"

class SheetMenuViewController: CommonUITableViewController  {
    
    open var mainArray: [String]?

    override func refreshEnable() -> Bool{
        //是否支持下拉刷新，由子类重写
        return false
    }
    
    override func loadMoreEnable() -> Bool{
        //是否支持底部自动加载更多，由子类重写
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:reuseIdentifier)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArray!.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = mainArray?[indexPath.row]
        return cell;
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        self.present(fpc, animated: true, completion: nil)
    }
}



extension SheetMenuViewController: PanModalPresentable {
    
    //MARK: PanModalPresentable
    var panScrollable: UIScrollView? {
        return self.tableView
    }

//    var longFormHeight: PanModalHeight {
//        return longFormHeight
//    }
    
//    var topOffset: CGFloat {
//        return topLayoutOffset + 401.0
//    }

    var anchorModalToLongForm: Bool {
        return false
    }
    
    var springDamping: CGFloat {
        return 1.0
    }
    
    var transitionDuration: Double {
        return 0.3
    }
    
    var cornerRadius: CGFloat {
        return 15
    }
    
    var panModalBackgroundColor: UIColor {
        UIColor.black.withAlphaComponent(0.2)
    }
}

