//
//  GAMessageViewController.swift
//  GASimpleStructDemo
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2020 gamin.com. All rights reserved.
//

import UIKit

//列表VC的通用类。T是tableview对应的Array数据的item类型
class CommonArrayTableViewController<T: JsonModelProtocol> : CommonUITableViewController {
    
    //当前页码
    private var page: Int = 1;
    
    //列表tableview主数据
    lazy var mainArray: [T] = {
        return [T]()
    }()
    
    // MARK: Need Override 列表接口的地址
    func arrayApiPath() -> String {
        return ""
    }
    
    // MARK: Need Override 列表接口的请求参数，不需要包含page字段
    func arrayApiParams() -> [String: String] {
        return [String: String]()
    }
    
    //触发了下拉刷新，子类需要重写，一般在这里请求第一页数据
    override func headerRefreshingBlock() {
        executeRequireList(isRefresh: true)
    }

    //触发了底部下载更多，子类需要重写，一般在这里请求第n页数据
    override func footerLoadmoreBlock() {
        executeRequireList(isRefresh: false)
    }
    
    //正式执行请求列表接口
    func executeRequireList(isRefresh: Bool! = true) {

        var params = arrayApiParams()
        
        //如果是加载更多，就加上参数page；否则（下拉刷新）就强制设为1，如果服务器要求是0，就改成"0"
        params["page"] =  isRefresh ? "1" : String(self.page)
        HttpManager.shared.request(path: arrayApiPath(), params: params, success: { [weak self] (response : BaseResponse<BasePagerModel<T>>) in
            
            //如果你不写上面的[weak self]。会出现：pop后vc第一时间不deinit，一定要这里的请求结束后且走完success里的所有代码后，再deinit
            guard let `self` = self else { return }
            
            if (isRefresh) {
                //下拉刷新接口，服务器返回成功
                self.endHeaderRefreshing()
                
                //隐藏中间的loadingView
                self.hideCenterLoadingView()
                
                if (response.isSuccess()) {
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
                
                self.needShowEmptyView(show: self.mainArray.isEmpty, emptyImage: nil, emptyTitle: nil)
            } else {
                //加载更多接口，服务器无响应
                self.endFooterRefreshing()
            }
        })
    }

}

