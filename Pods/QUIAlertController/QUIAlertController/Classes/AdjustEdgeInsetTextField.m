//
//  QAlertViewController
//
//  Created by QDong on 2022-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import "AdjustEdgeInsetTextField.h"


@interface AdjustEdgeInsetTextField ()

@end

@implementation AdjustEdgeInsetTextField

#pragma mark - Positioning Overrides

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds = CGRectInsetEdges(bounds, self.textInsets);
    CGRect resultRect = [super textRectForBounds:bounds];
    return resultRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = CGRectInsetEdges(bounds, self.textInsets);
    return [super editingRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect result = [super clearButtonRectForBounds:bounds];
    result = CGRectOffset(result, self.clearButtonPositionAdjustment.horizontal, self.clearButtonPositionAdjustment.vertical);
    return result;
}

/// 为给定的rect往内部缩小insets的大小（系统那个方法的命名太难联想了，所以定义了一个新函数）
CG_INLINE CGRect
CGRectInsetEdges(CGRect rect, UIEdgeInsets insets) {
    return UIEdgeInsetsInsetRect(rect, insets);
}

@end
