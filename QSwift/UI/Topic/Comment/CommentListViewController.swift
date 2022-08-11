//
//  GAMessageViewController.swift
//  GASimpleStructDemo
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 gamin.com. All rights reserved.
//

import UIKit


private let reuseIdentifier = "TopicCell"

class CommentListViewController: CommonArrayTableViewController<TopicModel>  {

    var topicId : Int64!
    
    //取出1个cell，专门用来计算高度。estimatedHeightForRowAt中使用，可以大量避免Cell的创建，提高允许效率
    private var estimatedHeightCell: TopicCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "评论列表"
        
        tableView.register(UINib(nibName:reuseIdentifier, bundle:nil), forCellReuseIdentifier: reuseIdentifier)

        
        //取出1个cell，专门用来计算高度
        estimatedHeightCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TopicCell
        
        //显示中间的loadingView
        showCenterLoadingView(true)
        
        //请求接口
        executeRequireList(isRefresh: true)
        
        //添加底部输入View
        var safeAreaInsetsBottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            //如果是x，给底部的34pt添加上背景颜色，颜色和输入条一致
            safeAreaInsetsBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            if safeAreaInsetsBottom > 0 {
                //iPhoneX 且 聊天界面VC（即输入条固定在底部）就会进入这里
                //我添加了一个和输入条背景颜色一样的普通View在inputView的底部
                let belowInputBarXView = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - safeAreaInsetsBottom, width: self.view.frame.size.width, height: safeAreaInsetsBottom))
                belowInputBarXView.backgroundColor = UIColor.yellow
                self.view.addSubview(belowInputBarXView)
            }
        }
        
        let commentBottomView = UIView(frame: CGRect.init(x: 0, y: self.view.bounds.height - safeAreaInsetsBottom - 84, width: self.view.bounds.width, height: 84))
        commentBottomView.backgroundColor = UIColor.yellow
        let tipsLabel = UILabel.init(frame: commentBottomView.bounds)
        tipsLabel.text = "给TableView界面的底部如果有view，建议使用tableView.contentInset，而不是用约束。系统的UITabViewController里嵌套TableView也是这么处理的，效率更高"
        tipsLabel.numberOfLines = 0
        commentBottomView.addSubview(tipsLabel)
        self.view.addSubview(commentBottomView)
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: commentBottomView.bounds.height, right: 0)
        self.tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    // MARK: Override 列表接口的地址
    override func arrayApiPath() -> String {
        return "topic/getlist"
    }

    // MARK: Override 列表接口的请求参数，不需要包含page字段
    override func arrayApiParams() -> [String: String] {
        return ["pagesize": "20"]
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        estimatedHeightCell.setData(model: mainArray[indexPath.row], true)
        let size = estimatedHeightCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return size.height
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TopicCell
        cell.setData(model: mainArray[indexPath.row])
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let sheetMenuViewController = SheetMenuViewController()
//        sheetMenuViewController.mainArray = ["help","quere","收货很多"]
//        sheetMenuViewController.modalPresentationStyle = .currentContext
//        presentPanModal(sheetMenuViewController)

    }

}
