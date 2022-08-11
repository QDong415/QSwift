//
//  QUIEmptyView.swift
//  QSwift
//
//  Created by QDong on 2021/3/25.
//

import Foundation
import UIKit

//图片宽高
let emptyImageViewWidth = CGFloat(140.0)
let emptyImageViewHeight = CGFloat(140.0)
let emptyImageViewPaddingBottom = CGFloat(24) //图片底部间距

let emptyTitleLabelPaddingLeftRight = CGFloat(30) //titleLabel左右间距
//let emptyTitleLabelPaddingBottom = CGFloat(24) //titleLabel底部间距

let contentViewVerticalOffset = CGFloat(-10); // 如果不想要内容整体垂直居中，则可通过调整此属性来进行垂直偏移，即内容比中间略微偏上（但其实最后一个控件的bottompadding已经有一些这种效果了，所以这个数字不需要写太大）

//  通用的空界面控件，支持显示 loading、标题和副标题提示语、占位图片。
class CommonUIEmptyView: UIView {
    // 布局顺序从上到下依次为：imageView, textLabel

    private(set) var imageView: UIImageView?
    private(set) var textLabel: UILabel?
    private(set) var actionButton: UIButton?
    
    //  如果要继承QMUIEmptyView并添加新的子 view，则必须：
    //  1. 像其它自带 view 一样添加到 contentView 上
    //  2. 重写sizeThatContentViewFits
    private(set) var contentView: UIView = {
        UIView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialized()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInitialized()
    }
    
    private func didInitialized(){
        print("创建QUIEmptyView")

        addSubview(contentView)

        //dqtodo
//        loadingView = UIActivityIndicatorView(style: .gray) as? UIView & QMUIEmptyViewLoadingViewProtocol
////        (loadingView as? UIActivityIndicatorView)?.hidesWhenStopped = false // 此控件是通过loadingView.hidden属性来控制显隐的，如果UIActivityIndicatorView的hidesWhenStopped属性设置为YES的话，则手动设置它的hidden属性就会失效，因此这里要置为NO
//        contentView.addSubview(loadingView)

        imageView = UIImageView()
        imageView!.contentMode = .center
        imageView!.clipsToBounds = true
        contentView.addSubview(imageView!)

        textLabel = UILabel()
        textLabel!.textAlignment = .center
        textLabel!.numberOfLines = 0
        //为了适配ios11的黑夜模式
        if #available(iOS 11, *) {
            textLabel!.textColor = UIColor.init(named: "text_gray");
        } else {
            textLabel!.textColor = UIColor(red: (145)/255.0, green: (145)/255.0, blue: (145)/255.0, alpha: 1)
        }
        contentView.addSubview(textLabel!)

        actionButton = UIButton()
        contentView.addSubview(actionButton!)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let contentViewWidth = self.bounds.width

        var currentOriginY: CGFloat = 0

        if imageView?.isHidden == false {
            imageView?.frame = CGRect(x: (contentViewWidth - emptyImageViewWidth)/2, y: 0, width: emptyImageViewWidth, height: emptyImageViewHeight)
            currentOriginY = (imageView?.frame.maxY)! + emptyImageViewPaddingBottom
        }
        
        if textLabel?.isHidden == false {
            let textLabelWidth = contentViewWidth - emptyTitleLabelPaddingLeftRight - emptyTitleLabelPaddingLeftRight
            let textLabelHeight = textLabel?.sizeThatFits(CGSize(width: textLabelWidth, height: CGFloat.greatestFiniteMagnitude)).height ?? 0.0
            
            textLabel?.frame = CGRect(x: emptyTitleLabelPaddingLeftRight, y: currentOriginY, width: textLabelWidth, height: textLabelHeight)//CGFloat.max
            currentOriginY = (textLabel?.frame.maxY)! + emptyImageViewPaddingBottom
        }
        
        // contentView 默认垂直居中于 CommonUIEmptyView
        contentView.frame = CGRect(x: 0, y: self.bounds.midY - currentOriginY / 2 + contentViewVerticalOffset, width: contentViewWidth, height: currentOriginY)
    }
    
    func setImage(_ image: UIImage?) {
        imageView?.image = image
        imageView?.isHidden = image == nil
    }

    func setTextLabelText(_ text: String?) {
        textLabel?.text = text
        textLabel?.isHidden = text == nil
    }
    
    func sharkImageView() {
        guard let imageView = imageView else { return }
        let rotate = CGAffineTransform(rotationAngle: -0.2)
        let stretchAndRotate = rotate.scaledBy(x: 0.5, y: 0.5)
        imageView.transform = stretchAndRotate
        imageView.alpha = 0.5
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping:  0.45, initialSpringVelocity: 10.0, options:[.curveEaseOut], animations: {
            imageView.alpha = 1.0
            let rotate = CGAffineTransform(rotationAngle: 0.0)
            let stretchAndRotate = rotate.scaledBy(x: 1.0, y: 1.0)
            imageView.transform = stretchAndRotate
            
        }, completion: nil)
    }
}
