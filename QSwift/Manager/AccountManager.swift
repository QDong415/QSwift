//
//  HttpManager.swift
//  TSWeChat
//
//  Created by Hilen on 11/3/15.
//  Copyright © 2015 Hilen. All rights reserved.
//


import Foundation
import UIKit


class AccountManager: NSObject {
    
    static let AccountLoginNotification = Notification.Name("ACLogin")
    
    static let AccountLogoutNotification = Notification.Name("ACLogout")
    
    static let AccountModifyNotification = Notification.Name("ACModify")
    
    private let AccountJsonStoreKey: String = "AccKey"
    
    static let shared: AccountManager = AccountManager()
    
    //当前登录的账号信息
    private(set) var accountModel: AccountModel?
    
    //禁止别的地方初始化本类
    fileprivate override init() {
        super.init()
    }
    
    //登录or注册or退出，保存到本地，并发出广播通知
    open func storeAccountModel(newAccountModel: AccountModel?, postNotification: Bool = true) {
        
        //当前是否已经登录
        let hadLogin: Bool = self.accountModel != nil

        if let newAccountModel = newAccountModel {
            //说明不是退出登录
            if hadLogin {
                //已经登录了 && 新的model不为nil，说明是修改资料。最好不要直接赋值，因为那样会改变全局变量accountModel的指针
                self.accountModel!.userid = newAccountModel.userid
                self.accountModel!.name = newAccountModel.name
                self.accountModel!.avatar = newAccountModel.avatar
                self.accountModel!.token = newAccountModel.token
                self.accountModel!.mobile = newAccountModel.mobile
            } else {
                //之前本地是nil。说明是登录 or 注册，直接赋值
                self.accountModel = newAccountModel
            }
            
            //保存起来 请不要用MMKV，它有极低的几率会丢失
            UserDefaults.standard.set(newAccountModel.toJSONString(), forKey: AccountJsonStoreKey)
            UserDefaults.standard.synchronize()
            
            if postNotification {
                //发出广播，刷新tab上的状态
                NotificationCenter.default.post(name: hadLogin ? AccountManager.AccountModifyNotification : AccountManager.AccountLoginNotification, object: newAccountModel)
            }
            
        } else {
            //说明是退出登录
            self.accountModel = nil
            
            UserDefaults.standard.removeObject(forKey: AccountJsonStoreKey)
            UserDefaults.standard.synchronize()
            
            if postNotification {
                //发出广播，刷新tab上的状态
                NotificationCenter.default.post(name: AccountManager.AccountLogoutNotification, object: newAccountModel)
            }
        }
    }
    
    //从本地UserDefaults取出json，解析成当前账号Model。请不要用MMKV，它有极低的几率会丢失
    open func checkAccountModelByStore() -> Bool {
        guard let accountJson = UserDefaults.standard.string(forKey: AccountJsonStoreKey) else {
            return false
        }
        
        self.accountModel = AccountModel.deserialize(from: accountJson)
        
        return self.accountModel != nil
    }
    
    //已经登录了就return false，否则跳转到登录界面并return true
    open func toLoginIfNeed(_ viewController: UIViewController) -> Bool {
        if self.accountModel != nil {
            return false
        } else {
            let loginViewController = AccountLoginViewController()
            let navigationController = UINavigationController(rootViewController: loginViewController);
            viewController.present(navigationController, animated: true)
            return true
        }
    }
    
    open func safeUserId() -> String {
        return accountModel?.userid ?? ""
//        return accountModel != nil ? accountModel?.userid! : ""
    }
}
