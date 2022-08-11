//
//  Common+UI.swift
//  QSwift
//
//  Created by QDong on 2021/7/4.
//

import UIKit
import Foundation

// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.size.width;
// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height;

// 状态栏高度
let kStatusBarFrame = UIApplication.shared.statusBarFrame.size.height  //非X是20 X是44
let kIphoneTopNavHeight = 44 + kStatusBarFrame //非X是64 X是98 ，44是导航栏的高度

let commonBackgroundColor = UIColor(red: (248)/255.0, green: (248)/255.0, blue: (246)/255.0, alpha: 1)
let commonWhiteColor = UIColor(red: (248)/255.0, green: (248)/255.0, blue: (248)/255.0, alpha: 1)
let commonSeparatorColor
    = UIColor(red: (220)/255.0, green: (220)/255.0, blue: (220)/255.0, alpha: 1)

let commonBlackColor = UIColor(red: (91)/255.0, green: (91)/255.0, blue: (91)/255.0, alpha: 1)
let commonGrayDarkColor = UIColor(red: (104)/255.0, green: (104)/255.0, blue: (104)/255.0, alpha: 1)
let commonGrayColor = UIColor(red: (145)/255.0, green: (145)/255.0, blue: (145)/255.0, alpha: 1)


// 计算String的高度
func measureHeight(text: String?, maxWidth: CGFloat, font: UIFont?, lineSpacing: CGFloat) -> CGFloat {
    return measureSize(text: text, maxWidth: maxWidth, font: font, lineSpacing: lineSpacing).size.height
}

// 计算String的高度
func measureSize(text: String?, maxWidth: CGFloat, font: UIFont?, lineSpacing: CGFloat) -> CGRect {
    
    guard let text = text else {
        return CGRect.zero
    }
    
    let calSize = CGSize(width: maxWidth, height: CGFloat(MAXFLOAT))

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byWordWrapping
    paragraphStyle.lineSpacing = lineSpacing

    let attributes = [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]
    
    let rect = text.boundingRect(
        with: calSize,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: attributes as [NSAttributedString.Key : Any],
        context: nil)
    
    return rect
}

// 计算AttributedString的高度
func measureSize(attributedString: NSAttributedString?, maxWidth: CGFloat) -> CGSize {
    
    guard let attributedString = attributedString else {
        return CGSize.zero
    }
    
    let frame = attributedString.boundingRect(with: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    
    //+1 是因为我发现NSAttributedString如果有图片，会出现就差1像素就能显示全的bug
    return CGSize.init(width: frame.size.width + 1, height: frame.size.height + 1)
}

