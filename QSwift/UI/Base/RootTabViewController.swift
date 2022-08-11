//
//  RootTabViewController.swift
//  QSwift
//
//  Created by DongJin on 2021/3/25.
//


import UIKit

class RootTabViewController: UITabBarController ,UIAlertViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupChildController(childVC: HomeViewController(), norImageName: "tabbar_mine_normal", selectedImageName: "tabbar_mine_selected", title: "用户列表");
        
        setupChildController(childVC: TopicRootViewController(), norImageName: "tabbar_mine_normal", selectedImageName: "tabbar_mine_selected", title: "Tab列表");
        
        setupChildController(childVC: MeTabViewController(), norImageName: "tabbar_mine_normal", selectedImageName: "tabbar_mine_selected", title: "我的");
        
        setupSeparateColor();

        self.tabBar.tintColor = UIColor.init(red: 0.23, green: 0.61, blue: 0.99, alpha: 1.0)
    }
    
    //首次安装App，会弹出是否允许访问网络的弹框。用户点击确认后，进入这里，重新请求数据
    func reloadDataIfEmpty() {
        let firstNavigationController = self.viewControllers![0] as? UINavigationController
        guard let firstNavigationController = firstNavigationController else { return }
        
        let firstViewController = firstNavigationController.viewControllers[0] as? HomeViewController
        guard let firstViewController = firstViewController else { return }
        
        firstViewController.reloadDataIfEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
//        UITabBar.appearance().isTranslucent = false;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
//        UITabBar.appearance().isTranslucent = false;
    }
    
    // 改变分隔线颜色
    func setupSeparateColor () {
        if #available(iOS 13.0, *) {
            let tabBarAppearance = self.tabBar.standardAppearance;
            tabBarAppearance.shadowImage = UIImage.filled(withColor: UIColor.init(named: "separator235")!, size: CGSize(width: 320, height: 1 / UIScreen.main.scale))
            tabBar.standardAppearance = tabBarAppearance;
        }
    }
    
    // addChildViewController
    func setupChildController(childVC: UIViewController, norImageName: String, selectedImageName: String, title: String) {
        childVC.title = title;
        childVC.tabBarItem.image = UIImage(named: norImageName)?.withRenderingMode(.alwaysOriginal);
        childVC.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal);
        let nav = UINavigationController(rootViewController: childVC);
        nav.view.backgroundColor = UIColor.white
        addChild(nav);
    }
    

}

