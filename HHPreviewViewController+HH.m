//
//  HHPreviewViewController+HH.m
//  PhotoSecurity
//
//  Created by Evan on 2019/8/11.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHPreviewViewController+HH.h"
#import <objc/runtime.h>

@implementation HHPreviewViewController (HH)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([HHPreviewViewController class], @selector(preferredStatusBarStyle));
        Method swizzledMethod = class_getInstanceMethod([HHPreviewViewController class], @selector(ql_preferredStatusBarStyle));
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        
        Method originalMethod1 = class_getInstanceMethod([HHPreviewViewController class], @selector(backgroundColor));
        Method swizzledMethod1 = class_getInstanceMethod([HHPreviewViewController class], @selector(ql_backgroundColor));
        method_exchangeImplementations(originalMethod1, swizzledMethod1);

    });
}


- (UIStatusBarStyle)ql_preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIColor *)ql_backgroundColor{
    return [UIColor colorWithHex:@"#f0f0f0"];
}

@end
