//
//  LoginDemoController.swift
//
//  Created by QDong on 2021/2/25.
//  Copyright © 2021 gamin.com. All rights reserved.
//

import UIKit
import QTableKit

class MeSettingController: CommonTableKitViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设置界面"

        let tkSection = TableKitSection(headerTitle: nil, footerTitle: nil)
        let tkButtonModel = TableKitButtonModel(title: "退出登录")
        //点击”退出登录“按钮
        let completeClickAction = TableRowAction<TableKitSingleButtonCell>(.custom(TableKitSingleButtonClicked)) { [weak self] (options :TableRowActionCallback<TableKitSingleButtonCell>) in
            
            guard let `self` = self else { return }
            
            AccountManager.shared.storeAccountModel(newAccountModel: nil, postNotification: true)
            
            self.navigationController?.popViewController(animated: true)
        }
        
        let buttonRow = TableKitRow<TableKitSingleButtonCell>(item: tkButtonModel, actions: [completeClickAction])
        tkSection.append(row: buttonRow)
        
        self.tableKitSections.append(tkSection)
        
    }
    
}
