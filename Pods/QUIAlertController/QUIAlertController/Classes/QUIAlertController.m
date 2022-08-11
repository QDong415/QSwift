//
//  QAlertViewController
//
//  Created by QDong on 2022-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import "QUIAlertController.h"
#import "QUIButton.h"
#import "AdjustEdgeInsetTextField.h"
#import "UIBorderViewHelper.h"

static NSUInteger alertControllerCount = 0;

#define QUIViewAnimationOptionsCurveOut (7<<16)
#define QUIViewAnimationOptionsCurveIn (8<<16)


#pragma mark - QUIAlertAction

@protocol QUIAlertActionDelegate <NSObject>

- (void)didClickAlertAction:(QUIAlertAction *)alertAction;

@end

@interface QUIAlertAction ()

@property(nonatomic, copy, readwrite) NSString *title;
@property(nonatomic, assign, readwrite) QUIAlertActionStyle style;
@property(nonatomic, copy) void (^handler)(QUIAlertController *aAlertController, QUIAlertAction *action);
@property(nonatomic, weak) id<QUIAlertActionDelegate> delegate;

@end

@implementation QUIAlertAction

+ (nonnull instancetype)actionWithTitle:(nullable NSString *)title style:(QUIAlertActionStyle)style handler:(void (^)(__kindof QUIAlertController *, QUIAlertAction *))handler {
    QUIAlertAction *alertAction = [[self alloc] init];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _button = [[QUIButton alloc] init];
        self.button.adjustsButtonWhenDisabled = NO;
        self.button.adjustsButtonWhenHighlighted = NO;
//        self.button.q_automaticallyAdjustTouchHighlightedInScrollView = YES;
        [self.button addTarget:self action:@selector(handleAlertActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.button.enabled = enabled;
}

- (void)handleAlertActionEvent:(id)sender {
    // 需要先调delegate，里面会先恢复keywindow
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAlertAction:)]) {
        [self.delegate didClickAlertAction:self];
    }
}

@end


#pragma mark - QUIAlertController
@interface QUIAlertController () <QUIAlertActionDelegate, QUIModalPresentationContentViewControllerProtocol, QUIModalPresentationViewControllerDelegate, UITextFieldDelegate>

@property(nonatomic, assign, readwrite) QUIAlertControllerStyle preferredStyle;
@property(nonatomic, strong, readwrite) QUIModalPresentationViewController *modalPresentationViewController;

@property(nonatomic, strong) UIView *containerView;

@property(nonatomic, strong) UIControl *maskView;

@property(nonatomic, strong) UIView *scrollWrapView;
@property(nonatomic, strong) UIScrollView *headerScrollView;
@property(nonatomic, strong) UIScrollView *buttonScrollView;

@property(nonatomic, strong) CALayer *extendLayer;

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *messageLabel;
@property(nonatomic, strong) QUIAlertAction *cancelAction;

@property(nonatomic, strong) NSMutableArray<QUIAlertAction *> *alertActions;
@property(nonatomic, strong) NSMutableArray<QUIAlertAction *> *destructiveActions;
@property(nonatomic, strong) NSMutableArray<UITextField *> *alertTextFields;

@property(nonatomic, assign) CGFloat keyboardHeight;

/// 调用 showWithAnimated 时置为 YES，在 show 动画结束时置为 NO
@property(nonatomic, assign) BOOL willShow;

/// 在 show 动画结束时置为 YES，在 hide 动画结束时置为 NO
@property(nonatomic, assign) BOOL showing;

// 保护 showing 的过程中调用 hide 无效
@property(nonatomic, assign) BOOL isNeedsHideAfterAlertShowed;
@property(nonatomic, assign) BOOL isAnimatedForHideAfterAlertShowed;

@end

@implementation QUIAlertController {
    NSString            *_title;
    BOOL _needsUpdateAction;
    BOOL _needsUpdateTitle;
    BOOL _needsUpdateMessage;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    
    [self initAppearance];
    
    self.alertTextFieldMarginBlock = ^UIEdgeInsets(__kindof QUIAlertController *aAlertController, NSInteger aTextFieldIndex) {
        if (aTextFieldIndex == aAlertController.textFields.count - 1) {
            return UIEdgeInsetsMake(0, 0, 16, 0);
        }
        return UIEdgeInsetsZero;
    };
    self.shouldManageTextFieldsReturnEventAutomatically = YES;
}


- (NSMutableParagraphStyle *)q_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = textAlignment;
    return paragraphStyle;
}

- (void)initAppearance {
    QUIAlertController *alertControllerAppearance = self;
    alertControllerAppearance.alertContentMargin = UIEdgeInsetsMake(0, 0, 0, 0);
    alertControllerAppearance.alertContentMaximumWidth = 270;
    alertControllerAppearance.alertSeparatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.82 alpha:1];
    alertControllerAppearance.alertTitleAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17],NSParagraphStyleAttributeName:[self q_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter]};
    alertControllerAppearance.alertMessageAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:13],NSParagraphStyleAttributeName:[self q_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter]};

    alertControllerAppearance.alertButtonAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.19 green:0.74 blue:0.95 alpha:1], NSFontAttributeName:[UIFont systemFontOfSize:17],NSKernAttributeName:@(0)};
    
    alertControllerAppearance.alertButtonDisabledAttributes = @{NSForegroundColorAttributeName:
                                                                    [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1], NSFontAttributeName:[UIFont systemFontOfSize:17],NSKernAttributeName:@(0)};
    alertControllerAppearance.alertCancelButtonAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.19 green:0.74 blue:0.95 alpha:1], NSFontAttributeName:[UIFont boldSystemFontOfSize:17],NSKernAttributeName:@(0)};

    alertControllerAppearance.alertDestructiveButtonAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.98 green:0.23 blue:0.23 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:17],NSKernAttributeName:@(0)};
    alertControllerAppearance.alertContentCornerRadius = 13;
    alertControllerAppearance.alertButtonHeight = 50;

    alertControllerAppearance.alertHeaderBackgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    alertControllerAppearance.alertButtonBackgroundColor = alertControllerAppearance.alertHeaderBackgroundColor;
    alertControllerAppearance.alertButtonHighlightBackgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
    alertControllerAppearance.alertHeaderInsets = UIEdgeInsetsMake(20, 16, 20, 16);
    alertControllerAppearance.alertTitleMessageSpacing = 10;
    alertControllerAppearance.alertTextFieldFont = [UIFont systemFontOfSize:14];
    alertControllerAppearance.alertTextFieldTextColor = [UIColor blackColor];
    alertControllerAppearance.alertTextFieldBorderColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1];
    alertControllerAppearance.alertTextFieldTextInsets = UIEdgeInsetsMake(10, 7, 10, 7);

    alertControllerAppearance.sheetContentMargin = UIEdgeInsetsMake(10, 10, 10, 10);
    alertControllerAppearance.sheetContentMaximumWidth = 414 - (alertControllerAppearance.sheetContentMargin.left + alertControllerAppearance.sheetContentMargin.right);
    alertControllerAppearance.sheetSeparatorColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.82 alpha:1];
    alertControllerAppearance.sheetTitleAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1],NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSParagraphStyleAttributeName:[self q_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter]};
    alertControllerAppearance.sheetMessageAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:13],NSParagraphStyleAttributeName:[self q_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter]};
    alertControllerAppearance.sheetButtonAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.19 green:0.74 blue:0.95 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:20],NSKernAttributeName:@(0)};
    alertControllerAppearance.sheetButtonDisabledAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:20],NSKernAttributeName:@(0)};
    alertControllerAppearance.sheetCancelButtonAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.19 green:0.74 blue:0.95 alpha:1],NSFontAttributeName:[UIFont boldSystemFontOfSize:20],NSKernAttributeName:@(0)};
    alertControllerAppearance.sheetDestructiveButtonAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.98 green:0.23 blue:0.23 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:20],NSKernAttributeName:@(0)};
    alertControllerAppearance.sheetCancelButtonMarginTop = 8;
    alertControllerAppearance.sheetContentCornerRadius = 13;
    alertControllerAppearance.sheetButtonHeight = 57;
    alertControllerAppearance.sheetHeaderBackgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    alertControllerAppearance.sheetButtonBackgroundColor = alertControllerAppearance.sheetHeaderBackgroundColor;
    alertControllerAppearance.sheetButtonHighlightBackgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
    alertControllerAppearance.sheetHeaderInsets = UIEdgeInsetsMake(16, 16, 16, 16);
    alertControllerAppearance.sheetTitleMessageSpacing = 8;
    alertControllerAppearance.sheetButtonColumnCount = 1;
    alertControllerAppearance.isExtendBottomLayout = NO;
}


- (void)setAlertButtonAttributes:(NSDictionary<NSString *,id> *)alertButtonAttributes {
    _alertButtonAttributes = alertButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonAttributes:(NSDictionary<NSString *,id> *)sheetButtonAttributes {
    _sheetButtonAttributes = sheetButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertButtonDisabledAttributes:(NSDictionary<NSString *,id> *)alertButtonDisabledAttributes {
    _alertButtonDisabledAttributes = alertButtonDisabledAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonDisabledAttributes:(NSDictionary<NSString *,id> *)sheetButtonDisabledAttributes {
    _sheetButtonDisabledAttributes = sheetButtonDisabledAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertCancelButtonAttributes:(NSDictionary<NSString *,id> *)alertCancelButtonAttributes {
    _alertCancelButtonAttributes = alertCancelButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetCancelButtonAttributes:(NSDictionary<NSString *,id> *)sheetCancelButtonAttributes {
    _sheetCancelButtonAttributes = sheetCancelButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)alertDestructiveButtonAttributes {
    _alertDestructiveButtonAttributes = alertDestructiveButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)sheetDestructiveButtonAttributes {
    _sheetDestructiveButtonAttributes = sheetDestructiveButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertButtonBackgroundColor:(UIColor *)alertButtonBackgroundColor {
    _alertButtonBackgroundColor = alertButtonBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonBackgroundColor:(UIColor *)sheetButtonBackgroundColor {
    _sheetButtonBackgroundColor = sheetButtonBackgroundColor;
    [self updateExtendLayerAppearance];
    _needsUpdateAction = YES;
}

- (void)setAlertButtonHighlightBackgroundColor:(UIColor *)alertButtonHighlightBackgroundColor {
    _alertButtonHighlightBackgroundColor = alertButtonHighlightBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonHighlightBackgroundColor:(UIColor *)sheetButtonHighlightBackgroundColor {
    _sheetButtonHighlightBackgroundColor = sheetButtonHighlightBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setAlertTitleAttributes:(NSDictionary<NSString *,id> *)alertTitleAttributes {
    _alertTitleAttributes = alertTitleAttributes;
    _needsUpdateTitle = YES;
}

- (void)setAlertMessageAttributes:(NSDictionary<NSString *,id> *)alertMessageAttributes {
    _alertMessageAttributes = alertMessageAttributes;
    _needsUpdateMessage = YES;
}

- (void)setSheetTitleAttributes:(NSDictionary<NSString *,id> *)sheetTitleAttributes {
    _sheetTitleAttributes = sheetTitleAttributes;
    _needsUpdateTitle = YES;
}

- (void)setSheetMessageAttributes:(NSDictionary<NSString *,id> *)sheetMessageAttributes {
    _sheetMessageAttributes = sheetMessageAttributes;
    _needsUpdateMessage = YES;
}

- (void)setAlertHeaderBackgroundColor:(UIColor *)alertHeaderBackgroundColor {
    _alertHeaderBackgroundColor = alertHeaderBackgroundColor;
    [self updateHeaderBackgrondColor];
}

- (void)setSheetHeaderBackgroundColor:(UIColor *)sheetHeaderBackgroundColor {
    _sheetHeaderBackgroundColor = sheetHeaderBackgroundColor;
    [self updateHeaderBackgrondColor];
}

- (void)updateHeaderBackgrondColor {
    if (self.preferredStyle == QUIAlertControllerStyleActionSheet) {
        if (_headerScrollView) { _headerScrollView.backgroundColor = self.sheetHeaderBackgroundColor; }
    } else if (self.preferredStyle == QUIAlertControllerStyleAlert) {
        if (_headerScrollView) { _headerScrollView.backgroundColor = self.alertHeaderBackgroundColor; }
    }
}

- (void)setAlertSeparatorColor:(UIColor *)alertSeparatorColor {
    _alertSeparatorColor = alertSeparatorColor;
    [self updateSeparatorColor];
}

- (void)setSheetSeparatorColor:(UIColor *)sheetSeparatorColor {
    _sheetSeparatorColor = sheetSeparatorColor;
    [self updateSeparatorColor];
}

- (void)updateSeparatorColor {
//    UIColor *separatorColor = self.preferredStyle == QUIAlertControllerStyleAlert ? self.alertSeparatorColor : self.sheetSeparatorColor;
    [self.alertActions enumerateObjectsUsingBlock:^(QUIAlertAction * _Nonnull alertAction, NSUInteger idx, BOOL * _Nonnull stop) {
//        alertAction.button.q_borderColor = separatorColor;
    }];
}

- (void)setAlertContentCornerRadius:(CGFloat)alertContentCornerRadius {
    _alertContentCornerRadius = alertContentCornerRadius;
    [self updateCornerRadius];
}

- (void)setSheetContentCornerRadius:(CGFloat)sheetContentCornerRadius {
    _sheetContentCornerRadius = sheetContentCornerRadius;
    [self updateCornerRadius];
}

- (void)setIsExtendBottomLayout:(BOOL)isExtendBottomLayout {
    _isExtendBottomLayout = isExtendBottomLayout;
    if (isExtendBottomLayout) {
        self.extendLayer.hidden = NO;
        [self updateExtendLayerAppearance];
    } else {
        self.extendLayer.hidden = YES;
    }
}

- (void)updateExtendLayerAppearance {
    if (_extendLayer) {
        _extendLayer.backgroundColor = self.sheetButtonBackgroundColor.CGColor;
    }
}

- (void)updateCornerRadius {
    if (self.preferredStyle == QUIAlertControllerStyleAlert) {
        if (self.containerView) { self.containerView.layer.cornerRadius = self.alertContentCornerRadius; self.containerView.clipsToBounds = YES; }
        if (self.cancelButtonVisualEffectView) { self.cancelButtonVisualEffectView.layer.cornerRadius = self.alertContentCornerRadius; self.cancelButtonVisualEffectView.clipsToBounds = NO;}
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = 0; self.scrollWrapView.clipsToBounds = NO; }
    } else {
        if (self.containerView) { self.containerView.layer.cornerRadius = 0; self.containerView.clipsToBounds = NO; }
        if (self.cancelButtonVisualEffectView) { self.cancelButtonVisualEffectView.layer.cornerRadius = self.sheetContentCornerRadius; self.cancelButtonVisualEffectView.clipsToBounds = YES; }
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = self.sheetContentCornerRadius; self.scrollWrapView.clipsToBounds = YES; }
    }
}

- (void)setAlertTextFieldFont:(UIFont *)alertTextFieldFont {
    _alertTextFieldFont = alertTextFieldFont;
    [self.textFields enumerateObjectsUsingBlock:^(AdjustEdgeInsetTextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.font = alertTextFieldFont;
    }];
}

- (void)setAlertTextFieldBorderColor:(UIColor *)alertTextFieldBorderColor {
    _alertTextFieldBorderColor = alertTextFieldBorderColor;
    [self.textFields enumerateObjectsUsingBlock:^(AdjustEdgeInsetTextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.layer.borderColor = alertTextFieldBorderColor.CGColor;
    }];
}

- (void)setAlertTextFieldTextColor:(UIColor *)alertTextFieldTextColor {
    _alertTextFieldTextColor = alertTextFieldTextColor;
    [self.textFields enumerateObjectsUsingBlock:^(AdjustEdgeInsetTextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.textColor = alertTextFieldTextColor;
    }];
}

- (void)setAlertTextFieldTextInsets:(UIEdgeInsets)alertTextFieldTextInsets {
    _alertTextFieldTextInsets = alertTextFieldTextInsets;
    [self.textFields enumerateObjectsUsingBlock:^(AdjustEdgeInsetTextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.textInsets = alertTextFieldTextInsets;
    }];
}

- (void)setAlertTextFieldMarginBlock:(UIEdgeInsets (^)(__kindof QUIAlertController * _Nonnull, NSInteger))alertTextFieldMarginBlock {
    _alertTextFieldMarginBlock = alertTextFieldMarginBlock;
    if (self.isViewLoaded) {
        [self.view setNeedsLayout];
    }
}

- (void)setMainVisualEffectView:(UIView *)mainVisualEffectView {
    if (!mainVisualEffectView) {
        // 不允许为空
        mainVisualEffectView = [[UIView alloc] init];
    }
    BOOL isValueChanged = _mainVisualEffectView != mainVisualEffectView;
    if (isValueChanged) {
        if ([_mainVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)_mainVisualEffectView).contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        } else {
            [_mainVisualEffectView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        [_mainVisualEffectView removeFromSuperview];
        _mainVisualEffectView = nil;
    }
    _mainVisualEffectView = mainVisualEffectView;
    if (isValueChanged) {
        [self.scrollWrapView insertSubview:_mainVisualEffectView atIndex:0];
        [self updateCornerRadius];
    }
}

- (void)setCancelButtonVisualEffectView:(UIView *)cancelButtonVisualEffectView {
    if (!cancelButtonVisualEffectView) {
        // 不允许为空
        cancelButtonVisualEffectView = [[UIView alloc] init];
    }
    BOOL isValueChanged = _cancelButtonVisualEffectView != cancelButtonVisualEffectView;
    if (isValueChanged) {
        if ([_cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)_cancelButtonVisualEffectView).contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        } else {
            [_cancelButtonVisualEffectView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        [_cancelButtonVisualEffectView removeFromSuperview];
        _cancelButtonVisualEffectView = nil;
    }
    _cancelButtonVisualEffectView = cancelButtonVisualEffectView;
    if (isValueChanged) {
        [self.containerView addSubview:_cancelButtonVisualEffectView];
        if (self.preferredStyle == QUIAlertControllerStyleActionSheet && self.cancelAction && !self.cancelAction.button.superview) {
            if ([_cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
                UIVisualEffectView *effectView = (UIVisualEffectView *)_cancelButtonVisualEffectView;
                [effectView.contentView addSubview:self.cancelAction.button];
            } else {
                [_cancelButtonVisualEffectView addSubview:self.cancelAction.button];
            }
        }
        
        [self updateCornerRadius];
    }
}

+ (nonnull instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(QUIAlertControllerStyle)preferredStyle {
    QUIAlertController *alertController = [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
    if (alertController) {
        return alertController;
    }
    return nil;
}

- (nonnull instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(QUIAlertControllerStyle)preferredStyle {
    self = [self init];
    if (self) {
        
        self.preferredStyle = preferredStyle;
    
        self.shouldRespondMaskViewTouch = preferredStyle == QUIAlertControllerStyleActionSheet;
        
        self.alertActions = [[NSMutableArray alloc] init];
        self.alertTextFields = [[NSMutableArray alloc] init];
        self.destructiveActions = [[NSMutableArray alloc] init];
        
        self.title = title;
        self.message = message;
        
        self.mainVisualEffectView = [[UIView alloc] init];
        self.cancelButtonVisualEffectView = [[UIView alloc] init];
    }
    return self;
}

- (QUIAlertControllerStyle)preferredStyle {
    return _preferredStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.scrollWrapView];
    [self.scrollWrapView addSubview:self.headerScrollView];
    [self.scrollWrapView addSubview:self.buttonScrollView];
    [self.containerView.layer addSublayer:self.extendLayer];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    BOOL hasTitle = (self.titleLabel.text.length > 0 && !self.titleLabel.hidden);
    BOOL hasMessage = (self.messageLabel.text.length > 0 && !self.messageLabel.hidden);
    BOOL hasTextField = self.alertTextFields.count > 0;
    BOOL hasCustomView = !!_customView;
    CGFloat contentOriginY = 0;
    
    self.maskView.frame = self.view.bounds;
    
    if (self.preferredStyle == QUIAlertControllerStyleAlert) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.bottom : 0;
        
        CGRect containerViewFrame = self.containerView.frame;
        self.containerView.frame = CGRectMake(containerViewFrame.origin.x, containerViewFrame.origin.y, fmin(self.alertContentMaximumWidth, CGRectGetWidth(self.view.bounds) - (self.alertContentMargin.left + self.alertContentMargin.right)), containerViewFrame.size.height);
        
        CGRect scrollWrapViewFrame = self.scrollWrapView.frame;
        self.scrollWrapView.frame = CGRectMake(scrollWrapViewFrame.origin.x, scrollWrapViewFrame.origin.y, CGRectGetWidth(self.containerView.bounds), scrollWrapViewFrame.size.height);
        
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            CGFloat height = [self.titleLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.titleLabel.frame), CGFLOAT_MAX)].height;
            self.titleLabel.frame = CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, height);
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.alertTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            CGFloat height = [self.messageLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.messageLabel.frame), CGFLOAT_MAX)].height;
            self.messageLabel.frame = CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, height);
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 输入框布局
        if (hasTextField) {
            for (int i = 0; i < self.alertTextFields.count; i++) {
                UITextField *textField = self.alertTextFields[i];
                CGRect textFieldFrame = CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, CGFLOAT_MAX);
                CGSize textFieldSize = [textField sizeThatFits:textFieldFrame.size];
                textFieldFrame = CGRectSetHeight(textFieldFrame, textFieldSize.height);
                UIEdgeInsets margin = UIEdgeInsetsZero;
                if (self.alertTextFieldMarginBlock) {
                    margin = self.alertTextFieldMarginBlock(self, i);
                }
                textFieldFrame = CGRectMake(CGRectGetMinX(textFieldFrame) + margin.left, CGRectGetMinY(textFieldFrame) + margin.top, CGRectGetWidth(textFieldFrame) - (margin.left + margin.right), CGRectGetHeight(textFieldFrame));
                contentOriginY = CGRectGetMaxY(textFieldFrame) + margin.bottom - textField.layer.borderWidth;
                textField.frame = textFieldFrame;
            }
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            _customView.frame = CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height);
            contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView的布局
        CGRect headerScrollViewFrame = self.headerScrollView.frame;
        self.headerScrollView.frame = CGRectMake(headerScrollViewFrame.origin.x, headerScrollViewFrame.origin.y, headerScrollViewFrame.size.width, contentOriginY < 0 ? headerScrollViewFrame.size.height : contentOriginY);
        
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = 0;
        NSArray<QUIAlertAction *> *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (newOrderActions.count > 0) {
            BOOL verticalLayout = YES;
            if (self.alertActions.count == 2) {
                CGFloat halfWidth = CGRectGetWidth(self.buttonScrollView.bounds) / 2;
                QUIAlertAction *action1 = newOrderActions[0];
                QUIAlertAction *action2 = newOrderActions[1];
                CGSize actionSize1 = [action1.button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                CGSize actionSize2 = [action2.button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                if (actionSize1.width < halfWidth && actionSize2.width < halfWidth) {
                    verticalLayout = NO;
                }
            }
            if (!verticalLayout) {
                // 对齐系统，先 add 的在右边，后 add 的在左边
                QUIAlertAction *leftAction = newOrderActions[1];
                leftAction.button.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);

                [UIBorderViewHelper lineBorderForView:leftAction.button color:self.alertSeparatorColor borderWidth:UIBorderViewHelper.pixelOne borderType:UIBorderSideTypeTop | UIBorderSideTypeRight];
                QUIAlertAction *rightAction = newOrderActions[0];
                rightAction.button.frame = CGRectMake(CGRectGetMaxX(leftAction.button.frame), contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
                [UIBorderViewHelper lineBorderForView:rightAction.button color:self.alertSeparatorColor borderWidth:UIBorderViewHelper.pixelOne borderType:UIBorderSideTypeTop];
                contentOriginY = CGRectGetMaxY(leftAction.button.frame);
            } else {
                for (int i = 0; i < newOrderActions.count; i++) {
                    QUIAlertAction *action = newOrderActions[i];
                    action.button.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), self.alertButtonHeight);
                    [UIBorderViewHelper lineBorderForView:action.button color:self.alertSeparatorColor borderWidth:UIBorderViewHelper.pixelOne borderType:UIBorderSideTypeTop];
                    contentOriginY = CGRectGetMaxY(action.button.frame);
                }
            }
        }
        // 按钮scrollView的布局
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最后布局
        CGFloat contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight - 20) {
            screenSpaceHeight -= 20;
            CGFloat contentH = fmin(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = fmin(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
            screenSpaceHeight += 20;
        }
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), contentHeight);
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
        
        self.containerView.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.frame)) / 2, (screenSpaceHeight - contentHeight - self.keyboardHeight) / 2, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.scrollWrapView.bounds));
    }
    
    else if (self.preferredStyle == QUIAlertControllerStyleActionSheet) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.bottom : 0;
        
        CGRect containerViewFrame = self.containerView.frame;
        self.containerView.frame = CGRectMake(containerViewFrame.origin.x, containerViewFrame.origin.y, fmin(self.sheetContentMaximumWidth, CGRectGetWidth(self.view.bounds) - (self.sheetContentMargin.left + self.sheetContentMargin.right)), containerViewFrame.size.height);
        
        CGRect scrollWrapViewFrame = self.scrollWrapView.frame;
        self.scrollWrapView.frame = CGRectMake(scrollWrapViewFrame.origin.x, scrollWrapViewFrame.origin.y, CGRectGetWidth(self.containerView.bounds), scrollWrapViewFrame.size.height);
        
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            CGFloat height = [self.titleLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.titleLabel.frame), CGFLOAT_MAX)].height;
            self.titleLabel.frame = CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, height);
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.sheetTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            CGFloat height = [self.messageLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.messageLabel.frame), CGFLOAT_MAX)].height;
            self.messageLabel.frame = CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, height);
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            _customView.frame = CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height);
            contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView布局
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentOriginY);
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮的布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        NSArray<QUIAlertAction *> *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (self.sheetButtonColumnCount > 1) {
            // 如果是多列，则为了布局，补齐 item 个数
            NSMutableArray<QUIAlertAction *> *fixedActions = [newOrderActions mutableCopy];
            [fixedActions removeObject:self.cancelAction];
            
            if (fmodf(fixedActions.count, self.sheetButtonColumnCount) != 0) {
                NSInteger increment = self.sheetButtonColumnCount - fmodf(fixedActions.count, self.sheetButtonColumnCount);
                for (NSInteger i = 0; i < increment; i++) {
                    QUIAlertAction *action = [[QUIAlertAction alloc] init];
                    action.title = @"";
                    action.style = QUIAlertActionStyleDefault;
                    action.handler = nil;
                    [self.buttonScrollView addSubview:action.button];
                    [fixedActions addObject:action];
                }
                
                [fixedActions addObject:self.cancelAction];
                newOrderActions = [fixedActions copy];
            }
        }
        
        CGFloat columnCount = self.sheetButtonColumnCount;
        CGFloat alertActionsWidth = CGRectGetWidth(self.buttonScrollView.bounds) / columnCount;
        CGFloat alertActionsLayoutX = 0;
        CGFloat alertActionsLayoutY = 0;
        contentOriginY = 0;
        if (self.alertActions.count > 0) {
            for (int i = 0; i < newOrderActions.count; i++) {
                QUIAlertAction *action = newOrderActions[i];
                if (action.style == QUIAlertActionStyleCancel && i == newOrderActions.count - 1) {
                    continue;
                } else {
                    action.button.frame = CGRectMake(alertActionsLayoutX, alertActionsLayoutY, alertActionsWidth, self.sheetButtonHeight);
                    if (fmodf(i + 1, columnCount) == 0) {
                        [UIBorderViewHelper lineBorderForView:action.button color:self.sheetSeparatorColor borderWidth:UIBorderViewHelper.pixelOne borderType:UIBorderSideTypeTop];
                        alertActionsLayoutX = 0;
                        alertActionsLayoutY = CGRectGetMaxY(action.button.frame);
                    } else {
                        [UIBorderViewHelper lineBorderForView:action.button color:self.sheetSeparatorColor borderWidth:UIBorderViewHelper.pixelOne borderType:UIBorderSideTypeTop | UIBorderSideTypeRight];
                        alertActionsLayoutX += alertActionsWidth;
                    }
                    
                    contentOriginY = MAX(contentOriginY, CGRectGetMaxY(action.button.frame));
                }
            }
        }
        // 按钮scrollView布局
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最终布局
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), CGRectGetMaxY(self.buttonScrollView.frame));
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
        contentOriginY = CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop;
        if (self.cancelAction) {
            self.cancelButtonVisualEffectView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), self.sheetButtonHeight);
            self.cancelAction.button.frame = self.cancelButtonVisualEffectView.bounds;
            contentOriginY = CGRectGetMaxY(self.cancelButtonVisualEffectView.frame);
        }
        // 把上下的margin都加上用于跟整个屏幕的高度做比较
        CGFloat contentHeight = contentOriginY + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight) {
            CGFloat cancelButtonAreaHeight = (self.cancelAction ? (CGRectGetHeight(self.cancelAction.button.bounds) + self.sheetCancelButtonMarginTop) : 0);
            screenSpaceHeight = screenSpaceHeight - cancelButtonAreaHeight - UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
            CGFloat contentH = MIN(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = MIN(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
            }
            self.scrollWrapView.frame =  CGRectSetHeight(self.scrollWrapView.frame, CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds));
            if (self.cancelAction) {
                self.cancelButtonVisualEffectView.frame = CGRectSetY(self.cancelButtonVisualEffectView.frame, CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop);
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds) + cancelButtonAreaHeight + self.sheetContentMargin.bottom;
            screenSpaceHeight += (cancelButtonAreaHeight + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin));
        } else {
            // 如果小于屏幕高度，则把顶部的top减掉
            contentHeight -= self.sheetContentMargin.top;
        }
        
        float safeAreaInsetsBottom = 0;
        if (@available(iOS 11.0, *)) {
            //如果是x，给底部的34pt添加上背景颜色，颜色和输入条一致
            safeAreaInsetsBottom = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
        }
        
        self.containerView.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.frame)) / 2, screenSpaceHeight - contentHeight - safeAreaInsetsBottom, CGRectGetWidth(self.containerView.frame), contentHeight + (self.isExtendBottomLayout ? safeAreaInsetsBottom : 0));
        
        self.extendLayer.frame = CGRectMake(0, CGRectGetHeight(self.containerView.bounds) - safeAreaInsetsBottom - 1, CGRectGetWidth(self.containerView.bounds), safeAreaInsetsBottom + 1);
    }
}

- (NSArray<QUIAlertAction *> *)orderedAlertActions:(NSArray<QUIAlertAction *> *)actions {
    NSMutableArray<QUIAlertAction *> *newActions = [[NSMutableArray alloc] init];
    // 按照用户addAction的先后顺序来排序
    if (self.orderActionsByAddedOrdered) {
        [newActions addObjectsFromArray:self.alertActions];
        // 取消按钮不参与排序，所以先移除，在最后再重新添加
        if (self.cancelAction) {
            [newActions removeObject:self.cancelAction];
        }
    } else {
        for (QUIAlertAction *action in self.alertActions) {
            if (action.style != QUIAlertActionStyleCancel && action.style != QUIAlertActionStyleDestructive) {
                [newActions addObject:action];
            }
        }
        for (QUIAlertAction *action in self.destructiveActions) {
            [newActions addObject:action];
        }
    }
    if (self.cancelAction) {
        [newActions addObject:self.cancelAction];
    }
    return newActions;
}

- (void)initModalPresentationController {
    _modalPresentationViewController = [[QUIModalPresentationViewController alloc] init];
    self.modalPresentationViewController.delegate = self;
    self.modalPresentationViewController.maximumContentViewWidth = CGFLOAT_MAX;
    self.modalPresentationViewController.contentViewMargins = UIEdgeInsetsZero;
    self.modalPresentationViewController.dimmingView = nil;
    self.modalPresentationViewController.contentViewController = self;
    if (self.alertTextFields.count > 0) {
        self.modalPresentationViewController.containsTextField = true;
    }
    [self customModalPresentationControllerAnimation];
}

- (void)customModalPresentationControllerAnimation {
    
    __weak __typeof(self)weakSelf = self;
    
    self.modalPresentationViewController.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
        weakSelf.view.frame = CGRectMake(0, 0, CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
        weakSelf.keyboardHeight = keyboardHeight;
        [weakSelf.view setNeedsLayout];
    };
    
    self.modalPresentationViewController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        if (self.preferredStyle == QUIAlertControllerStyleAlert) {
            weakSelf.containerView.alpha = 0;
            weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
            [UIView animateWithDuration:0.25f delay:0 options:QUIViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 1;
                weakSelf.containerView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (self.preferredStyle == QUIAlertControllerStyleActionSheet) {
            weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
            [UIView animateWithDuration:0.25f delay:0 options:QUIViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
    
    self.modalPresentationViewController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        if (self.preferredStyle == QUIAlertControllerStyleAlert) {
            [UIView animateWithDuration:0.25f delay:0 options:QUIViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.containerView.alpha = 0;
            } completion:^(BOOL finished) {
                weakSelf.containerView.alpha = 1;
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (self.preferredStyle == QUIAlertControllerStyleActionSheet) {
            [UIView animateWithDuration:0.25f delay:0 options:QUIViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
}

- (void)showWithAnimated:(BOOL)animated {
    if (self.willShow || self.showing) {
        return;
    }
    self.willShow = YES;
    
    if (self.alertTextFields.count > 0) {
        [self.alertTextFields.firstObject becomeFirstResponder];
    }
    
    if (_needsUpdateAction) {
        [self updateAction];
    }
    if (_needsUpdateTitle) {
        [self updateTitleLabel];
    }
    if (_needsUpdateMessage) {
        [self updateMessageLabel];
    }
    
    [self initModalPresentationController];
    
    if ([self.delegate respondsToSelector:@selector(willShowAlertController:)]) {
        [self.delegate willShowAlertController:self];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [self.modalPresentationViewController showWithAnimated:animated completion:^(BOOL finished) {
        weakSelf.maskView.alpha = 1;
        weakSelf.willShow = NO;
        weakSelf.showing = YES;
        if (weakSelf.isNeedsHideAfterAlertShowed) {
            [weakSelf hideWithAnimated:weakSelf.isAnimatedForHideAfterAlertShowed];
            weakSelf.isNeedsHideAfterAlertShowed = NO;
            weakSelf.isAnimatedForHideAfterAlertShowed = NO;
        }
        if ([weakSelf.delegate respondsToSelector:@selector(didShowAlertController:)]) {
            [weakSelf.delegate didShowAlertController:weakSelf];
        }
    }];
    
    // 增加alertController计数
    alertControllerCount++;
}

- (void)hideWithAnimated:(BOOL)animated {
    [self hideWithAnimated:animated completion:NULL];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if ([self.delegate respondsToSelector:@selector(shouldHideAlertController:)] && ![self.delegate shouldHideAlertController:self]) {
        return;
    }
    
    if (!self.showing) {
        if (self.willShow) {
            self.isNeedsHideAfterAlertShowed = YES;
            self.isAnimatedForHideAfterAlertShowed = animated;
        }
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(willHideAlertController:)]) {
        [self.delegate willHideAlertController:self];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [self.modalPresentationViewController hideWithAnimated:animated completion:^(BOOL finished) {
        weakSelf.modalPresentationViewController = nil;
        weakSelf.willShow = NO;
        weakSelf.showing = NO;
        weakSelf.maskView.alpha = 0;
        if (self.preferredStyle == QUIAlertControllerStyleAlert) {
            weakSelf.containerView.alpha = 0;
        } else {
            weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
        }
        if ([weakSelf.delegate respondsToSelector:@selector(didHideAlertController:)]) {
            [weakSelf.delegate didHideAlertController:weakSelf];
        }
        if (completion) completion();
    }];
    
    // 减少alertController计数
    alertControllerCount--;
}

- (void)addAction:(nonnull QUIAlertAction *)action {
    if (action.style == QUIAlertActionStyleCancel && self.cancelAction) {
        [NSException raise:@"QUIAlertController使用错误" format:@"同一个alertController不可以同时添加两个cancel按钮"];
    }
    if (action.style == QUIAlertActionStyleCancel) {
        self.cancelAction = action;
    }
    if (action.style == QUIAlertActionStyleDestructive) {
        [self.destructiveActions addObject:action];
    }
    // 只有ActionSheet的取消按钮不参与滚动
    if (self.preferredStyle == QUIAlertControllerStyleActionSheet && action.style == QUIAlertActionStyleCancel) {
        if (!self.cancelButtonVisualEffectView.superview) {
            [self.containerView addSubview:self.cancelButtonVisualEffectView];
        }
        if ([self.cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)self.cancelButtonVisualEffectView).contentView addSubview:action.button];
        } else {
            [self.cancelButtonVisualEffectView addSubview:action.button];
        }
    } else {
        [self.buttonScrollView addSubview:action.button];
    }
    action.delegate = self;
    [self.alertActions addObject:action];
}

- (void)addCancelAction {
    QUIAlertAction *action = [QUIAlertAction actionWithTitle:@"取消" style:QUIAlertActionStyleCancel handler:nil];
    [self addAction:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(AdjustEdgeInsetTextField *textField))configurationHandler {
    if (_customView) {
        [NSException raise:@"QUIAlertController使用错误" format:@"UITextField和CustomView不能共存"];
    }
    if (self.preferredStyle == QUIAlertControllerStyleActionSheet) {
        [NSException raise:@"QUIAlertController使用错误" format:@"Sheet类型不运行添加UITextField"];
    }
    AdjustEdgeInsetTextField *textField = [[AdjustEdgeInsetTextField alloc] init];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = [UIColor whiteColor];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = self.alertTextFieldFont;
    textField.textColor = self.alertTextFieldTextColor;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.textInsets = self.alertTextFieldTextInsets;
    textField.layer.borderColor = self.alertTextFieldBorderColor.CGColor;
    textField.layer.borderWidth = 1 / [[UIScreen mainScreen] scale];
    [self.headerScrollView addSubview:textField];
    [self.alertTextFields addObject:textField];
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

- (void)addCustomView:(UIView *)view {
    if (view && self.alertTextFields.count > 0) {
        [NSException raise:@"QUIAlertController使用错误" format:@"UITextField 和 customView 不能共存"];
    }
    if (_customView && _customView != view) {
        [_customView removeFromSuperview];
    }
    _customView = view;
    if (_customView) {
        [self.headerScrollView addSubview:_customView];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        [self.headerScrollView addSubview:self.titleLabel];
    }
    if (!_title || [_title isEqualToString:@""]) {
        self.titleLabel.hidden = YES;
    } else {
        self.titleLabel.hidden = NO;
        [self updateTitleLabel];
    }
}

- (NSString *)title {
    return _title;
}

- (void)updateTitleLabel {
    if (self.titleLabel && !self.titleLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.title attributes:self.preferredStyle == QUIAlertControllerStyleAlert ? self.alertTitleAttributes : self.sheetTitleAttributes];
        self.titleLabel.attributedText = attributeString;
    }
}

- (void)setMessage:(NSString *)message {
    _message = message;
    if (!self.messageLabel) {
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.numberOfLines = 0;
        [self.headerScrollView addSubview:self.messageLabel];
    }
    if (!_message || [_message isEqualToString:@""]) {
        self.messageLabel.hidden = YES;
    } else {
        self.messageLabel.hidden = NO;
        [self updateMessageLabel];
    }
}

- (void)updateMessageLabel {
    if (self.messageLabel && !self.messageLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.message attributes:self.preferredStyle == QUIAlertControllerStyleAlert ? self.alertMessageAttributes : self.sheetMessageAttributes];
        self.messageLabel.attributedText = attributeString;
    }
}

- (NSArray<QUIAlertAction *> *)actions {
    return [self.alertActions copy];
}

- (void)updateAction {
    
    for (QUIAlertAction *alertAction in self.alertActions) {
        
        UIColor *backgroundColor = self.preferredStyle == QUIAlertControllerStyleAlert ? self.alertButtonBackgroundColor : self.sheetButtonBackgroundColor;
        UIColor *highlightBackgroundColor = self.preferredStyle == QUIAlertControllerStyleAlert ? self.alertButtonHighlightBackgroundColor : self.sheetButtonHighlightBackgroundColor;
          
        alertAction.button.clipsToBounds = alertAction.style == QUIAlertActionStyleCancel;
        alertAction.button.backgroundColor = backgroundColor;
        alertAction.button.highlightedBackgroundColor = highlightBackgroundColor;
        
        NSAttributedString *attributeString = nil;
        if (alertAction.style == QUIAlertActionStyleCancel) {
            
            NSDictionary *attributes = (self.preferredStyle == QUIAlertControllerStyleAlert) ? self.alertCancelButtonAttributes : self.sheetCancelButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else if (alertAction.style == QUIAlertActionStyleDestructive) {
            
            NSDictionary *attributes = (self.preferredStyle == QUIAlertControllerStyleAlert) ? self.alertDestructiveButtonAttributes : self.sheetDestructiveButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else {
            
            NSDictionary *attributes = (self.preferredStyle == QUIAlertControllerStyleAlert) ? self.alertButtonAttributes : self.sheetButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        }
        
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateNormal];
        
        NSDictionary *attributes = (self.preferredStyle == QUIAlertControllerStyleAlert) ? self.alertButtonDisabledAttributes : self.sheetButtonDisabledAttributes;
        if (alertAction.buttonDisabledAttributes) {
            attributes = alertAction.buttonDisabledAttributes;
        }
        
        attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateDisabled];
        
//        if ([alertAction.button imageForState:UIControlStateNormal]) {
//            NSRange range = NSMakeRange(0, attributeString.length);
//            UIColor *disabledColor = [attributeString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
//            [alertAction.button setImage:[[alertAction.button imageForState:UIControlStateNormal] q_imageWithTintColor:disabledColor] forState:UIControlStateDisabled];
//        }
    }
}

- (NSArray<__kindof UITextField *> *)textFields {
    return [self.alertTextFields copy];
}

- (void)handleMaskViewEvent:(id)sender {
    if (_shouldRespondMaskViewTouch) {
        [self hideWithAnimated:YES completion:NULL];
    }
}

CG_INLINE CGRect
CGRectSetHeight(CGRect rect, CGFloat height) {
    if (height < 0) {
        return rect;
    }
    rect.size.height = height;
    return rect;
}

/// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat
UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}


CG_INLINE CGRect
CGRectSetY(CGRect rect, CGFloat y) {
    rect.origin.y = y;
    return rect;
}

#pragma mark - Getters & Setters

- (UIControl *)maskView {
    if (!_maskView) {
        _maskView = [[UIControl alloc] init];
        _maskView.alpha = 0;
        _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35f];
        [_maskView addTarget:self action:@selector(handleMaskViewEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (UIView *)scrollWrapView {
    if (!_scrollWrapView) {
        _scrollWrapView = [[UIView alloc] init];
    }
    return _scrollWrapView;
}

- (UIScrollView *)headerScrollView {
    if (!_headerScrollView) {
        _headerScrollView = [[UIScrollView alloc] init];
        _headerScrollView.scrollsToTop = NO;
        if (@available(iOS 11.0, *)) {
            _headerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
        [self updateHeaderBackgrondColor];
    }
    return _headerScrollView;
}

- (UIScrollView *)buttonScrollView {
    if (!_buttonScrollView) {
        _buttonScrollView = [[UIScrollView alloc] init];
        _buttonScrollView.scrollsToTop = NO;
        if (@available(iOS 11.0, *)) {
            _buttonScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
    return _buttonScrollView;
}

- (CALayer *)extendLayer {
    if (!_extendLayer) {
        _extendLayer = [CALayer layer];
        _extendLayer.hidden = !self.isExtendBottomLayout;
        [self updateExtendLayerAppearance];
    }
    return _extendLayer;
}

#pragma mark - <QUIAlertActionDelegate>

- (void)didClickAlertAction:(QUIAlertAction *)alertAction {
    [self hideWithAnimated:YES completion:^{
        if (alertAction.handler) {
            alertAction.handler(self, alertAction);
        }
    }];
}

#pragma mark - <QUIModalPresentationComponentProtocol>

- (void)hideModalPresentationComponent {
    [self hideWithAnimated:NO completion:NULL];
}

#pragma mark - <QUIModalPresentationViewControllerDelegate>

- (BOOL)shouldHideModalPresentationViewController:(QUIModalPresentationViewController *)controller {
    if ([self.delegate respondsToSelector:@selector(shouldHideAlertController:)]) {
        return [self.delegate shouldHideAlertController:self];
    }
    return YES;
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!self.shouldManageTextFieldsReturnEventAutomatically) {
        return NO;
    }
    
    if (![self.textFields containsObject:textField]) {
        return NO;
    }
    
    // 最后一个输入框，默认的 return 行为与 iOS 9-11 保持一致，也即：
    // 如果 action = 1，则自动响应这个 action 的事件
    // 如果 action = 2，并且其中有一个是 Cancel，则响应另一个 action 的事件，如果其中不存在 Cancel，则降下键盘，不响应任何 action
    // 如果 action > 2，则降下键盘，不响应任何 action
    if (textField == self.textFields.lastObject) {
        if (self.actions.count == 1) {
            [self.actions.firstObject.button sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else if (self.actions.count == 2) {
            if (self.cancelAction) {
                QUIAlertAction *targetAction = self.actions.firstObject == self.cancelAction ? self.actions.lastObject : self.actions.firstObject;
                [targetAction.button sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
        [self.view endEditing:YES];
        return NO;
    }
    // 非最后一个输入框，则默认的 return 行为是聚焦到下一个输入框
    NSUInteger index = [self.textFields indexOfObject:textField];
    [self.textFields[index + 1] becomeFirstResponder];
    return NO;
}

@end

@implementation QUIAlertController (Manager)

+ (BOOL)isAnyAlertControllerVisible {
    return alertControllerCount > 0;
}

@end

