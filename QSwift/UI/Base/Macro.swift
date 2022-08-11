//
//  GAConfigurationFile.swift
//  GASimpleStructDemo
//
//  Created by Gamin on 2020/2/26.
//  Copyright © 2020 gamin.com. All rights reserved.
//

import UIKit
import Foundation


let QINIU_URL = "https://qiniu.itopic.com.cn/" //七牛链接

let DOMAIN_API_URL = "https://api.itopic.com.cn/api/"

let commonNetworkRequestFailure = "服务器出问题了"

// APPID
let APP_ID = "";

// 评价跳转
func APP_OPEN_EVALUATE_IOS11() -> (String) {
    return "itms-apps://itunes.apple.com/cn/app/id" + APP_ID + "?mt=8&action=write-review";
}
