//
//  AppDelegate.swift
//  QSwift
//
//  Created by QDong on 2021/3/23.
//

import UIKit
import SVProgressHUD
import Alamofire

#if DEBUG
import GDPerformanceView_Swift
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //首次安装App，会弹出是否允许访问网络的弹框。弹框时候是无网络的。等用户点了确认要监听网络恢复
    private var reachabilityManager = Alamofire.NetworkReachabilityManager()
    
    //上一次的网络状态
    private var lastReachabilityState: NetworkReachabilityManager.NetworkReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus.notReachable
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //开启性能检测，如果直接run到真机上，也不会有这个；仅限于模拟器
        #if DEBUG
            PerformanceMonitor.shared().start()
            PerformanceMonitor.shared().performanceViewConfigurator.options = [.performance,.memory]
            PerformanceMonitor.shared().performanceViewConfigurator.style = .custom(backgroundColor: .white, borderColor: UIColor.black, borderWidth: 1, cornerRadius: 1, textColor: .black, font:  UIFont.systemFont(ofSize: 15))
        #endif
      
        //检查账号登录情况
        let hadLogin: Bool = AccountManager.shared.checkAccountModelByStore()
        
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        SVProgressHUD.setMaximumDismissTimeInterval(4)
//        [SVProgressHUD sharedView].minimumDismissTimeInterval
        
        //配置全局UI
        setupUI()
      
        //开启全屏侧滑，相当于OC的FDFullscreenPopGesture库；但是OC的库不需要写这句代码，因为OC有+load方法
        SHFullscreenPopGesture.configure()
        
        let tabbar = RootTabViewController();
        
        window = UIWindow(frame: UIScreen.main.bounds);
        if let window = window {
            window.rootViewController = tabbar
            window.makeKeyAndVisible()
        }
        
        startNetworkListening()
        
        return true
    }
    
    //配置全局UI
    private func setupUI(){

        UINavigationBar.appearance().isTranslucent = true  //导航栏透明
        
        if #available(iOS 11.0, *) {
            //导航栏分割线
            UINavigationBar.appearance().shadowImage = UIImage.filled(withColor: UIColor.init(named: "separator235")!, size: CGSize(width: 1, height: 1 / UIScreen.main.scale))

            //返回键字体颜色
            UINavigationBar.appearance().tintColor = UIColor.init(named: "text_black_gray")!
        } else {
            //导航栏分割线
            UINavigationBar.appearance().shadowImage = UIImage.filled(withColor: commonSeparatorColor, size: CGSize(width: 1, height: 1 / UIScreen.main.scale))

            //返回键字体颜色
            UINavigationBar.appearance().tintColor = commonBlackColor
        }
    }
    
    
    //首次安装App，会弹出是否允许访问网络的弹框。用户点击确认后，进入这里，重新请求数据
    private func startNetworkListening() {
        
        guard let reachabilityManager = self.reachabilityManager else { return }
        
        if reachabilityManager.isReachable {
            //本来就是可以连上网的，后面就不需要监听了
            return
        }
        
        reachabilityManager.startListening(onUpdatePerforming: { [weak self] status in
            guard let `self` = self else {
                return
            }
            switch status {
            case .notReachable:
                break
            case .unknown :
                break
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                if self.lastReachabilityState == .notReachable || self.lastReachabilityState == .unknown {
                    //之前是网络不可达
                    let rootTabViewController = self.window!.rootViewController as! RootTabViewController
                    rootTabViewController.reloadDataIfEmpty()
                }
            }
            
            self.lastReachabilityState = status
        })
    }

}

