//
//  QAlertViewController
//
//  Created by QDong on 2022-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIBorderViewHelper : NSObject

/// 获取一像素的大小
@property(class, nonatomic, readonly) CGFloat pixelOne;

/// 边框类型(位移枚举)
typedef NS_ENUM(NSInteger, UIBorderSideType) {
    UIBorderSideTypeAll = 0,
    UIBorderSideTypeTop = 1 << 0,
    UIBorderSideTypeBottom = 1 << 1,
    UIBorderSideTypeLeft = 1 << 2,
    UIBorderSideTypeRight = 1 << 3,
};

+ (UIView *)layerBorderForView:(UIView *)originalview color:(UIColor *)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType;

/**
 设置view指定位置的边框，采用addview的方式
 @return view
 */
+ (UIView *)lineBorderForView:(UIView *)originalview color:(UIColor *)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType;

@end
