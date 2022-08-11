//
//  QAlertViewController
//
//  Created by QDong on 2022-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdjustEdgeInsetTextField : UITextField

/**
 *  文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距
 *
 *  默认为 TextFieldTextInsets
 */
@property(nonatomic, assign) UIEdgeInsets textInsets;

/**
 clearButton 在默认位置上的偏移
 */
@property(nonatomic, assign) UIOffset clearButtonPositionAdjustment UI_APPEARANCE_SELECTOR;


@end
