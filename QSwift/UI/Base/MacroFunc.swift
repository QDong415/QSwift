//
//  Common+UI.swift
//  QSwift
//
//  Created by QDong on 2021/7/4.
//

import Foundation

// Print log
func printLog<T>(_ message: T,
              file: String = #file,
              method: String = #function,
              line: Int = #line)
{
    #if DEBUG
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm:ss.SSS"
        let time = dateformatter.string(from: Date())
        print("【\(time)】 \((file as NSString).lastPathComponent)[\(line)], \(method): ", message)
    #endif
}

// 根据图片name拼接完整的图片url
func fileUrlString(_ name: String?) -> String? {
    if name == nil || name!.isEmpty || name!.hasPrefix("http") {
        return nil
    }
    return QINIU_URL + name!
}
