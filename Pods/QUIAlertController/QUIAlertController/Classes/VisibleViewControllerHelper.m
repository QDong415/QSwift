//
//  QAlertViewController
//
//  Created by QDong on 2022-7-30.
//  Copyright (c) 2021年 QDong QQ:285275534@qq.com. All rights reserved.
//

#import "VisibleViewControllerHelper.h"

@interface VisibleViewControllerHelper ()

+ (UIViewController *)q_visibleViewControllerIfExist:(UIViewController *)viewController;

+ (BOOL)q_isViewLoadedAndVisible:(UIViewController *) viewController;

@end

@implementation VisibleViewControllerHelper

+ (nullable UIViewController *)visibleViewController {
    UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *visibleViewController = [VisibleViewControllerHelper q_visibleViewControllerIfExist: rootViewController];
    return visibleViewController;
}



+ (UIViewController *)q_visibleViewControllerIfExist:(UIViewController *)viewController {
    
    if (viewController.presentedViewController) {
        return [VisibleViewControllerHelper q_visibleViewControllerIfExist:viewController.presentedViewController];
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [VisibleViewControllerHelper q_visibleViewControllerIfExist:((UINavigationController *)viewController).visibleViewController];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [VisibleViewControllerHelper q_visibleViewControllerIfExist:((UITabBarController *)viewController).selectedViewController];
    }
    
    if ([VisibleViewControllerHelper q_isViewLoadedAndVisible:viewController]) {
        return viewController;
    } else {
        return nil;
    }
}

+ (BOOL)q_isViewLoadedAndVisible:(UIViewController *) viewController {
    return viewController.isViewLoaded && [VisibleViewControllerHelper q_visible:viewController.view];
}

+ (BOOL)q_visible:(UIView *)view {
    if (view.hidden || view.alpha <= 0.01) {
        return NO;
    }
    if (view.window) {
        return YES;
    }
    if ([self isKindOfClass:UIWindow.class]) {
        if (@available(iOS 13.0, *)) {
            return !!((UIWindow *)self).windowScene;
        } else {
            return YES;
        }
    }
    return YES;
//    UIViewController *viewController = self.q_viewController;
//    return viewController.q_visibleState >= QUIViewControllerWillAppear && viewController.q_visibleState < QUIViewControllerWillDisappear;
}



@end

