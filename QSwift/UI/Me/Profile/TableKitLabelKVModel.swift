//
//  LabelModel.swift
//  QSwift
//
//  Created by QDong on 2021/11/6.
//

import Foundation
import QTableKit

//这个LabelXibAutoCell对应的Model，建议用class，不建议用struct；因为struct会在TableKitRow里产生一个无用的深copy
class TableKitLabelKVModel {
        
    var title: String?
    var value: String?
}
