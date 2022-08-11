//
//  ContentBaseViewController.swift
//  JXSegmentedView
//
//  Created by jiaxin on 2018/12/26.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit
import JXSegmentedView

class TopicRootViewController: UIViewController {

    let totalItemWidth: CGFloat = 240
    var segmentedDataSource: JXSegmentedBaseDataSource?
    
    //顶部的横滑tabbar
    let segmentedView = JXSegmentedView()
    
    //viewControllers，默认采用scrollview作为vc的承载器
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let titles = ["推荐", "附近", "关注"]
        let titleDataSource = JXSegmentedTitleDataSource()
//        titleDataSource.isItemSpacingAverageEnabled = true
        titleDataSource.titles = titles
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 17)
//        titleDataSource.itemWidth = totalItemWidth/CGFloat(titles.count)
//        titleDataSource.itemSpacing = 0
        titleDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource = titleDataSource
        segmentedView.dataSource = titleDataSource
        segmentedView.frame = CGRect(x: 0, y: 0, width: totalItemWidth, height: 44)
        navigationItem.titleView = segmentedView


        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicator.indicatorHeight = 4
        segmentedView.indicators = [indicator]

        //设置 sh_scrollViewPopGestureRecognizerEnable 属性为 true 可以让 scrollView 的控制器具有左滑返回手势
        listContainerView.scrollView.sh_scrollViewPopGestureRecognizerEnable = true
        
        

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 15.0, *) {
            //移除ios15的导航栏的渐变特性
            let appearance = UINavigationBarAppearance()
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        //处于第一个item的时候，才允许屏幕边缘手势返回
//        self.sh_interactivePopDisabled = (segmentedView.selectedIndex != 0)
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 15.0, *) {
            //恢复ios15的导航栏的渐变特性
            navigationController?.navigationBar.scrollEdgeAppearance = nil
        }
        
        //离开页面的时候，需要恢复屏幕边缘手势，不能影响其他页面
//        self.sh_interactivePopDisabled = false
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        segmentedView.frame = CGRect(x: 0, y: 0, width: totalItemWidth, height: 44)
        listContainerView.frame = view.bounds
    }
}

extension TopicRootViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedView.dataSource as? JXSegmentedDotDataSource {
            //先更新数据源的数据
            dotDataSource.dotStates[index] = false
            //再调用reloadItem(at: index)
            segmentedView.reloadItem(at: index)
        }

//        self.sh_interactivePopDisabled = (segmentedView.selectedIndex != 0)
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
}

extension TopicRootViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        switch index {
        case 0:
            return TopicListViewController()
        default:
            return UserListViewController()
        }
    }
}

extension TopicListViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension UserListViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension HomeViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
