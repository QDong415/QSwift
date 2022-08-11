//
//  TableKitSwitchModel.swift
//  TableKitDemo
//
//  Created by QDong on 2021/6/3.
//  Copyright © 2021 Tablet. All rights reserved.
//

import Foundation
import UIKit

//这个TableKitSwitchCell对应的Model，只能用class，不要用struct；因为struct会在TableKitRow里产生一个无用的深copy
class TableKitSwitchModel {
        
    var title: String?
    
    var isOn: Bool = false

}
