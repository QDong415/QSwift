//
//  QAlertViewController
//
//  Created by QDong on 2022-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import "UIBorderViewHelper.h"

@interface BoardShapeLayer : CAShapeLayer

@end


@implementation BoardShapeLayer : CAShapeLayer

@end


@interface BoardShapeView : UIView

@end


@implementation BoardShapeView : UIView

@end


@interface UIBorderViewHelper ()


@end


@implementation UIBorderViewHelper

static CGFloat pixelOne = -1.0f;
+ (CGFloat)pixelOne {
    if (pixelOne < 0) {
        pixelOne = 1 / [[UIScreen mainScreen] scale];
    }
    return pixelOne;
}

/**
 设置view指定位置的边框，采用addLayer的方式
 
 @param originalview 原view
 @param color   边框颜色
 @param borderWidth 边框宽度
 @param borderType  边框类型 例子: UIBorderSideTypeTop|UIBorderSideTypeBottom
 @return view
 */
+ (UIView *)layerBorderForView:(UIView *)originalview color:(UIColor *)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType {
    
    for (CALayer *layer in originalview.layer.sublayers) {
        if ([layer isKindOfClass:[BoardShapeLayer class]]){
            [layer removeFromSuperlayer];
            break;
        }
    }

    /// 线的路径
    UIBezierPath * bezierpath = [UIBezierPath bezierPath];

    /// 左侧
    if (borderType & UIBorderSideTypeLeft) {
        /// 左侧线路径
        [bezierpath moveToPoint:CGPointMake(0.0f, originalview.frame.size.height)];
        [bezierpath addLineToPoint:CGPointMake(0.0f, 0.0f)];
    }

    /// 右侧
    if (borderType & UIBorderSideTypeRight) {
        /// 右侧线路径
        [bezierpath moveToPoint:CGPointMake(originalview.frame.size.width, 0.0f)];
        [bezierpath addLineToPoint:CGPointMake( originalview.frame.size.width, originalview.frame.size.height)];
    }

    /// top
    if (borderType & UIBorderSideTypeTop) {
        /// top线路径
        [bezierpath moveToPoint:CGPointMake(0.0f, 0.0f)];
        [bezierpath addLineToPoint:CGPointMake(originalview.frame.size.width, 0.0f)];
    }

    /// bottom
    if (borderType & UIBorderSideTypeBottom) {
        /// bottom线路径
        [bezierpath moveToPoint:CGPointMake(0.0f, originalview.frame.size.height)];
        [bezierpath addLineToPoint:CGPointMake( originalview.frame.size.width, originalview.frame.size.height)];
    }

    BoardShapeLayer * shapelayer = [BoardShapeLayer layer];
    shapelayer.strokeColor = color.CGColor;
    shapelayer.fillColor = color.CGColor;//[UIColor clearColor].CGColor;
    shapelayer.lineWidth = borderWidth;
    /// 添加路径
    shapelayer.path = bezierpath.CGPath;

    [originalview.layer addSublayer:shapelayer];

    return originalview;
}

- (void)q_bringSublayerToFrontView:(UIView *)targetView targetLayer:(CALayer *)sublayer {
    [targetView.layer insertSublayer:sublayer atIndex:(unsigned int)targetView.layer.sublayers.count];
}

/**
 设置view指定位置的边框，采用addview的方式
 @return view
 */
+ (UIView *)lineBorderForView:(UIView *)originalview color:(UIColor *)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType {
    
    for (UIView *subView in originalview.subviews) {
        if ([subView isKindOfClass:[BoardShapeView class]]){
//            [subView removeFromSuperview];
            //已经添加过border了就return。这里判断并不严谨，无法二次setBorder，但是为了代码执行效率，先这样解决
            return originalview;
        }
    }

    /// 左侧
    if (borderType & UIBorderSideTypeLeft) {
        /// 左侧线路径
        BoardShapeView *lineView = [[BoardShapeView alloc] initWithFrame:CGRectMake(0, 0, borderWidth, originalview.frame.size.height)];
        lineView.backgroundColor = color;

        [originalview addSubview:lineView];
    }

    /// 右侧
    if (borderType & UIBorderSideTypeRight) {
        /// 右侧线路径
        BoardShapeView *lineView = [[BoardShapeView alloc] initWithFrame:CGRectMake(originalview.frame.size.width - borderWidth, 0, borderWidth, originalview.frame.size.height)];
        lineView.backgroundColor = color;

        [originalview addSubview:lineView];
    }

    /// top
    if (borderType & UIBorderSideTypeTop) {
        /// top线路径
        BoardShapeView *lineView = [[BoardShapeView alloc] initWithFrame:CGRectMake(0, 0, originalview.frame.size.width, borderWidth)];
        lineView.backgroundColor = color;

        [originalview addSubview:lineView];
    }

    /// bottom
    if (borderType & UIBorderSideTypeBottom) {
        /// bottom线路径
        BoardShapeView *lineView = [[BoardShapeView alloc] initWithFrame:CGRectMake(0, originalview.frame.size.height - borderWidth, originalview.frame.size.width, borderWidth)];
        lineView.backgroundColor = color;

        [originalview addSubview:lineView];
    }

    
    return originalview;
}



@end
