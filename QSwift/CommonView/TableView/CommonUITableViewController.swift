//
//  QUITableViewController.swift
//  QSwift
//
//  Created by QDong on 2021/3/25.
//

import UIKit
import MJRefresh

let emptyDefaultTips = "没有内容哦"

class CommonUITableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private(set) var tableView: UITableView!
    
    //内容为空的时候的布局，他的bound是和tableView一致
    private(set) var emptyView: CommonUIEmptyView?
    
    //正中间的“加载中”动画，他的size是 96,37
    private(set) var centerLoadingView: CommonUILoadingView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }
    
    func initTableView() {
        tableView = UITableView.init(frame: view.bounds, style: tableViewStyle())
        
        //移除底部多余的separator
        if(tableView.style == UITableView.Style.plain){
            let footerView: UIView = UIView();
            tableView.tableFooterView = footerView;
        }
        
        //为了适配ios11的黑夜模式
        if #available(iOS 11, *) {
            tableView.backgroundColor = UIColor.init(named: "background");
            tableView.separatorColor = UIColor.init(named: "separator");
        } else {
            tableView.backgroundColor = UIColor(red: (248)/255.0, green: (248)/255.0, blue: (246)/255.0, alpha: 1)
        }
        
        tableView.delegate = self;
        tableView.dataSource = self;
        view.addSubview(tableView)
        
        //如果采用约束布局的方式(代码如下)，能自动适应屏幕旋转。无需重设frame。本案采用传统frame的方式，效率略微提高
//        tableView.translatesAutoresizingMaskIntoConstraints = false;
//        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true  //顶部约束
//        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true  //左端约束
//        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true  //右端约束
//        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true

        if (loadMoreEnable()){
            tableView.mj_footer = MJRefreshAutoNormalFooter { [weak self] in
                self?.footerLoadmoreBlock();
            };
        }
        
        if (refreshEnable()) {
            let header = MJRefreshNormalHeader { [weak self] in
                self?.headerRefreshingBlock();
            }
            //隐藏mj下拉刷新的时间和状态
            header.lastUpdatedTimeLabel?.isHidden = true;
            header.stateLabel?.isHidden = true;
            header.isAutomaticallyChangeAlpha = true;
            tableView.mj_header = header;
            
            //先设置为没有下一页
            tableView.mj_footer?.isHidden = true;
        }
    }
    
    //以下是下拉刷新和底部加载的相关控件方法（目前用的是mj），放到base类里面，这样更换的话更方便
    
    //open - 临时禁止下拉刷新，子类主动调用；这个方法一般不常用，比如某个VC不需要下拉刷新功能，才用这个
    func hideRefreshHeader(hide: Bool) {
        tableView.mj_header?.isHidden = hide
    }
    
    //open - 临时禁止底部翻页，子类主动调用；这个方法一般不常用，比如某个VC不需要底部加载更多功能，才用这个
    func hideRefreshFooter(hide: Bool) {
        tableView.mj_footer?.isHidden = hide
    }
    
    //open - 结束下拉刷新，子类主动调用；这个方法经常使用
    func endHeaderRefreshing(){
        if !(tableView.mj_header?.isHidden ?? false) {
            tableView.mj_header?.endRefreshing()
        }
    }
    
    //open - 结束底部翻页，子类主动调用；这个方法经常使用
    func endFooterRefreshing(){
        tableView.mj_footer?.endRefreshing()
    }
    
    //open - 主动触发下拉刷新
    func beginFooterRefreshing(){
        tableView.mj_footer?.beginRefreshing()
    }
    
    //open - 主动触发底部翻页
    func beginHeaderRefreshing(){
        tableView.mj_header?.beginRefreshing()
    }
    
    
    //旋转屏幕，和 第一次的willAppear和didAppear中间 都会调用这个方法；app进入后台1秒后，可能会调用4次这个方法
    //如果tableview不是用约束add上去的，那么要在这里重新设置frame，否则老版本ios无法适配
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        //测试结果：约束布局下 tbf =  (0.0, 0.0, 390.0, 844.0)；frame下可能需要frame =
        let shouldChangeTableViewFrame: Bool = !self.view.bounds.equalTo(tableView.frame);
        if (shouldChangeTableViewFrame) {
            tableView.frame = self.view.bounds;
            
            //为了处理旋转屏幕时候的emptyView
            layoutEmptyView()
        }
        
        //由于往往是在viewDidLoad()里就showCenterLoadingView，所以这里不能写在上面的if里
        layoutCenterLoadingView()
    }

    // MARK: - can override
    //触发了下拉刷新，子类需要重写，一般在这里请求第一页数据
    func headerRefreshingBlock() {}

    //触发了底部下载更多，子类需要重写，一般在这里请求第n页数据
    func footerLoadmoreBlock() {}
    
    func emptyViewPaddingBottom() -> CGFloat {
        return 0;
    }
    
    func centerLoadingViewPaddingBottom() -> CGFloat {
        return 0;
    }
    
    func tableViewStyle() -> UITableView.Style {
        //tableViewStyle，由子类重写
        return UITableView.Style.plain
    }
    
    func refreshEnable() -> Bool{
        //是否支持下拉刷新，由子类重写
        return true
    }
    
    func loadMoreEnable() -> Bool{
        //是否支持底部自动加载更多，由子类重写
        return true
    }

    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell();
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
        return tableView.style == UITableView.Style.plain ? 0 : CGFloat.leastNormalMagnitude;
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
        return tableView.style == UITableView.Style.plain ? 0 : 8;
    }
    
    deinit {
        tableView.delegate = nil
        tableView.dataSource = nil
    }
}


// MARK: - EmptyView
extension CommonUITableViewController {
    
    //子类直接调用这个方法，显示 or 隐藏emptyview
    func needShowEmptyView(show: Bool, emptyImage: UIImage?, emptyTitle: String?) {
        if (show) {
            showEmptyView(image: emptyImage ?? UIImage.init(named: "tips_empty_works"), text: emptyTitle ?? emptyDefaultTips)
        } else {
            hideEmptyView();
        }
    }
    
    //最终的addEmptyView并显示
    func showEmptyView(image: UIImage?, text: String?){
        if (emptyView == nil) {
            emptyView = CommonUIEmptyView(frame: self.view.bounds)
        }
        //ios系统会自动处理多次addSubview的情况，所以无需担心add多次
        tableView.addSubview(emptyView!)
        layoutEmptyView()
        
        emptyView!.setImage(image)
        emptyView!.setTextLabelText(text)
        emptyView!.setNeedsDisplay()
        emptyView!.sharkImageView()
    }
    
    func hideEmptyView() {
        emptyView?.removeFromSuperview()
    }
    
    @discardableResult
    private func layoutEmptyView() -> Bool {
        
        guard emptyView?.superview != nil else {
            return false
        }
        
        //注意，tab和navigation会导致tableView.contentInset有变化（top == 94，bottom == 83）
        var insets: UIEdgeInsets! = tableView.contentInset
        if #available(iOS 11.0, *) {
            if tableView.contentInsetAdjustmentBehavior != .never {
                insets = tableView.adjustedContentInset
            }
        }
        
        let emptyViewPaddingBottom: CGFloat = emptyViewPaddingBottom()
        
        // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
        let tableHeaderViewMaxY: CGFloat = tableView.tableHeaderView?.frame.maxY ?? 0
        
        emptyView!.frame = CGRect(x: 0, y: tableHeaderViewMaxY, width: tableView.bounds.width - insets.left - insets.right, height: tableView.bounds.height - insets.top - insets.bottom - tableHeaderViewMaxY - emptyViewPaddingBottom)

        return true;
    }
}


// MARK: - CenterLoadingView
extension CommonUITableViewController {
    
    func showCenterLoadingView(_ hideRefreshHeader: Bool = true) {
        if centerLoadingView == nil {
            centerLoadingView = CommonUILoadingView(frame: CGRect.init(x: 0, y: 0, width: 95, height: 30))
        }
        tableView.addSubview(centerLoadingView!)
        
        layoutCenterLoadingView()
        
        if hideRefreshHeader {
            self.hideRefreshHeader(hide: true)
        }
    }

    func hideCenterLoadingView(_ enableRefreshHeader: Bool = true) {
        if let centerLoadingView = centerLoadingView {
            centerLoadingView.removeFromSuperview()
        }
        
        self.centerLoadingView = nil
        
        if enableRefreshHeader {
            self.hideRefreshHeader(hide: false)
        }
    }
    
    @discardableResult
    private func layoutCenterLoadingView() -> Bool {
        
        guard centerLoadingView?.superview != nil else {
            return false
        }
        
        var insets: UIEdgeInsets! = tableView.contentInset
        if #available(iOS 11.0, *) {
            if tableView.contentInsetAdjustmentBehavior != .never {
                insets = tableView.adjustedContentInset
            }
        }
        
        let centerLoadingViewPaddingBottom: CGFloat = centerLoadingViewPaddingBottom()
        
        // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
        let tableHeaderViewMaxY: CGFloat = tableView.tableHeaderView?.frame.maxY ?? 0
        
        let orgFrame = centerLoadingView!.frame

        centerLoadingView!.frame = CGRect(x: (self.tableView.bounds.size.width  - insets.left - insets.right - orgFrame.size.width) / 2,
                                          y: tableHeaderViewMaxY + (tableView.bounds.size.height - insets.top - insets.bottom - tableHeaderViewMaxY - orgFrame.size.height) / 2 - centerLoadingViewPaddingBottom,
                                          width: orgFrame.size.width,
                                          height: orgFrame.size.height)

        return true;
    }

}

