//
//  NSDate+Additions.m
//  KXFramework
//
//  Created by kyori.hu on 13-6-3.
//  Copyright (c) 2013 kuxun.cn. All rights reserved.
//

#import "NSDate+Util.h"

#define DATE_COMPONENTS (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)

#define CURRENT_CALENDAR [NSCalendar currentCalendar]

//--------------------------------------------------------------------------------
//
//	Additions
//
//--------------------------------------------------------------------------------

@implementation NSDate (Additions)

+ (NSDate *)dateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    NSDate *date = [calendar dateFromComponents:comps];
    
    return date;
}


- (NSString *)yyyymmdd
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    NSInteger year = comps.year;
    NSInteger month = comps.month;
    NSInteger day = comps.day;
    
    NSString *strDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", (long)year, (long)month, (long)day];
    
    return strDate;
}


- (NSString *)yyyymmddhhmmss
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond
                                          fromDate:self];
    NSInteger year = comps.year;
    NSInteger month = comps.month;
    NSInteger day = comps.day;
    
    NSString *strDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld", (long)year, (long)month, (long)day, (long)comps.hour, (long)comps.minute, (long)comps.second];
    
    return strDate;
}


#pragma mark -
#pragma mark Relative Dates

+ (NSDate *)dateWithDaysFromNow:(NSUInteger) days
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_DAY * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}


+ (NSDate *)dateWithDaysBeforeNow:(NSUInteger)days
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_DAY * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSString *)dateWithTimeStramp:(NSString *)timeStramp {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //（@"YYYY-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timeStramp longLongValue]/1000];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

+ (NSDate *)dateTomorrow {
    return [NSDate dateWithDaysFromNow:1];
}


+ (NSDate *)dateYesterday {
    return [NSDate dateWithDaysBeforeNow:1];
}


+ (NSDate *)dateWithHoursFromNow:(NSUInteger)dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}


+ (NSDate *)dateWithHoursBeforeNow:(NSUInteger)dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}


+ (NSDate *)dateWithMinutesFromNow:(NSUInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}


+ (NSDate *)dateWithMinutesBeforeNow:(NSUInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}


#pragma mark -
#pragma mark Comparing Dates


- (BOOL)isEqualToDateIgnoringTime: (NSDate *) aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    return (([components1 year] == [components2 year]) &&
            ([components1 month] == [components2 month]) &&
            ([components1 day] == [components2 day]));
}


- (BOOL)isToday {
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}


- (BOOL)isTomorrow {
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}


- (BOOL)isYesterday {
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}


// This hard codes the assumption that a week is 7 days
- (BOOL)isSameWeekAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if ([components1 weekOfMonth] != [components2 weekOfMonth])
        return NO;
    
    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}


- (BOOL)isThisWeek
{
    return [self isSameWeekAsDate:[NSDate date]];
}


- (BOOL)isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    
    return [self isSameYearAsDate:newDate];
}


- (BOOL)isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    
    return [self isSameYearAsDate:newDate];
}


- (BOOL)isSameYearAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:aDate];
    
    return ([components1 year] == [components2 year]);
}


- (BOOL)isThisYear
{
    return [self isSameWeekAsDate:[NSDate date]];
}


- (BOOL)isNextYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return ([components1 year] == ([components2 year] + 1));
}


- (BOOL)isLastYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return ([components1 year] == ([components2 year] - 1));
}


- (BOOL)isEarlierThanDate:(NSDate *)aDate
{
    return ([self earlierDate:aDate] == self);
}


- (BOOL)isLaterThanDate:(NSDate *)aDate
{
    return ([self laterDate:aDate] == self);
}


#pragma mark -
#pragma mark Adjusting Dates

- (NSDate *)dateByAddingDays:(NSUInteger)dDays
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}


- (NSDate *)dateBySubtractingDays:(NSUInteger)dDays
{
    return [self dateByAddingDays:(dDays * -1)];
}


- (NSDate *)dateByAddingHours:(NSUInteger)dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}


- (NSDate *)dateBySubtractingHours:(NSUInteger)dHours
{
    return [self dateByAddingHours: (dHours * -1)];
}


- (NSDate *)dateByAddingMinutes:(NSUInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}


- (NSDate *)dateBySubtractingMinutes:(NSUInteger)dMinutes
{
    return [self dateByAddingMinutes: (dMinutes * -1)];
}


- (NSDate *)dateAtStartOfDay
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return [CURRENT_CALENDAR dateFromComponents:components];
}


- (NSDateComponents *)componentsWithOffsetFromDate:(NSDate *)aDate
{
    NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
    return dTime;
}


#pragma mark -
#pragma mark Retrieving Intervals

- (NSInteger)minutesAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}


- (NSInteger)minutesBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}


- (NSInteger)hoursAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}


- (NSInteger)hoursBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}


- (NSInteger)daysAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}





- (NSInteger)daysBeforeDate:(NSDate *)aDate
{
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fromDate;
    NSDate *toDate;
    
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:self];
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:[NSDate date]];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    return dayComponents.day;
    //
    //	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    //	return (NSInteger) (ti / D_DAY);
}


#pragma mark -
#pragma mark Decomposing Dates

- (NSInteger)nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitHour fromDate:newDate];
    return [components hour];
}


- (NSInteger)hour
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components hour];
}


- (NSInteger)minute
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components minute];
}


- (NSInteger)seconds
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components second];
}


- (NSInteger)day
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components day];
}


- (NSInteger)month
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components month];
}


- (NSInteger)week
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components weekOfMonth];
}


- (NSInteger)weekday
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components weekday];
}


- (NSInteger)nthWeekday
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components weekdayOrdinal];
}


- (NSInteger)year
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return [components year];
}

@end


//--------------------------------------------------------------------------------
//
//	ext_string
//
//--------------------------------------------------------------------------------

@implementation NSDate (ext_string)

NSString *g_strXingqi[] = {
    @"星期日",
    @"星期一",
    @"星期二",
    @"星期三",
    @"星期四",
    @"星期五",
    @"星期六"
};

NSString *g_strZhou[] = {
    @"周日",
    @"周一",
    @"周二",
    @"周三",
    @"周四",
    @"周五",
    @"周六"
};

#define kDataFormat_DateTime        @"yyyy-MM-dd HH:mm:ss"
#define kDataFormat_Date            @"yyyy-MM-dd"
#define kDataFormat_Time            @"HH:mm:ss"
#define kDataFormat_YYYYMMDD        @"yyyyMMdd"
#define kDataFormat_YYYYMMDDHHMMSS  @"yyyy-MM-dd HH:mm:ss"


- (NSString *) xingqiString
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:kCFCalendarUnitWeekday|NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    
    if ( comps.weekday > 0 && comps.weekday <= 7) {
        return g_strXingqi[comps.weekday-1];
    }
    else {
        return @"";
    }
}


- (NSString *)zhouString
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:kCFCalendarUnitWeekday|NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    if ( comps.weekday > 0 && comps.weekday <= 7) {
        return g_strZhou[comps.weekday-1];
    }
    else {
        return @"";
    }
}


+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *t_date = [dateFormatter dateFromString:dateString];
    return t_date;
}

- (NSString *)toYearMonthDay
{
    NSInteger year, month, day;
    ParseDate(self, &year, &month, &day);
    return [NSString stringWithFormat:@"%04ld年%02ld月%02ld日", (long)year, (long)month, (long)day];
}

- (NSString *)toHHMM
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *str = [dateFormatter stringFromDate:self];
    
    return str;
}

- (NSString *)toYYYYMMDD
{
    NSInteger year, month, day;
    ParseDate(self, &year, &month, &day);
    return [NSString stringWithFormat:@"%04ld%02ld%02ld", (long)year, (long)month, (long)day];
}


- (NSString *)toYYYY_MM_DD
{
    NSInteger year, month, day;
    ParseDate(self, &year, &month, &day);
    return [NSString stringWithFormat:@"%04ld-%02ld-%02ld", (long)year, (long)month, (long)day];
}

- (NSString *)toYYYY_MM_DD1
{
    NSInteger year, month, day;
    ParseDate(self, &year, &month, &day);
    return [NSString stringWithFormat:@"%04ld/%02ld/%02ld", (long)year, (long)month, (long)day];
}


- (NSString *)toYYYYMMDDHHMMSS
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDataFormat_YYYYMMDDHHMMSS];
    NSString *str = [dateFormatter stringFromDate:self];
    
    return str;
}


- (NSString *)yoMM_DD
{
    NSInteger year, month, day;
    ParseDate(self, &year, &month, &day);
    return [NSString stringWithFormat:@"%02ld-%02ld", (long)month, (long)day];
}

//只比较日期上的大小
- (NSComparisonResult)compareDate:(NSDate *)anotherDate
{
    NSString *str1 = [self toYYYYMMDD];
    NSString *str2 = [anotherDate toYYYYMMDD];
    return [str1 compare:str2];
}


+ (NSDate *)dateWithYYYYMMDD:(NSString *)strDate
{
    if (strDate.length != 8)
        return nil;
    int n = [strDate intValue];
    int year = n/10000;
    int month = (n/100) % 100;
    int day = n % 100;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:year];
    [comps setMonth:month];
    [comps setDay:day];
    NSDate *date = [calendar dateFromComponents:comps];
    
    return date;
}


+ (NSDate *)dateWithYYYY_MM_DD:(NSString *)strDate
{
    NSArray *arr = [strDate componentsSeparatedByString:@"-"];
    if ( arr.count == 3 ) {
        int year = [[arr objectAtIndex:0] intValue];
        int month = [[arr objectAtIndex:1] intValue];
        int day = [[arr objectAtIndex:2] intValue];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:year];
        [comps setMonth:month];
        [comps setDay:day];
        NSDate *date = [calendar dateFromComponents:comps];
        return date;
    }
    return nil;
}

+ (NSDate *)dateWithYYYY_MM_DD1:(NSString *)strDate
{
    NSArray *arr = [strDate componentsSeparatedByString:@"-"];
    if ( arr.count == 3 ) {
        int year = [[arr objectAtIndex:0] intValue];
        int month = [[arr objectAtIndex:1] intValue];
        int day = [[arr objectAtIndex:2] intValue];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:year];
        [comps setMonth:month];
        [comps setDay:day+1];
        NSDate *date = [calendar dateFromComponents:comps];
        
        return date;
    }
    return nil;
}

+ (NSDate *)dateWithYYYY_MM_DD:(NSString *)strDate HH_MM:(NSString *)strTime
{
    if ( strTime.length == 0 ) {
        strTime = @"00:00";
    }
    
    NSArray *arrDate = [strDate componentsSeparatedByString:@"-"];
    NSArray *arrTime = [strTime componentsSeparatedByString:@":"];
    
    if (arrDate.count == 3 && arrTime.count == 2) {
        int year = [[arrDate objectAtIndex:0] intValue];
        int month = [[arrDate objectAtIndex:1] intValue];
        int day = [[arrDate objectAtIndex:2] intValue];
        int hour = [[arrTime objectAtIndex:0] intValue];
        int min = [[arrTime objectAtIndex:1] intValue];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:year];
        [comps setMonth:month];
        [comps setDay:day];
        [comps setHour:hour];
        [comps setMinute:min];
        NSDate *date = [calendar dateFromComponents:comps];
        
        return date;
    }
    return nil;
}

@end


void ParseDate(NSDate *date, NSInteger *year, NSInteger *month, NSInteger *day)
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    *year = comps.year;
    *month = comps.month;
    *day = comps.day;
}


void ParseDateWeek(NSDate *date, NSInteger *year, NSInteger *month, NSInteger *day, NSInteger *week)
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:date];
    *year = comps.year;
    *month = comps.month;
    *day = comps.day;
    *week = comps.weekday;
}

