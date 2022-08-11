//
//  MeTabViewController.swift
//
//  Created by QDong on 2021/2/25.
//  Copyright © 285275534@qq.com. All rights reserved.
//


import UIKit
import SVProgressHUD
import QTableKit

class MeTabViewController: CommonTableKitViewController {
    
    private var meTabHeaderCell: MeTabHeaderCell!;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "我的"
        
        NotificationCenter.default.addObserver(self, selector: #selector(accountLogin(notification:)), name: AccountManager.AccountLoginNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(accountModify(notification:)), name: AccountManager.AccountModifyNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(accountLogout(notification:)), name: AccountManager.AccountLogoutNotification, object: nil)
        
        //隐藏导航栏
        self.sh_prefersNavigationBarHidden = true
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        let topBgView :UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH * 25/36))
        topBgView.image = UIImage(named: "mine_header_bg");
        view.addSubview(topBgView)
        view.bringSubviewToFront(tableView)
        tableView.backgroundColor = UIColor.clear;
        
        meTabHeaderCell = UINib(nibName: "MeTabHeaderCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as? MeTabHeaderCell
        meTabHeaderCell.userImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerImageClick))
        meTabHeaderCell.userImageView.addGestureRecognizer(tapGestureRecognizer)
        tableView.tableHeaderView = meTabHeaderCell
        
        /// start ----------- 第一栏section --------- start
        let section = TableKitSection()//创建一个Section

        /// 创建cell的点击事件
        var cellClickAction = TableRowAction<MeTabCell>(.click) { [weak self] (options :TableRowActionCallback<MeTabCell>) in
            //点击Cell
            guard let `self` = self else { return  }
            if AccountManager.shared.toLoginIfNeed(self) {
                return //去登录界面了
            }
            let settingViewController = MeSettingController()
            settingViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingViewController, animated: true)
        }
        let nameRow = TableKitRow<MeTabCell>(item: MeTabModel(imageName: "me_tab_submit", title: "设置1"), actions: [cellClickAction])//创建cell，并绑定cell的数据+点击事件
        section.append(row: nameRow) //section添加cell
        
        /// 创建cell的点击事件
        cellClickAction = TableRowAction<MeTabCell>(.click) { [weak self] (options :TableRowActionCallback<MeTabCell>) in
            //点击Cell
            guard let `self` = self else { return  }
            if AccountManager.shared.toLoginIfNeed(self) {
                return //去登录界面了
            }
            let settingViewController = MeSettingController()
            settingViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingViewController, animated: true)
        }
        let nameRow2 = TableKitRow<MeTabCell>(item: MeTabModel(imageName: "me_tab_submit", title: "设置2"), actions: [cellClickAction])//创建cell，并绑定cell的数据+点击事件
        section.append(row: nameRow2) //section添加cell
        
        /// 创建cell的点击事件
        cellClickAction = TableRowAction<MeTabCell>(.click) { [weak self] (options :TableRowActionCallback<MeTabCell>) in
            //点击Cell
            guard let `self` = self else { return  }
            if AccountManager.shared.toLoginIfNeed(self) {
                return //去登录界面了
            }
            let settingViewController = MeSettingController()
            settingViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingViewController, animated: true)
        }
        let nameRow3 = TableKitRow<MeTabCell>(item: MeTabModel(imageName: "me_tab_submit", title: "设置3"), actions: [cellClickAction])//创建cell，并绑定cell的数据+点击事件
        section.append(row: nameRow3) //section添加cell
        
        self.tableKitSections.append(section) //把section添加到[section]
        
        //设置数据
        setDataUI(accountModel: AccountManager.shared.accountModel)
    }
    
    //MARK: Private
    //设置我的头像昵称UI
    private func setDataUI(accountModel: AccountModel?) {
        if let accountModel = accountModel {
            meTabHeaderCell.userImageView.setImageWithURLString(fileUrlString(accountModel.avatar), placeholderImage: UIImage.init(named: "user_photo"))
            meTabHeaderCell.nameLabel.text = accountModel.name
        } else {
            meTabHeaderCell.userImageView.image = UIImage.init(named: "user_photo")
            meTabHeaderCell.nameLabel.text = "未登录"
        }
    }
    
    //MARK: Action
    @objc private func headerImageClick(tapGesture: UITapGestureRecognizer) {
        if AccountManager.shared.toLoginIfNeed(self) {
            return //去登录界面了
        }
        let modifyViewController = ModifyViewController()
        modifyViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(modifyViewController, animated: true)
    }
    
    //MARK: Notification
    @objc func accountLogin(notification: Notification) {
        //用户登录成功
        let accountModel: AccountModel = notification.object as! AccountModel
        setDataUI(accountModel: accountModel)
    }
    
    @objc func accountModify(notification: Notification) {
        //用户修改资料
        let accountModel: AccountModel = notification.object as! AccountModel
        setDataUI(accountModel: accountModel)
    }
    
    @objc func accountLogout(notification: Notification) {
        //用户退出登录
        setDataUI(accountModel: nil)
    }
    
    //MARK: UIScrollViewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = super.tableView(tableView, cellForRowAt: indexPath) as! MeTabCell
        if #available(iOS 11, *) {
            let numberOfRows = self.tableKitSections[indexPath.section].numberOfRows;
            if numberOfRows == 1 {
                // single
                cell.bgView.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue | CACornerMask.layerMinXMaxYCorner.rawValue | CACornerMask.layerMaxXMaxYCorner.rawValue)
            } else {
                // mutable
                switch indexPath.row {
                case 0:
                    // 上两圆角
                    cell.bgView.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue)
                case numberOfRows - 1:
                    // 下两圆角
                    cell.bgView.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMaxYCorner.rawValue | CACornerMask.layerMaxXMaxYCorner.rawValue)
                default:
                    //中部
                    cell.bgView.layer.maskedCorners = CACornerMask(rawValue: 0); // middle
                }
            }
        }

        return cell
    }
    
    //MARK:UIScrollViewDelegate
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let contentOffsetY = scrollView.contentOffset.y
//        let showNavBarOffsetY = CGFloat(0)
//
//        print("topLayoutGuide.length ",topLayoutGuide.length)
//
//        //navigationBar alpha
//        if contentOffsetY > showNavBarOffsetY  {
//            var navAlpha = (contentOffsetY - (showNavBarOffsetY)) / 40.0
//            if navAlpha > 1 {
//                navAlpha = 1
//            }
//            navBarBgAlpha = navAlpha
//            if navAlpha > 0.8 {
//
//            }else{
//            }
//        }else{
//            navBarBgAlpha = 0
//        }
//        setNeedsStatusBarAppearanceUpdate()
//    }
}

//extension MeTabViewController {
//
//    fileprivate struct AssociatedKeys {
//        static var navBarBgAlpha: CGFloat = 1.0
//    }
//
//    open var navBarBgAlpha: CGFloat {
//        get {
//            guard let alpha = objc_getAssociatedObject(self, &AssociatedKeys.navBarBgAlpha) as? CGFloat else {
//                return 1.0
//            }
//            return alpha
//
//        }
//        set {
//            let alpha = max(min(newValue, 1), 0) // 必须在 0~1的范围
//
//            objc_setAssociatedObject(self, &AssociatedKeys.navBarBgAlpha, alpha, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//
//            // Update UI
//            setNeedsNavigationBackground(alpha: alpha)
//        }
//    }
//
//
//    fileprivate func setNeedsNavigationBackground(alpha: CGFloat) {
//        if let barBackgroundView = self.navigationController!.navigationBar.subviews.first {
//            let valueForKey = barBackgroundView.getIvar(forKey:)
//
//            if let shadowView = valueForKey("_shadowView") as? UIView {
//                shadowView.alpha = alpha
//                shadowView.isHidden = alpha == 0
//            }
//
//            if self.navigationController!.navigationBar.isTranslucent {
//                if #available(iOS 10.0, *) {
//                    if let backgroundEffectView = valueForKey("_backgroundEffectView") as? UIView, self.navigationController!.navigationBar.backgroundImage(for: .default) == nil {
//                        backgroundEffectView.alpha = alpha
//                        return
//                    }
//
//                } else {
//                    if let adaptiveBackdrop = valueForKey("_adaptiveBackdrop") as? UIView , let backdropEffectView = adaptiveBackdrop.value(forKey: "_backdropEffectView") as? UIView {
//                        backdropEffectView.alpha = alpha
//                        return
//                    }
//                }
//            }
//
//            barBackgroundView.alpha = alpha
//        }
//    }
//}
//
//extension NSObject {
//    func getIvar(forKey key: String) -> Any? {
//        guard let _var = class_getInstanceVariable(type(of: self), key) else {
//            return nil
//        }
//
//        return object_getIvar(self, _var)
//    }
//}
