//
//  XPPasswordTool.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/6.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "HHPasswordTool.h"

@implementation HHPasswordTool

/**
 是否已经设置过密码
 
 @return YES:已设置了密码 NO:首次使用,还未设置密码
 */
+ (BOOL)isSetPassword {
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:XPPasswordKey];
    // 密码采用MD5加密,长度固定为32个字符
    return password.length;
}

///**
// 是否开启了TouchID功能
// */
//+ (BOOL)isEnableTouchID {
//    BOOL isEnable = [[NSUserDefaults standardUserDefaults] boolForKey:XPTouchEnableStateKey];
//    return isEnable;
//}

/**
 校验给定的密码是否与用户设置的密码匹配
 
 @param password 待校验的密码明文
 @return Bool
 */
+ (BOOL)verifyPassword:(NSString *)password {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *psd = [userDefaults objectForKey:XPPasswordKey];
    return [password isEqualToString:psd];
}

/**
 存储密码到本地沙盒文件中
 
 @param password 待存储的密码明文(存储之前会进行加密)
 */
+ (void)storagePassword:(NSString *)password {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:password forKey:XPPasswordKey];
    [userDefaults synchronize];
}
@end
