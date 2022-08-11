//
//  UIImageView+Loader.swift
//  TSWeChat
//
//  Created by QDong on 11/6/15.
//  Copyright © 2015 QDong. All rights reserved.
//

import Foundation
import Kingfisher

//为什么要对图片加载进行抽象封装？因为如果哪天换成别的图片加载库，可以很方便统一更换
public extension UIImageView {

    func setImageWithURLString(_ URLString: String?, placeholderImage placeholder: UIImage? = nil) {
        guard let URLString = URLString else {
            image = placeholder
            return
        }
        setImageWithURL(URL(string: URLString), placeholderImage: placeholder)
    }
    
    func setImageWithURL(_ url: URL?, placeholderImage placeholder: UIImage? = nil) {
        guard let url = url else {
            image = placeholder
            return
        }
        setImageWithURL(url, placeholderImage: placeholder, options: [
            .transition(.fade(1))
        ])
    }
    
    func setImageWithURL(_ url: URL?, placeholderImage placeholder: UIImage? = nil, options: KingfisherOptionsInfo? = nil) {
        guard let url = url else {
            image = placeholder
            return
        }
        self.kf.setImage(with: url, placeholder: placeholder, options: options)
    }

}



