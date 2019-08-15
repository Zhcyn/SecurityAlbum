//
//  NSDate+Additions.h
//  KXFramework
//
//  Created by kyori.hu on 13-6-3.
//  Copyright (c) 2013 kuxun.cn. All rights reserved.
//

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//--------------------------------------------------------------------------------
//
//	Additions
//
//--------------------------------------------------------------------------------

@interface NSDate (Additions)

+ (NSDate *)dateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day;

- (NSString *)yyyymmdd;
- (NSString *)yyyymmddhhmmss;

// Relative dates from the current date
//将时间戳转为时间
+ (NSString *)dateWithTimeStramp:(NSString *)timeStramp;
+ (NSDate *)dateTomorrow;
+ (NSDate *)dateYesterday;
+ (NSDate *)dateWithDaysFromNow:(NSUInteger) days;
+ (NSDate *)dateWithDaysBeforeNow:(NSUInteger) days;
+ (NSDate *)dateWithHoursFromNow:(NSUInteger) dHours;
+ (NSDate *)dateWithHoursBeforeNow:(NSUInteger) dHours;
+ (NSDate *)dateWithMinutesFromNow:(NSUInteger) dMinutes;
+ (NSDate *)dateWithMinutesBeforeNow:(NSUInteger) dMinutes;

// Comparing dates
- (BOOL)isEqualToDateIgnoringTime:(NSDate *) aDate;
- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isYesterday;
- (BOOL)isSameWeekAsDate:(NSDate *)aDate;
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;
- (BOOL)isSameYearAsDate:(NSDate *)aDate;
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;
- (BOOL)isEarlierThanDate:(NSDate *) Date;
- (BOOL)isLaterThanDate:(NSDate *)aDate;

// Adjusting dates
- (NSDate *)dateByAddingDays:(NSUInteger)dDays;
- (NSDate *)dateBySubtractingDays:(NSUInteger)dDays;
- (NSDate *)dateByAddingHours:(NSUInteger)dHours;
- (NSDate *)dateBySubtractingHours:(NSUInteger)dHours;
- (NSDate *)dateByAddingMinutes:(NSUInteger)dMinutes;
- (NSDate *)dateBySubtractingMinutes:(NSUInteger)dMinutes;
- (NSDate *)dateAtStartOfDay;

// Retrieving intervals
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
- (NSInteger)minutesBeforeDate:(NSDate *)aDate;
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)hoursBeforeDate:(NSDate *)aDate;
- (NSInteger)daysAfterDate:(NSDate *)aDate;
- (NSInteger)daysBeforeDate:(NSDate *)aDate;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;

@end


//--------------------------------------------------------------------------------
//
//	ext_string
//
//--------------------------------------------------------------------------------

@interface NSDate (ext_string)

- (NSString *)xingqiString; //星期
- (NSString *)zhouString;   //周

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

- (NSComparisonResult)compareDate:(NSDate *)anotherDate; //只比较日期上的大小

- (NSString *)toHHMM;
- (NSString *)toYYYYMMDD;
- (NSString *)toYearMonthDay;
- (NSString *)toYYYY_MM_DD;
- (NSString *)toYYYY_MM_DD1;
- (NSString *)toYYYYMMDDHHMMSS;
- (NSString *)yoMM_DD;

+ (NSDate *)dateWithYYYYMMDD:(NSString *)strDate;
+ (NSDate *)dateWithYYYY_MM_DD:(NSString *)strDate;
+ (NSDate *)dateWithYYYY_MM_DD1:(NSString *)strDate;
+ (NSDate *)dateWithYYYY_MM_DD:(NSString *)strDate HH_MM:(NSString *)strTime;

@end


void ParseDate(NSDate *date, NSInteger *year, NSInteger *month, NSInteger* day);
void ParseDateWeek(NSDate *date, NSInteger *year, NSInteger *month, NSInteger* day, NSInteger *week);

