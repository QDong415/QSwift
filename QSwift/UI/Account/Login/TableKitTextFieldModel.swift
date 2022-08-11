//
//  TableKitTextFieldModel.swift
//  TableKitDemo
//
//  Created by QDong on 2021/6/3.
//  Copyright © 2021 Tablet. All rights reserved.
//

import Foundation
import UIKit

//这个TableKitTextFieldCell对应的Model，只能用class，不要用struct；因为struct会在TableKitRow里产生一个无用的深copy
class TableKitTextFieldModel {
        
    var title: String?
    var value: String?
    
    var secureTextEntry: Bool = false
    var placeHolder: String?
    var keyboardType: UIKeyboardType = UIKeyboardType.default
    var textAlignment: NSTextAlignment = NSTextAlignment.right
}
