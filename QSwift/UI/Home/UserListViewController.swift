//
//  GAMessageViewController.swift
//  GASimpleStructDemo
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 gamin.com. All rights reserved.
//

import UIKit


private let reuseIdentifier = "ContactCell"

class UserListViewController: CommonArrayTableViewController<UserSimpleModel>  {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "标题"
        
        tableView.register(UINib(nibName:reuseIdentifier, bundle:nil), forCellReuseIdentifier: reuseIdentifier)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "toLogin", style: .done, target: self, action: #selector(toLogin))
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        
        //主动触发下拉刷新
//        beginFooterRefreshing()
        
        showCenterLoadingView(true)
        
        executeRequireList(isRefresh: true)
    }
    
    // MARK: Override 列表接口的地址
    override func arrayApiPath() -> String {
        return "user/getlist"
    }

    // MARK: Override 列表接口的请求参数，不需要包含page字段
    override func arrayApiParams() -> [String: String] {
        return ["keyword": "小"]
    }
    
    @objc
    func toLogin() {
//        let loginVC = LoginDemoController()
//        self.navigationController?.pushViewController(loginVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ContactCell
        cell.setData(model: mainArray[indexPath.row])
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        return cell;
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        self.present(fpc, animated: true, completion: nil)
//        let sheetMenuViewController = SheetMenuViewController()
//        sheetMenuViewController.mainArray = ["help","quere","收货很多"]
//        sheetMenuViewController.modalPresentationStyle = .currentContext
//        presentPanModal(sheetMenuViewController)

    }
    
    deinit {
        printLog("UserListViewController deinit")
    }
}
