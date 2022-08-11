//
//  QUIEmptyView.swift
//  QSwift
//
//  Created by QDong on 2021/3/25.
//

import Foundation
import UIKit


class CommonUILoadingView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInitialized()
    }
    
    
    private func didInitialized(){
        
        let shapeView1 = UIView(frame: CGRect(x: 0, y: 7, width: 16, height: 16))
        shapeView1.backgroundColor = UIColor(red: 0.62, green: 0.84, blue: 0.38, alpha: 1.00)
        shapeView1.layer.cornerRadius = 8
        self.addSubview(shapeView1)

        let shapeView2 = UIView(frame: CGRect(x: 0, y: 7, width: 16, height: 16))
        shapeView2.backgroundColor = UIColor(red: 0.19, green: 0.74, blue: 0.95, alpha: 1.00)
        shapeView2.layer.cornerRadius = 8
        self.addSubview(shapeView2)
        
        let shapeView3 = UIView(frame: CGRect(x: 0, y: 7, width: 16, height: 16))
        shapeView3.backgroundColor = UIColor(red: 1.0, green: 0.81, blue: 0.28, alpha: 1.00)
        shapeView3.layer.cornerRadius = 8
        self.addSubview(shapeView3)
        
        let positionAnimation = CAKeyframeAnimation()
        positionAnimation.keyPath = "position.x"
        positionAnimation.values = [NSNumber(value: -5), NSNumber(value: 0), NSNumber(value: 10), NSNumber(value: 40), NSNumber(value: 70), NSNumber(value: 80), NSNumber(value: 75)]
        positionAnimation.keyTimes = [NSNumber(value: 0), NSNumber(value: 5 / 90.0), NSNumber(value: 15 / 90.0), NSNumber(value: 45 / 90.0), NSNumber(value: 75 / 90.0), NSNumber(value: 85 / 90.0), NSNumber(value: 1)]
        positionAnimation.isAdditive = true
        
        let scaleAnimation = CAKeyframeAnimation()
        scaleAnimation.keyPath = "transform.scale"
        scaleAnimation.values = [NSNumber(value: 0.7), NSNumber(value: 0.9), NSNumber(value: 1), NSNumber(value: 0.9), NSNumber(value: 0.7)]
        scaleAnimation.keyTimes = [NSNumber(value: 0), NSNumber(value: 15 / 90.0), NSNumber(value: 45 / 90.0), NSNumber(value: 75 / 90.0), NSNumber(value: 1)]

        let alphaAnimation = CAKeyframeAnimation()
        alphaAnimation.keyPath = "opacity"
        alphaAnimation.values = [NSNumber(value: 0), NSNumber(value: 1), NSNumber(value: 1), NSNumber(value: 1), NSNumber(value: 0)]
        alphaAnimation.keyTimes = [NSNumber(value: 0), NSNumber(value: 1 / 6.0), NSNumber(value: 3 / 6.0), NSNumber(value: 5 / 6.0), NSNumber(value: 1)]
        
        let group = CAAnimationGroup()
        group.animations = [positionAnimation, scaleAnimation, alphaAnimation]
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        group.repeatCount = MAXFLOAT
        group.duration = 1.3
        group.isRemovedOnCompletion = false; //不设置这个的话，页面disAppear后就动画暂停了
        
        shapeView1.layer.add(group, forKey: "basic1")
        group.timeOffset = 0.43
        
        shapeView2.layer.add(group, forKey: "basic2")
        group.timeOffset = 0.86
        shapeView3.layer.add(group, forKey: "basic3")
    }

}
