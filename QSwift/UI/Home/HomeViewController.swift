//
//  GAMessageViewController.swift
//  GASimpleStructDemo
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2020 gamin.com. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ContactCell"

class HomeViewController: CommonUITableViewController {
    
    private var page: Int = 1;
    private lazy var mainArray: [UserSimpleModel] = {
        return [UserSimpleModel]()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName:reuseIdentifier, bundle:nil), forCellReuseIdentifier: reuseIdentifier)
        
        let scrollView = UIScrollView()
        scrollView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 180)
        scrollView.contentSize = CGSize.init(width: SCREEN_WIDTH * 3, height: 120)
        scrollView.backgroundColor = UIColor.yellow
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH * 3, height: 180))
        label.text = "rollView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 120)View.register(UINib(nibName:reuseIdentifier, bundle:nil), forCellReuseIdentifier: reuseIdentifier)"
        scrollView.addSubview(label)
        
        self.tableView.tableHeaderView = scrollView
        
        showCenterLoadingView(true)
        
        executeRequireList(isRefresh: true)
    }
    
    //首次安装App，会弹出是否允许访问网络的弹框。用户点击确认后，进入这里，重新请求数据
    func reloadDataIfEmpty() {
        if (mainArray.isEmpty) {
            executeRequireList(isRefresh: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //触发了下拉刷新，子类需要重写，一般在这里请求第一页数据
    override func headerRefreshingBlock() {
        executeRequireList(isRefresh: true)
    }

    //触发了底部下载更多，子类需要重写，一般在这里请求第n页数据
    override func footerLoadmoreBlock() {
        executeRequireList(isRefresh: false)
    }
    
    // MARK - 这里展示的是不封装的写法，想封装的话，看 UserListViewController.swift
    //调用接口，请求列表
    private func executeRequireList(isRefresh: Bool! = true) {
        
        //如果是加载更多，就加上参数page；否则（下拉刷新）就强制设为1，如果服务器要求是0，就改成"0"
        var params = ["page": isRefresh ? "1" : String(self.page)]
        params["keyword"] = "小" //keyword传入奇怪的参数，就可以让服务器返回空列表
//        params["error"] = "1" //传入这个error为1，服务器就返回code为0 就是失败
        HttpManager.shared.request(path: "user/getlist", params: params, success: { [weak self] (response : BaseResponse<BasePagerModel<UserSimpleModel>>) in
            
            //如果你不写上面的[weak self]。会出现：pop后vc第一时间不deinit，一定要这里的请求结束后且走完success里的所有代码后，再deinit
            guard let `self` = self else { return }
            
            if (isRefresh) {
                //下拉刷新接口，服务器返回成功
                self.endHeaderRefreshing()
                
                //隐藏中间的loadingView
                self.hideCenterLoadingView()
                
                if (response.code == 1) {
                    //服务器返回了code为成功
                    //重新remove再append数据
                    self.mainArray.removeAll()
                    self.mainArray.append(contentsOf: (response.data?.items)!)
                    
                    //根据服务器返回的“是否还有更多数据”来隐藏或显示moreFooter
                    self.hideRefreshFooter(hide: !response.data!.hasMore())
                    
                    //刷新UI
                    self.tableView.reloadData()
                    
                    //调用父类封装的是否需要显示\隐藏emptyView
                    self.needShowEmptyView(show: self.mainArray.isEmpty, emptyImage: nil, emptyTitle: nil)
                    
                    //下一页页码强制设为为2
                    self.page = 2;
                } else {
                    //服务器返回了code为失败
                    printLog(response.message)
                    //利用EmptyView显示错误信息
                    self.needShowEmptyView(show: self.mainArray.isEmpty, emptyImage: nil, emptyTitle: response.message)
                }
            } else {
                //底部加载更多接口，服务器返回成功
                self.endFooterRefreshing()

                if (response.isSuccess()) {
                    //服务器返回了code为成功
                    //append数据
                    self.mainArray.append(contentsOf: (response.data?.items)!)
                    
                    //根据服务器返回的“是否还有更多数据”来隐藏或显示moreFooter
                    self.hideRefreshFooter(hide: !response.data!.hasMore())
                    
                    //刷新UI
                    self.tableView.reloadData()
                    
                    //下一页页码+1
                    self.page += 1;
                } else {
                    //服务器返回了code为失败，由于这里是 加载更多接口 失败，就无需多做处理
                    printLog(response.message)
                }
            }
        }, failure: { [weak self] error in
            
            guard let `self` = self else { return }
            
            //网络请求失败，服务器关闭或者json解析失败
            if (isRefresh) {
                //下拉刷新接口，服务器无响应
                self.endHeaderRefreshing()
                
                //隐藏中间的loadingView
                self.hideCenterLoadingView()
                
                self.needShowEmptyView(show: self.mainArray.isEmpty, emptyImage: nil, emptyTitle: "服务器出问题了")
            } else {
                //加载更多接口，服务器无响应
                self.endFooterRefreshing()
            }
        })
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArray.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ContactCell
        cell.setData(model: mainArray[indexPath.row])
        return cell;
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destination = UserListViewController()
        destination.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(destination, animated: true)
    }

}

