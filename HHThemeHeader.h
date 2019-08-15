//
//  VKThemeHeader.h
//  MeiFang
//
//  Created by Evan on 2017/3/14.
//  Copyright © 2017年 Vanke.com All rights reserved.
//
//主题相关

#ifndef VKThemeHeader_h
#define VKThemeHeader_h

//Font


//Color
#define RGBA(r,g,b,a)       [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r,g,b)          [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define XRGB(r,g,b)         [UIColor colorWithRed:(0x##r)/255.0 green:(0x##g)/255.0 blue:(0x##b)/255.0 alpha:1]
#define UIColorFromRGB(rgbValue ,alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((alphaValue>=0 && alphaValue <=1.0) ? alphaValue : 1.0)]

//#define COLOR_SPLINE    XRGB(e0, e0, e0)  //分割线灰色
//#define COLOR_NAVBG     XRGB(ff, ff, ff)  //白色
//#define COLOR_FLUSH     XRGB(66, 66, 66)  //灰色
//#define COLOR_TBLINE    XRGB(e0, e0, e0)  //列表分割线
//#define COLOR_VIEWGB    XRGB(f5, f5, f5)  //view背景灰色
//#define COLOR_BLUE      XRGB(50, a5, fa)  //淡蓝色
//
//#define COLOR_TEXT33    XRGB(33, 33, 33)   //主题黑色
//#define COLOR_TEXT66    XRGB(66, 66, 66)   //主题黑灰色
//#define COLOR_TEXT99    XRGB(99, 99, 99)   //主题灰色
//#define COLOR_TEXTBB    XRGB(bb, bb, bb)   //主题淡灰色
//#define COLOR_TEXTFF    XRGB(ff, ff, ff)   //主题白色
//
//#define COLOR_PINK      XRGB(e6, 00, 12)   //红色
//#define COLOR_GEEN      XRGB(33, be, 6e)   //绿色
//#define COLOR_MASK      XRGB(00, 00, 00)   //黑色
//
//#define MFNoticeGrayColor     XRGB(f5,f5,f5) //灰色
//#define MFNoticeRedColor      XRGB(f0,66,71) //红色
//#define MFNoticeGreenColor    XRGB(33,be,6e) //绿色
//#define MFNoticeOregenColor   XRGB(f0,a5,23) //橙色
//#define MFNoticeYellowColor   XRGB(d8,c8,1a) //黄色


#define COLOR_LIGHTPINK UIColorFromRGB(0xe60012, 0.2) //浅红

#define kTextColor_3 @"#333333"     //主题黑色(字体)
#define kTextColor_C @"#656D78"     //深灰色
#define kRedColor    @"#f05141"     //主题红色
#define kBlueColor   @"#38ACFF"     //主题蓝色//原色值#50A5FA
#define kBlackColor  @"#000000"     //黑色
//辅助色
#define kWhiteColor   @"#FFFFFF"    //白色
#define kTextColor_6  @"#666666"    //灰色
#define kTextColor_9  @"#999999"    //浅灰色
#define kGrayColor_Light @"#F5F5F5"  //浅浅灰色
#define kGrayColor_White @"#dcdcdc"  //超浅灰白色
#define kRedColor_Dark   @"#C80012"  //深红色
#define kBlueColor_Light @"#46BEFF"  //浅蓝色
#define kBlueColor_Dark  @"#1496FA"  //深蓝色

//线、边框
#define kGrayColor_2 @"#E0E0E0"      //浅灰 分割线
#define kGrayColor_B @"#BBBBBB"      //灰
#define kGrayColor_4 @"#F0F0F0"      //浅浅灰色
//状态、图表提示色
#define kGreenColor  @"#80cbc4"      //绿色
#define kRedColor_1  @"#F05050"      //浅红色 房源
#define kOrangeColor @"#ffc438"      //橙色
#define kBlueColor_1 @"#87c9e0"      //浅蓝色
#define kPurpleColor @"#d1abe5"      //浅紫色


//字体大小
//导航栏
#define kTextFont_18  @"18"   //一级导航栏、列表标题、正文一级标题
#define kTextFont_16  @"16"   //二级导航栏、目录列表、正文二级标题
#define kTextFont_14  @"14"   //列表内容、标题栏操作类文本
#define kTextFont_12  @"12"   //注释、角标、提示性弱显文本

//字体
#define kFoneName_Helvetica @"Helvetica"
#define kTitleName_PingFang_R @"PingFang-SC-Regular"
#define kTitleName_PingFang_M @"PingFang-SC-Medium"

#define kBarColor [UIColor colorWithHex:@"32c87d"]


#endif /* VKThemeHeader_h */
