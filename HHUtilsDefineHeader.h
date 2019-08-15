//
//  VKUtilsDefineHeader.h
//  MeiFang
//
//  Created by Evan on 2017/3/14.
//  Copyright © 2017年 Vanke.com All rights reserved.
//
//主要放置一些方便开发的宏

#ifndef VKUtilsDefineHeader_h
#define VKUtilsDefineHeader_h

#define AppContext [HHAPPContext sharedAppContext]
//UI
#define IOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242,2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750,1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define APP_WIDTH [UIScreen mainScreen].bounds.size.width
#define APP_HEIGTH [UIScreen mainScreen].bounds.size.height

//导航栏
#define StatusBarHeight (iPhoneX ? 44.f : 20.f)
#define StatusBarAndNavigationBarHeight (iPhoneX ? 88.f : 64.f)
#define TabbarHeight (iPhoneX ? (49.f + 34.f) : (49.f))
#define BottomSafeAreaHeight (iPhoneX ? (34.f) : (0.f))


#define APP_NAV_HIGH CGRectGetHeight([[UIScreen mainScreen] bounds])
#define FONT(a)      [UIFont systemFontOfSize:a]
#define BFONT(a)     [UIFont boldSystemFontOfSize:a]
#define kFONT(a,b)   [UIFont fontWithName:a size:b]
#define kView_W(View) (View.frame.origin.x + View.bounds.size.width)
#define kView_H(View) (View.frame.origin.y + View.bounds.size.height)
#define kViewW(View) View.bounds.size.width
#define kViewH(View) View.bounds.size.height
#define kViewOriginY(View) View.frame.origin.y
#define kViewOriginX(View) View.frame.origin.x

#define kBaseScreenW 375
#define kBaseScale kScreenWidth*1.0/kBaseScreenW
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kIMAGE(IMAGE_NAME) [UIImage imageNamed:IMAGE_NAME]
#define kSystemFontSize(value) [UIFont systemFontOfSize:value]
#define kBodyFontSize(value) [UIFont boldSystemFontOfSize:value]
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define SAFE_STRING(str) (![str isKindOfClass: [NSString class]] ? [NSString stringWithFormat:@"%@", str] : str)
#define SAFE_ARRAY(value) (![value isKindOfClass: [NSArray class]] ? [NSArray array] : value)
#define SAFE_NUMBER(value) ([value isKindOfClass: [NSNumber class]] ? value : @(-1))


#define kEnvironment 1

// 日志输出
#ifdef DEBUG // 开发阶段-DEBUG阶段:使用Log
#define NSLog(...) NSLog(__VA_ARGS__)
#else // 发布阶段-上线阶段:移除Log
#define NSLog(...)
#endif

#endif /* VKUtilsDefineHeader_h */





