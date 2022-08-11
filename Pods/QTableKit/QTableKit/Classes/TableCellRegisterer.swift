//
//  QAlertViewController
//
//  Created by QDong on 2021-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

import UIKit

open class TableCellRegisterer {

    private var registeredIds = Set<String>()
    private weak var tableView: UITableView?
    
    public init(tableView: UITableView?) {
        self.tableView = tableView
    }
    
    open func register(cellType: AnyClass, forCellReuseIdentifier reuseIdentifier: String) {
        
        if registeredIds.contains(reuseIdentifier) {
            return
        }
        
        // check if cell is already registered, probably cell has been registered by storyboard
        if tableView?.dequeueReusableCell(withIdentifier: reuseIdentifier) != nil {
            
            registeredIds.insert(reuseIdentifier)
            return
        }
        
        let bundle = Bundle(for: cellType)
        
        // we hope that cell's xib file has name that equals to cell's class name
        // in that case we could register nib
        if let _ = bundle.path(forResource: reuseIdentifier, ofType: "nib") {
            tableView?.register(UINib(nibName: reuseIdentifier, bundle: bundle), forCellReuseIdentifier: reuseIdentifier)
        // otherwise, register cell class
        } else {
            tableView?.register(cellType, forCellReuseIdentifier: reuseIdentifier)
        }
        
        registeredIds.insert(reuseIdentifier)
    }
}
