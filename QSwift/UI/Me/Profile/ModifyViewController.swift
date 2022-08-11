//
//  LoginDemoController.swift
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 gamin.com. All rights reserved.
//

import UIKit
import QTableKit
import QUIAlertController
import SVProgressHUD

class ModifyViewController: CommonTableKitViewController {
    
    private var nameTableKitRow: TableKitRow<TableKitLabelKVCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "修改资料界面"
        
        let section = TableKitSection(headerTitle: "TextFieldCell的HeaderTitle", footerTitle: nil)
        self.tableKitSections.append(section)
        
        createNickNameRow()
    }
    
    private func createNickNameRow(){
        //创建cell的Model
        let nameTkModel = TableKitLabelKVModel()
        nameTkModel.title = "昵称"
        nameTkModel.value = AccountManager.shared.accountModel?.name
        
        //创建Cell的点击事件
        let cellClickAction = TableRowAction<TableKitLabelKVCell>(.click) {  [weak self] (options :TableRowActionCallback<TableKitLabelKVCell>) in

            guard let `self` = self else { return }
            self.showNickNameAlert()
        }
        
        //创建cell，并绑定cell的Model+点击事件
        nameTableKitRow = TableKitRow<TableKitLabelKVCell>(item: nameTkModel, actions: [cellClickAction])
        self.tableKitSections[0].append(row: nameTableKitRow)
    }
    
    private func showNickNameAlert(){
        // Alert弹框 + UITextField
        let alertController = QUIAlertController(title: "请输入昵称", message: "不超过20个字符", preferredStyle: .alert)
        
        alertController.addAction(QUIAlertAction(title: "确定", style: .destructive, handler: { [weak self] alertController, action in
            
            guard let `self` = self else { return }
            
            if let text = alertController.textFields![0].text , !text.isEmpty {
                
                //为了用户体验，先更新本地UI
                self.nameTableKitRow.dataModel.value = text
                
                var reloadIndexPaths: [IndexPath] = []
                let indexPath = IndexPath(row: 0, section: 0)
                reloadIndexPaths.append(indexPath)
                self.tableView.reloadRows(at: reloadIndexPaths, with: .none)
                
                //提交给服务器
                var params = [String: String]()
                params["name"] = text
                params["userid"] = AccountManager.shared.safeUserId()
                self.executeModify(params: params)
            }
        }))
        alertController.addCancelAction()
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "昵称"
        })
        
        // 输入框的布局默认是贴在一起的，默认不需要修改，这里只是展示可以通过这个 block 自行调整。
        alertController.alertTextFieldMarginBlock = { alertController, aTextFieldIndex in
            var margin: UIEdgeInsets = .zero
            if aTextFieldIndex == alertController.textFields!.count - 1 {
                margin.bottom = 16
            } else {
                margin.bottom = 6
            }
            return margin
        }
        
        alertController.showWith(animated: true)
    }
    
    //提交给服务器
    private func executeModify(params: [String: String]){
        
        HttpManager.shared.request(.post , path: "account/modifyarray", params: params, success: { [weak self] (response : BaseResponse<AccountModel>) in
            
            if response.isSuccess() {
                //保存
                AccountManager.shared.storeAccountModel(newAccountModel: response.data, postNotification: true)
                self?.dismiss(animated: true, completion: nil)
            } else {
                SVProgressHUD.showError(withStatus: response.message)
            }
            
        }, failure: { error in
            //网络请求失败，服务器关闭或者json解析失败
            SVProgressHUD.showError(withStatus: commonNetworkRequestFailure)
        })
    }
    
}
