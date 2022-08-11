//
//  LoginDemoController.swift
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 gamin.com. All rights reserved.
//

import UIKit
import QTableKit
import SVProgressHUD

class AccountLoginViewController: CommonTableKitViewController {
    
    private var nameTableKitRow: TableKitRow<TableKitTextFieldCell>!
    private var passwordTableKitRow: TableKitRow<TableKitTextFieldCell>!
    private var switchTableKitRow: TableKitRow<TableKitSwitchCell>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "登录界面"
        
        createPhoneRow()
        createPasswordRow()
        createSwitchRow()
        
        let tkSection = TableKitSection(headerTitle: nil, footerTitle: nil)
        let tkButtonModel = TableKitButtonModel(title: "确定")
        //点击”确定“按钮
        let completeClickAction = TableRowAction<TableKitSingleButtonCell>(.custom(TableKitSingleButtonClicked)) { [weak self] (options :TableRowActionCallback<TableKitSingleButtonCell>) in
            
            guard let `self` = self else { return }
            
            self.view.endEditing(true)
            
            print("nameTkModel_value = ", self.nameTableKitRow.dataModel.value ?? "")
            print("passwordTkModel_value = ", self.passwordTableKitRow.dataModel.value ?? "")
            print("switchTkModel_value = ", self.switchTableKitRow.dataModel.isOn)
            
            SVProgressHUD.show(withStatus: "登录中...")
            
            var params = [String: String]()
            params["mobile"] = self.nameTableKitRow.dataModel.value!
            params["password"] = self.passwordTableKitRow.dataModel.value!
            
            HttpManager.shared.request(.post , path: "account/login", params: params, success: { [weak self] (response : BaseResponse<AccountModel>) in
                
                SVProgressHUD.dismiss()
                if response.isSuccess() {
                    //保存
                    AccountManager.shared.storeAccountModel(newAccountModel: response.data, postNotification: true)
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    SVProgressHUD.showError(withStatus: response.message)
                }
                
            }, failure: { error in
                
                //网络请求失败，服务器关闭或者json解析失败
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: commonNetworkRequestFailure)
            })
        }
        let buttonRow = TableKitRow<TableKitSingleButtonCell>(item: tkButtonModel, actions: [completeClickAction])
        tkSection.append(row: buttonRow)
        
        self.tableKitSections.append(tkSection)
        
    }
    
    //添加"账号" UITableViewCell
    func createPhoneRow(){
        let nameTkModel = TableKitTextFieldModel()
        nameTkModel.title = "账号"
        nameTkModel.placeHolder = "请输入账号"
        nameTkModel.value = "13810244766"
        
        //Cell点击事件
        let cellClickAction = TableRowAction<TableKitTextFieldCell>(.click) { (options :TableRowActionCallback<TableKitTextFieldCell>) in
            options.cell?.textField.becomeFirstResponder()
        }
        
        //cell里的TextField的文本编辑事件
        let textFieldEditAction = TableRowAction<TableKitTextFieldCell>(.custom(TKTextFieldEditingChangedKey)) { (options :TableRowActionCallback<TableKitTextFieldCell>) in
            //options.dataModel 就是 nameTkModel
            print("vc收到账号输入框变化1 = ",options.dataModel.value!)
        }
        
        let section = TableKitSection(headerTitle: "TextFieldCell的HeaderTitle", footerTitle: nil)
        self.nameTableKitRow = TableKitRow<TableKitTextFieldCell>(item: nameTkModel, actions: [cellClickAction, textFieldEditAction])
        section.append(row: self.nameTableKitRow)
        self.tableKitSections.append(section)
    }

    
    //添加"密码" TextFieldCell
    func createPasswordRow(){
        let nameTkModel = TableKitTextFieldModel()
        nameTkModel.title = "密码"
        nameTkModel.placeHolder = "请输入密码"
        nameTkModel.secureTextEntry = true
        nameTkModel.value = "123"
        
        //Cell点击事件
        let cellClickAction = TableRowAction<TableKitTextFieldCell>(.click) { (options :TableRowActionCallback<TableKitTextFieldCell>) in
            options.cell?.textField.becomeFirstResponder()
        }
        
        //cell里的TextField的文本编辑事件
        let textFieldEditAction = TableRowAction<TableKitTextFieldCell>(.custom(TKTextFieldEditingChangedKey)) { (options :TableRowActionCallback<TableKitTextFieldCell>) in
            //options.dataModel 和 nameTkModel是同一个变量
            print("vc收到密码输入框变化1 = ",options.dataModel.value!)
//            nameTkModel.value = options.item.value ?? ""
            print("vc收到密码输入框变化2 = ",nameTkModel.value ?? "")
        }
        
        let section = TableKitSection(headerTitle: "TextFieldCell的HeaderTitle", footerTitle: nil)
        self.passwordTableKitRow = TableKitRow<TableKitTextFieldCell>(item: nameTkModel, actions: [cellClickAction, textFieldEditAction])
        section.append(row: self.passwordTableKitRow)
        self.tableKitSections.append(section)
    }
    
    //添加"开源" SwitchCell
    func createSwitchRow() {
        let switchTkModel = TableKitSwitchModel()
        switchTkModel.title = "显示密码"
        
        //Cell点击事件
        let cellClickAction = TableRowAction<TableKitSwitchCell>(.click) {  [weak self] (options :TableRowActionCallback<TableKitSwitchCell>) in
            options.dataModel.isOn = !options.dataModel.isOn
            options.cell?.uiSwitch.isOn = options.dataModel.isOn
            
            guard let `self` = self else { return }
            
            self.passwordTableKitRow.dataModel.secureTextEntry = options.dataModel.isOn
            
            var reloadIndexPaths: [IndexPath] = []
            let indexPath = IndexPath(row: 0, section: 1)
            reloadIndexPaths.append(indexPath)
            self.tableView.reloadRows(at: reloadIndexPaths, with: .fade)
        }
        
        //cell里的TextField的文本编辑事件
        let switchAction = TableRowAction<TableKitSwitchCell>(.custom(TKSwitchValueChangedKey)) { [weak self] (options :TableRowActionCallback<TableKitSwitchCell>) in
            
            guard let `self` = self else { return }
            //options.dataModel 和 switchTkModel是同一个变量
            print("vc收到UISwitch变化方式1 = ",options.dataModel.isOn)
//            nameTkModel.value = options.item.value ?? ""
            print("vc收到UISwitch变化方式2 = ",switchTkModel.isOn)
            self.passwordTableKitRow.dataModel.secureTextEntry = options.dataModel.isOn
            
            var reloadIndexPaths: [IndexPath] = []
            let indexPath = IndexPath(row: 0, section: 1)
            reloadIndexPaths.append(indexPath)
            self.tableView.reloadRows(at: reloadIndexPaths, with: .fade)
        }
        
        let section = TableKitSection(headerTitle: "TextFieldCell的HeaderTitle", footerTitle: nil)
        self.switchTableKitRow = TableKitRow<TableKitSwitchCell>(item: switchTkModel, actions: [cellClickAction, switchAction])
        section.append(row: self.switchTableKitRow)
        self.tableKitSections.append(section)
    }
}
