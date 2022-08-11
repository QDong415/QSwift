//
//  GAMessageViewController.swift
//  GASimpleStructDemo
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 gamin.com. All rights reserved.
//

import UIKit


private let reuseIdentifier = "TopicCell"

class TopicListViewController: CommonArrayTableViewController<TopicModel>  {

    
    //取出1个cell，专门用来计算高度。estimatedHeightForRowAt中使用，可以大量避免Cell的创建，提高允许效率
    private var estimatedHeightCell: TopicCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "话题列表"
        
        tableView.register(UINib(nibName:reuseIdentifier, bundle:nil), forCellReuseIdentifier: reuseIdentifier)

        
        //取出1个cell，专门用来计算高度
        estimatedHeightCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TopicCell
        
        //显示中间的loadingView
        showCenterLoadingView(true)
        
        //请求接口
        executeRequireList(isRefresh: true)
    }
    
    // MARK: Override 列表接口的地址
    override func arrayApiPath() -> String {
        return "topic/getlist"
    }

    // MARK: Override 列表接口的请求参数，不需要包含page字段
    override func arrayApiParams() -> [String: String] {
        return ["pagesize": "20"]
    }
    
    //在heightForRowAt 里使用estimatedHeightCell，翻到第10页，共创建了46个Cell, deinit 22个，第一次加载成功就创建了8个Cell
    //在estimatedHeightForRowAt 里使用estimatedHeightCell，翻到第10页，创建了15个Cell, deinit 0个，第一次加载成功就创建了8个Cell
    //什么都不写，翻到第10页，创建了40个Cell，deinit 20个，第一次加载成功就创建了8个Cell
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        estimatedHeightCell.setLabelPreferredMaxLayoutWidth(cellWith: tableView.bounds.size.width)
//        estimatedHeightCell.setData(model: mainArray[indexPath.row])
//        let size = estimatedHeightCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        return size.height
//    }
    
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

        let vc = CommentListViewController()
        vc.topicId = self.mainArray[indexPath.section].tid
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
