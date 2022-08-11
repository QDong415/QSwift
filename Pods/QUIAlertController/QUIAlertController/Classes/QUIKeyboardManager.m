//
//  QAlertViewController
//
//  Created by QDong on 2022-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad


#import "QUIKeyboardManager.h"

@interface QUIKeyboardManager ()

@property(nonatomic, strong) NSMutableArray <NSValue *> *targetResponderValues;

@property(nonatomic, strong) QUIKeyboardUserInfo *lastUserInfo;
@property(nonatomic, assign) CGRect keyboardMoveBeginRect;

@property(nonatomic, weak) UIResponder *currentResponder;
//@property(nonatomic, weak) UIResponder *currentResponderWhenResign;

@property(nonatomic, assign) BOOL debug;

@end


@interface UIView (KeyboardManager)

- (id)q_findFirstResponder;

@end

@implementation UIView (KeyboardManager)

- (id)q_findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView q_findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}

@end


@interface QUIKeyboardUserInfo ()

@property(nonatomic, weak, readwrite) QUIKeyboardManager *keyboardManager;
@property(nonatomic, strong, readwrite) NSNotification *notification;
@property(nonatomic, weak, readwrite) UIResponder *targetResponder;
@property(nonatomic, assign) BOOL isTargetResponderFocused;

@property(nonatomic, assign, readwrite) CGFloat width;
@property(nonatomic, assign, readwrite) CGFloat height;

@property(nonatomic, assign, readwrite) CGRect beginFrame;
@property(nonatomic, assign, readwrite) CGRect endFrame;

@property(nonatomic, assign, readwrite) NSTimeInterval animationDuration;
@property(nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;
@property(nonatomic, assign, readwrite) UIViewAnimationOptions animationOptions;

@property(nonatomic, assign, readwrite) BOOL isFloatingKeyboard;

@end

@implementation QUIKeyboardUserInfo

- (void)setNotification:(NSNotification *)notification {
    _notification = notification;
    if (self.originUserInfo) {
        
        _animationDuration = [[self.originUserInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        _animationCurve = (UIViewAnimationCurve)[[self.originUserInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        _animationOptions = self.animationCurve<<16;
        
        CGRect beginFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect endFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        _beginFrame = beginFrame;
        _endFrame = endFrame;
    }
}

- (void)setTargetResponder:(UIResponder *)targetResponder {
    _targetResponder = targetResponder;
    self.isTargetResponderFocused = targetResponder;
}

- (NSDictionary *)originUserInfo {
    return self.notification ? self.notification.userInfo : nil;
}

- (CGFloat)width {
    CGRect keyboardRect = [QUIKeyboardManager convertKeyboardRect:_endFrame toView:nil];
    return keyboardRect.size.width;
}

- (CGFloat)height {
    CGRect keyboardRect = [QUIKeyboardManager convertKeyboardRect:_endFrame toView:nil];
    return keyboardRect.size.height;
}

- (CGFloat)heightInView:(UIView *)view {
    if (!view) {
        return [self height];
    }
    CGRect keyboardRect = [QUIKeyboardManager convertKeyboardRect:_endFrame toView:view];
    CGRect visibleRect = CGRectIntersection(view.bounds, keyboardRect);
    if (![QUIKeyboardManager CGRectIsValidated: visibleRect]) {
        return 0;
    }
    return visibleRect.size.height;
}

- (CGRect)beginFrame {
    return _beginFrame;
}

- (CGRect)endFrame {
    return _endFrame;
}

- (NSTimeInterval)animationDuration {
    return _animationDuration;
}

- (UIViewAnimationCurve)animationCurve {
    return _animationCurve;
}

- (UIViewAnimationOptions)animationOptions {
    return _animationOptions;
}

@end


/**
 1. 系统键盘app启动第一次使用键盘的时候，会调用两轮键盘通知事件，之后就只会调用一次。而搜狗等第三方输入法的键盘，目前发现每次都会调用三次键盘通知事件。总之，键盘的通知事件是不确定的。

 2. 搜狗键盘可以修改键盘的高度，在修改键盘高度之后，会调用键盘的keyboardWillChangeFrameNotification和keyboardWillShowNotification通知。

 3. 如果从一个聚焦的输入框直接聚焦到另一个输入框，会调用前一个输入框的keyboardWillChangeFrameNotification，在调用后一个输入框的keyboardWillChangeFrameNotification，最后调用后一个输入框的keyboardWillShowNotification（如果此时是浮动键盘，那么后一个输入框的keyboardWillShowNotification不会被调用；）。

 4. iPad可以变成浮动键盘，固定->浮动：会调用keyboardWillChangeFrameNotification和keyboardWillHideNotification；浮动->固定：会调用keyboardWillChangeFrameNotification和keyboardWillShowNotification；浮动键盘在移动的时候只会调用keyboardWillChangeFrameNotification通知，并且endFrame为zero，fromFrame不为zero，而是移动前键盘的frame。浮动键盘在聚焦和失焦的时候只会调用keyboardWillChangeFrameNotification，不会调用show和hide的notification。

 5. iPad可以拆分为左右的小键盘，小键盘的通知具体基本跟浮动键盘一样。

 6. iPad可以外接键盘，外接键盘之后屏幕上就没有虚拟键盘了，但是当我们输入文字的时候，发现底部还是有一条灰色的候选词，条东西也是键盘，它也会触发跟虚拟键盘一样的通知事件。如果点击这条候选词右边的向下箭头，则可以完全隐藏虚拟键盘，这个时候如果失焦再聚焦发现还是没有这条候选词，也就是键盘完全不出来了，如果输入文字，候选词才会重新出来。总结来说就是这条候选词是可以关闭的，关闭之后只有当下次输入才会重新出现。（聚焦和失焦都只调用keyboardWillChangeFrameNotification和keyboardWillHideNotification通知，而且frame始终不变，都是在屏幕下面）

 7. iOS8 hide 之后高度变成0了，keyboardWillHideNotification还是正常的，所以建议不要使用键盘高度来做动画，而是用键盘的y值；在show和hide的时候endFrame会出现一些奇怪的中间值，但最终值是对的；两个输入框切换聚焦，iOS8不会触发任何键盘通知；iOS8的浮动切换正常；

 8. iOS8在 固定->浮动 的过程中，后面的keyboardWillChangeFrameNotification和keyboardWillHideNotification里面的endFrame是正确的，而iOS10和iOS9是错的，iOS9的y值是键盘的MaxY，而iOS10的y值是隐藏状态下的y，也就是屏幕高度。所以iOS9和iOS10需要在keyboardDidChangeFrameNotification里面重新刷新一下。
 */
@implementation QUIKeyboardManager

- (instancetype)init {
    NSAssert(NO, @"请使用initWithDelegate:初始化");
    return [self initWithDelegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSAssert(NO, @"请使用initWithDelegate:初始化");
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id <QUIKeyboardManagerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _delegateEnabled = YES;
        _targetResponderValues = [[NSMutableArray alloc] init];
        [self addKeyboardNotification];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)addTargetResponder:(UIResponder *)targetResponder {
    if (!targetResponder || ![targetResponder isKindOfClass:[UIResponder class]]) {
        return NO;
    }
    [self.targetResponderValues addObject:[self packageTargetResponder:targetResponder]];
    return YES;
}

- (NSArray<UIResponder *> *)allTargetResponders {
    NSMutableArray *targetResponders = nil;
    for (int i = 0; i < self.targetResponderValues.count; i++) {
        if (!targetResponders) {
            targetResponders = [[NSMutableArray alloc] init];
        }
        id unPackageValue = [self unPackageTargetResponder:self.targetResponderValues[i]];
        if (unPackageValue && [unPackageValue isKindOfClass:[UIResponder class]]) {
            [targetResponders addObject:(UIResponder *)unPackageValue];
        }
    }
    return [targetResponders copy];
}

- (BOOL)removeTargetResponder:(UIResponder *)targetResponder {
    if (targetResponder && [self.targetResponderValues containsObject:[self packageTargetResponder:targetResponder]]) {
        [self.targetResponderValues removeObject:[self packageTargetResponder:targetResponder]];
        return YES;
    }
    return NO;
}

- (NSValue *)packageTargetResponder:(UIResponder *)targetResponder {
    if (![targetResponder isKindOfClass:[UIResponder class]]) {
        return nil;
    }
    return [NSValue valueWithNonretainedObject:targetResponder];
}

- (UIResponder *)unPackageTargetResponder:(NSValue *)value {
    if (!value) {
        return nil;
    }
    id unPackageValue = [value nonretainedObjectValue];
    if (![unPackageValue isKindOfClass:[UIResponder class]]) {
        return nil;
    }
    return (UIResponder *)unPackageValue;
}

- (UIResponder *)firstResponderInWindows {
    UIResponder *responder = [UIApplication.sharedApplication.keyWindow q_findFirstResponder];
    if (!responder) {
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            if (window != UIApplication.sharedApplication.keyWindow) {
                responder = [window q_findFirstResponder];
                if (responder) {
                    return responder;
                }
            }
        }
    }
    return responder;
}

#pragma mark - Notification

- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (BOOL)isAppActive {
    if (self.ignoreApplicationState) {
        return YES;
    }
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
        return YES;
    }
    return NO;
}

- (BOOL)isLocalKeyboard:(NSNotification *)notification {
    if ([[notification.userInfo valueForKey:UIKeyboardIsLocalUserInfoKey] boolValue]) {
        return YES;
    }
    return NO;
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {

    
    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        return;
    }
    
    if (![self shouldReceiveShowNotification]) {
        return;
    }
    
    QUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillShowWithUserInfo:)]) {
        [self.delegate keyboardWillShowWithUserInfo:userInfo];
    }
}

- (void)keyboardDidShowNotification:(NSNotification *)notification {
    
    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        return;
    }
    
    QUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    id firstResponder = [self firstResponderInWindows];
    BOOL shouldReceiveDidShowNotification = self.targetResponderValues.count <= 0 || (firstResponder && firstResponder == self.currentResponder);
    
    if (shouldReceiveDidShowNotification) {
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidShowWithUserInfo:)]) {
            [self.delegate keyboardDidShowWithUserInfo:userInfo];
        }
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {

    
    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        return;
    }
    
    if (![self shouldReceiveHideNotification]) {
        return;
    }
    
    QUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillHideWithUserInfo:)]) {
        [self.delegate keyboardWillHideWithUserInfo:userInfo];
    }
    
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {

    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        return;
    }
    
    QUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    userInfo.targetResponder = self.currentResponder ?: nil;
    
    if ([self shouldReceiveHideNotification]) {
        if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidHideWithUserInfo:)]) {
            [self.delegate keyboardDidHideWithUserInfo:userInfo];
        }
    }
    
    if (self.currentResponder && !(IS_IPAD)) {
        // 时机最晚，设置为 nil
        self.currentResponder = nil;
    }

}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {

    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        return;
    }
    
    QUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    
    if ([self shouldReceiveShowNotification] || [self shouldReceiveHideNotification]) {
        userInfo.targetResponder = self.currentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardWillChangeFrameWithUserInfo:userInfo];
    }
}

- (void)keyboardDidChangeFrameNotification:(NSNotification *)notification {

    if (![self isAppActive] || ![self isLocalKeyboard:notification]) {
        return;
    }
    
    QUIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
    self.lastUserInfo = userInfo;
    
    if ([self shouldReceiveShowNotification] || [self shouldReceiveHideNotification]) {
        userInfo.targetResponder = self.currentResponder ?: nil;
    } else {
        return;
    }
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidChangeFrameWithUserInfo:)]) {
        [self.delegate keyboardDidChangeFrameWithUserInfo:userInfo];
    }
}

- (QUIKeyboardUserInfo *)newUserInfoWithNotification:(NSNotification *)notification {
    QUIKeyboardUserInfo *userInfo = [[QUIKeyboardUserInfo alloc] init];
    userInfo.keyboardManager = self;
    userInfo.notification = notification;
    return userInfo;
}

- (BOOL)shouldReceiveShowNotification {
   
    UIResponder *firstResponder = [self firstResponderInWindows];
    if (self.currentResponder) {
         // 这里有 BUG，如果点击了 webview 导致键盘下降，这个时候运行 shouldReceiveHideNotification 就会判断错误，所以如果发现是 nil 或是 WKContentView 则值不变
        if (firstResponder && ![firstResponder isKindOfClass:NSClassFromString([NSString stringWithFormat:@"%@%@", @"WK", @"ContentView"])]) {
            self.currentResponder = firstResponder;
        }
    } else {
        self.currentResponder = firstResponder;
    }

    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        return self.currentResponder && [self.targetResponderValues containsObject:[self packageTargetResponder:self.currentResponder]];
    }
}

- (BOOL)shouldReceiveHideNotification {
    if (self.targetResponderValues.count <= 0) {
        return YES;
    } else {
        if (self.currentResponder) {
            return [self.targetResponderValues containsObject:[self packageTargetResponder:self.currentResponder]];
        } else {
            return NO;
        }
    }
}

#pragma mark - 工具方法

+ (void)animateWithAnimated:(BOOL)animated keyboardUserInfo:(QUIKeyboardUserInfo *)keyboardUserInfo animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:keyboardUserInfo.animationDuration delay:0 options:keyboardUserInfo.animationOptions|UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (animations) {
                animations();
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)handleKeyboardNotificationWithUserInfo:(QUIKeyboardUserInfo *)keyboardUserInfo showBlock:(void (^)(QUIKeyboardUserInfo *keyboardUserInfo))showBlock hideBlock:(void (^)(QUIKeyboardUserInfo *keyboardUserInfo))hideBlock {
    // 专门处理 iPad Pro 在键盘完全不显示的情况（不会调用willShow，所以通过是否focus来判断）
    // iPhoneX Max 这里键盘高度不是0，而是一个很小的值
    if (!keyboardUserInfo.isTargetResponderFocused) {
        // 先判断 focus，避免 frame 变化但是此时 visibleKeyboardHeight 还不是 0 导致调用了 showBlock
        if ([QUIKeyboardManager visibleKeyboardHeight] <= 0) {
            if (hideBlock) {
                hideBlock(keyboardUserInfo);
            }
        }
    } else {
        if (showBlock) {
            showBlock(keyboardUserInfo);
        }
    }
}

+ (UIWindow *)keyboardWindow {
    
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if ([self getKeyboardViewFromWindow:window]) {
            return window;
        }
    }
    
    NSMutableArray *kbWindows = nil;
    
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        NSString *windowName = NSStringFromClass(window.class);
        if ([windowName isEqualToString:[NSString stringWithFormat:@"UI%@%@", @"Remote", @"KeyboardWindow"]]) {
            // UIRemoteKeyboardWindow（iOS9 以下 UITextEffectsWindow）
            if (!kbWindows) kbWindows = [NSMutableArray new];
            [kbWindows addObject:window];
        }
    }
    
    if (kbWindows.count == 1) {
        return kbWindows.firstObject;
    }
    
    return nil;
}

+ (CGRect)convertKeyboardRect:(CGRect)rect toView:(UIView *)view {
    
    if (CGRectIsNull(rect) || CGRectIsInfinite(rect)) {
        return rect;
    }
    
    UIWindow *mainWindow = UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.windows.firstObject;
    if (!mainWindow) {
        if (view) {
            [view convertRect:rect fromView:nil];
        } else {
            return rect;
        }
    }
    
    rect = [mainWindow convertRect:rect fromWindow:nil];
    if (!view) {
        return [mainWindow convertRect:rect toWindow:nil];
    }
    if (view == mainWindow) {
        return rect;
    }
    
    UIWindow *toWindow = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!mainWindow || !toWindow) {
        return [mainWindow convertRect:rect toView:view];
    }
    if (mainWindow == toWindow) {
        return [mainWindow convertRect:rect toView:view];
    }
    
    rect = [mainWindow convertRect:rect toView:mainWindow];
    rect = [toWindow convertRect:rect fromWindow:mainWindow];
    rect = [view convertRect:rect fromView:toWindow];
    
    return rect;
}

+ (CGFloat)distanceFromMinYToBottomInView:(UIView *)view keyboardRect:(CGRect)rect {
    rect = [self convertKeyboardRect:rect toView:view];
    CGFloat distance = CGRectGetHeight(view.bounds) - CGRectGetMinY(rect);
    return distance;
}

+ (UIView *)keyboardView {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        UIView *view = [self getKeyboardViewFromWindow:window];
        if (view) {
            return view;
        }
    }
    return nil;
}

+ (UIView *)getKeyboardViewFromWindow:(UIWindow *)window {
    
    if (!window) return nil;
    
    NSString *windowName = NSStringFromClass(window.class);
    if (![windowName isEqualToString:@"UIRemoteKeyboardWindow"]) {
        return nil;
    }
    
    for (UIView *view in window.subviews) {
        NSString *viewName = NSStringFromClass(view.class);
        if (![viewName isEqualToString:@"UIInputSetContainerView"]) {
            continue;
        }
        for (UIView *subView in view.subviews) {
            NSString *subViewName = NSStringFromClass(subView.class);
            if (![subViewName isEqualToString:@"UIInputSetHostView"]) {
                continue;
            }
            return subView;
        }
    }
    
    return nil;
}

+ (BOOL)isKeyboardVisible {
    UIView *keyboardView = self.keyboardView;
    UIWindow *keyboardWindow = keyboardView.window;
    if (!keyboardView || !keyboardWindow) {
        return NO;
    }
    CGRect rect = CGRectIntersection(keyboardWindow.bounds, keyboardView.frame);
    if ([QUIKeyboardManager CGRectIsValidated:rect] && !CGRectIsEmpty(rect)) {
        return YES;
    }
    return NO;
}

+ (CGRect)currentKeyboardFrame {
    UIView *keyboardView = [self keyboardView];
    if (!keyboardView) {
        return CGRectNull;
    }
    UIWindow *keyboardWindow = keyboardView.window;
    if (keyboardWindow) {
        return [keyboardWindow convertRect:keyboardView.frame toWindow:nil];
    } else {
        return keyboardView.frame;
    }
}

+ (CGFloat)visibleKeyboardHeight {
    UIView *keyboardView = [self keyboardView];
    UIWindow *keyboardWindow = keyboardView.window;
    if (!keyboardView || !keyboardWindow) {
        return 0;
    } else {
        // 开启了系统的“设置→辅助功能→动态效果→减弱动态效果→首选交叉淡出过渡效果”后，键盘动画不再是 slide，而是 fade，此时应该用 alpha 来判断
        if (keyboardView.alpha <= 0) {
            return 0;
        }
        
        CGRect visibleRect = CGRectIntersection(keyboardWindow.bounds, keyboardView.frame);
        if ([QUIKeyboardManager CGRectIsValidated: visibleRect]) {
            return CGRectGetHeight(visibleRect);
        }
        return 0;
    }
}

/// 判断一个 CGRect 是否合法（例如不带无穷大的值、不带非法数字）
+ (BOOL)CGRectIsValidated:(CGRect)rect {
    return !CGRectIsNull(rect) && !CGRectIsInfinite(rect);
}

@end
