//
// NSDate+Helper.h
//
// Created by Billy Gray on 2/26/09.
// Copyright (c) 2009, 2010, ZETETIC LLC
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the ZETETIC LLC nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY ZETETIC LLC ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL ZETETIC LLC BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSDate+Helper.h"
#import "NSDate+Category.h"

@implementation NSDate (Helper)

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
    NSDateComponents *components =
        [[NSCalendar currentCalendar] components:(NSCalendarUnitDay)fromDate:self toDate:[NSDate date] options:0];
    return [components day];
}

- (NSInteger)secondAgo {
    NSDateComponents *components =
        [[NSCalendar currentCalendar] components:(NSCalendarUnitSecond)fromDate:self toDate:[NSDate date] options:0];
    return [components second];
}

- (NSInteger)minuteCompare:(NSDate *)date {
    NSDateComponents *components =
        [[NSCalendar currentCalendar] components:(NSCalendarUnitMinute)fromDate:self toDate:date options:0];
    return [components minute];
}

- (NSInteger)dayCompare:(NSDate *)date {
    if (date == nil) {
        return 0;
    }
    NSDateComponents *components =
        [[NSCalendar currentCalendar] components:(NSCalendarUnitDay)fromDate:self toDate:date options:0];
    return [components day];
}

- (NSInteger)dayFCompare:(NSDate *)date {
    NSInteger dayInterval = [self dayCompare:date];
    if (0 == dayInterval) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
        NSInteger day = [comps day];
        NSDateComponents *components = [calendar components:unitFlags fromDate:self];
        NSInteger nowDay = [components day];
        dayInterval = nowDay - day;
    }

    return dayInterval;
}

- (NSInteger)hourCompare:(NSDate *)date {
    NSDateComponents *components =
        [[NSCalendar currentCalendar] components:(NSCalendarUnitHour)fromDate:self toDate:date options:0];
    return [components hour];
}

- (NSUInteger)daysAgoAgainstMidnight {
    // get a midnight version of ourself:
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];

    return (int)[midnight timeIntervalSinceNow] / (60 * 60 * 24) * -1;
}

- (NSString *)stringDaysAgo {
    return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
    NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
    NSString *text = nil;
    switch (daysAgo) {
        case 0:
            text = @"Today";
            break;
        case 1:
            text = @"Yesterday";
            break;
        default:
            text = [NSString stringWithFormat:@"%lu days ago", (unsigned long)daysAgo];
    }
    return text;
}

- (NSUInteger)weekday {
    NSDateComponents *weekdayComponents =
        [[NSCalendar currentCalendar] components:(NSCalendarUnitWeekday)fromDate:self];
    return [weekdayComponents weekday];
}

+ (NSDate *)dateFromString:(NSString *)string {
    return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:format];

    NSDate *date = [inputFormatter dateFromString:string];
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    NSInteger frominterval = [fromzone secondsFromGMTForDate:date];
    date = [date dateByAddingTimeInterval:frominterval];
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    return [date string];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime {
    /*
         * if the date is in today, display 12-hour time with meridian,
         * if it is within the last 7 days, display weekday name (Friday)
         * if within the calendar year, display as Jan 23
         * else display as Nov 11, 2008
         */

    NSDate *today = [NSDate date];
    NSDateComponents *offsetComponents =
        [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                        fromDate:today];

    NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:offsetComponents];

    NSString *displayString = nil;
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    // comparing against midnight
    if ([date compare:midnight] == NSOrderedDescending) {
        if (prefixed) {
            [displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
        } else {
            [displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
        }
    } else {
        // check if date is within last 7 days
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-7];
        NSDate *lastweek =
            [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:today options:0];
        if ([date compare:lastweek] == NSOrderedDescending) {
            if (displayTime)
                [displayFormatter setDateFormat:@"EEEE h:mm a"]; // Tuesday
            else
                [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
        } else {
            // check if same calendar year
            NSInteger thisYear = [offsetComponents year];

            NSDateComponents *dateComponents =
                [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                fromDate:date];
            NSInteger thatYear = [dateComponents year];
            if (thatYear >= thisYear) {
                if (displayTime)
                    [displayFormatter setDateFormat:@"MMM d h:mm a"];
                else
                    [displayFormatter setDateFormat:@"MMM d"];
            } else {
                if (displayTime)
                    [displayFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
                else
                    [displayFormatter setDateFormat:@"MMM d, yyyy"];
            }
        }
        if (prefixed) {
            NSString *dateFormat = [displayFormatter dateFormat];
            NSString *prefix = @"'on' ";
            [displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
        }
    }

    // use display formatter to return formatted date string
    displayString = [displayFormatter stringFromDate:date];
    return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
    // preserve prior behavior
    return [self stringForDisplayFromDate:date prefixed:prefixed alwaysDisplayTime:NO];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
    return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:format];
    NSString *timestamp_str = [outputFormatter stringFromDate:self];
    return timestamp_str;
}

- (NSString *)string {
    return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateStyle:dateStyle];
    [outputFormatter setTimeStyle:timeStyle];
    NSString *outputString = [outputFormatter stringFromDate:self];
    return outputString;
}

- (NSDate *)beginningOfYear {
    // largely borrowed from "Date and Time Programming Guide for Cocoa"
    // we'll use the default calendar and hope for the best
    
    NSDate *beginningOfYear = nil;
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitYear
                                              startDate:&beginningOfYear
                                               interval:NULL
                                                forDate:self];
    if (ok) {
        return beginningOfYear;
    }
    
    // couldn't calc via range, so try to grab Sunday, assuming gregorian style
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self];
    
    /*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from
     the date in question.  (If today's Sunday, subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:0 - ([weekdayComponents weekday] - 1)];
    beginningOfYear = nil;
    beginningOfYear = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:self options:0];
    
    // normalize to midnight, extract the year, month, and day components and create a new date from those components.
    NSDateComponents *components =
    [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                    fromDate:beginningOfYear];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)beginningOfMonth {
    // largely borrowed from "Date and Time Programming Guide for Cocoa"
    // we'll use the default calendar and hope for the best
    
    NSDate *beginningOfMonth = nil;
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth
                                              startDate:&beginningOfMonth
                                               interval:NULL
                                                forDate:self];
    if (ok) {
        return beginningOfMonth;
    }
    
    // couldn't calc via range, so try to grab Sunday, assuming gregorian style
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self];
    
    /*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from
     the date in question.  (If today's Sunday, subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:0 - ([weekdayComponents weekday] - 1)];
    beginningOfMonth = nil;
    beginningOfMonth = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:self options:0];
    
    // normalize to midnight, extract the year, month, and day components and create a new date from those components.
    NSDateComponents *components =
    [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                    fromDate:beginningOfMonth];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)beginningOfWeek {
    // largely borrowed from "Date and Time Programming Guide for Cocoa"
    // we'll use the default calendar and hope for the best

    NSDate *beginningOfWeek = nil;
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitWeekOfMonth
                                              startDate:&beginningOfWeek
                                               interval:NULL
                                                forDate:self];
    if (ok) {
        return beginningOfWeek;
    }

    // couldn't calc via range, so try to grab Sunday, assuming gregorian style
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self];

    /*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from
     the date in question.  (If today's Sunday, subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:0 - ([weekdayComponents weekday] - 1)];
    beginningOfWeek = nil;
    beginningOfWeek = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:self options:0];

    // normalize to midnight, extract the year, month, and day components and create a new date from those components.
    NSDateComponents *components =
        [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                        fromDate:beginningOfWeek];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
    // Get the weekday component of the current date
    NSDateComponents *components =
        [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                        fromDate:self];
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)endOfWeek {
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    // to get the end of week for a particular date, add (7 - weekday) days
    [componentsToAdd setDay:(7 - [weekdayComponents weekday])];
    NSDate *endOfWeek = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToAdd toDate:self options:0];

    return endOfWeek;
}
- (NSString *)endOfThisWeek {
    NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    // to get the end of week for a particular date, add (7 - weekday) days
    [componentsToAdd setDay:(8 - [weekdayComponents weekday])];
    NSDate *endOfWeek = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToAdd toDate:self options:0];

    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:endOfWeek];
    return firstDay;
}
//- (NSString *)endOfThisWeek {
//    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
//    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
//    
//    NSDate *nowDate = [NSDate date];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
//    
//    NSInteger weekDay = [comp weekday];
//    NSInteger day = [comp day];
//    
//    long firstDiff;
//    long lastDiff;
//    
//    if (weekDay == 1) {
//        firstDiff = -6;
//        lastDiff =  0;
//    }
//    else {
//        firstDiff = [calendar firstWeekday] - weekDay + 1;
//        lastDiff = 0;
//    }
//    
//    
//    NSDateComponents *lastDayComp = [calendar components:unitFlagsR fromDate:nowDate];
//    [lastDayComp setDay:day + lastDiff];
//    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    NSString *firstDay = [formatter stringFromDate:lastDayOfWeek];
//    return firstDay;
//}

- (NSString *)endOfLastWeek {
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
    
    NSInteger weekDay = [comp weekday];
    NSInteger day = [comp day];
    
    long firstDiff;
    long lastDiff;
    
    if (weekDay == 1) {
        firstDiff = -7-6;
        lastDiff = -7+0;
    }
    else {
        firstDiff = -7+[calendar firstWeekday] - weekDay + 1;
        lastDiff = -7+8 - weekDay;
    }
    
    
    NSDateComponents *lastDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:lastDayOfWeek];
    return firstDay;
}

- (NSString *)endOfLast2Week {
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
    
    NSInteger weekDay = [comp weekday];
    NSInteger day = [comp day];
    
    long firstDiff;
    long lastDiff;
    
    if (weekDay == 1) {
        firstDiff = -14-6;
        lastDiff = -14+0;
    }
    else {
        firstDiff = -14+[calendar firstWeekday] - weekDay + 1;
        lastDiff = -14+8-weekDay;
    }
    
    NSDateComponents *lastDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:lastDayOfWeek];
    return firstDay;

}

- (NSString *)endOfLast3Week {
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
    
    NSInteger weekDay = [comp weekday];
    NSInteger day = [comp day];
    
    long firstDiff;
    long lastDiff;
    
    if (weekDay == 1) {
        firstDiff = -14-6;
        lastDiff = -14+0;
    }
    else {
        firstDiff = -21+[calendar firstWeekday] - weekDay + 1;
        lastDiff = -21+8-weekDay;
    }
    
    NSDateComponents *lastDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:lastDayOfWeek];
    return firstDay;
    
}


- (NSString *)beginingOfYearStr {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSDate *currentYearDate = [self beginningOfYear];
    NSInteger interval = [zone secondsFromGMTForDate: currentYearDate];
    NSDate *localeCurrentDate = [currentYearDate  dateByAddingTimeInterval: interval];
    NSString *currentDateStr = [NSString stringWithFormat:@"%@",localeCurrentDate];
    return currentDateStr;
}

- (NSString *)beginingOfMonthStr {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSDate *currentMonthDate = [self beginningOfMonth];
    NSInteger interval = [zone secondsFromGMTForDate: currentMonthDate];
    NSDate *localeCurrentDate = [currentMonthDate  dateByAddingTimeInterval: interval];
    NSString *currentDateStr = [NSString stringWithFormat:@"%@",localeCurrentDate];
    return currentDateStr;
}

- (NSString *)beginningOfWeekStr {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSDate *currentWeekDate = [[[NSDate alloc] init] beginningOfWeek];
    NSInteger interval = [zone secondsFromGMTForDate: currentWeekDate];
    NSDate *localeCurrentDate = [currentWeekDate  dateByAddingTimeInterval: interval];
    NSString *currentDateStr = [NSString stringWithFormat:@"%@",localeCurrentDate];
    return currentDateStr;

}
- (NSString *)beginningOfDayStr {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSDate *currentDayDate = [[[NSDate alloc] init] beginningOfDay];
    NSInteger interval = [zone secondsFromGMTForDate: currentDayDate];
    NSDate *localeCurrentDate = [currentDayDate  dateByAddingTimeInterval: interval];
    NSString *currentDateStr = [NSString stringWithFormat:@"%@",localeCurrentDate];
    return currentDateStr;

}

- (NSString *)beginingOfDayFromNow:(NSUInteger)intergerDay {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSDate *currentDayDate = [NSDate dateWithDaysFromNow:intergerDay];
    NSInteger interval = [zone secondsFromGMTForDate: currentDayDate];
    NSDate *localeCurrentDate = [currentDayDate  dateByAddingTimeInterval: interval];
    NSString *currentDateStr = [NSString stringWithFormat:@"%@",localeCurrentDate];
    return currentDateStr;
}

- (NSString *)beginingOfDayBeforeNow:(NSUInteger)intergerDay {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSDate *currentDayDate = [NSDate dateWithDaysBeforeNow:intergerDay];
    NSInteger interval = [zone secondsFromGMTForDate: currentDayDate];
    NSDate *localeCurrentDate = [currentDayDate  dateByAddingTimeInterval: interval];
    NSString *currentDateStr = [NSString stringWithFormat:@"%@",localeCurrentDate];
    return currentDateStr;
}


- (NSString *)beginingOfWeek {
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
    
    NSInteger weekDay = [comp weekday];
    NSInteger day = [comp day];
    
    long firstDiff;
    long lastDiff;
    
    if (weekDay == 1) {
        firstDiff = -6;
        lastDiff =  0;
    }
    else {
        firstDiff = [calendar firstWeekday] - weekDay + 1;
        lastDiff = 0;
    }
    
    NSDateComponents *firstDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:firstDayOfWeek];
    return firstDay;
}

- (NSString *)beginingOfLastWeek {
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
    
    NSInteger weekDay = [comp weekday];
    NSInteger day = [comp day];
    
    long firstDiff;
    long lastDiff;
    
    if (weekDay == 1) {
        firstDiff = -7-6;
        lastDiff = -7+0;
    }
    else {
        firstDiff = -7+[calendar firstWeekday] - weekDay + 1;
        lastDiff = -7+8 - weekDay;
    }
    
    NSDateComponents *firstDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:firstDayOfWeek];
    return firstDay;
}

- (NSString *)beginingOfLast2Week {
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
    
    NSInteger weekDay = [comp weekday];
    NSInteger day = [comp day];
    
    long firstDiff;
    long lastDiff;
    
    if (weekDay == 1) {
        firstDiff = -14-6;
        lastDiff = -14+0;
    }
    else {
        firstDiff = -14+[calendar firstWeekday] - weekDay + 1;
        lastDiff = -14+8-weekDay;
    }
    
    NSDateComponents *firstDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:firstDayOfWeek];
    return firstDay;
}

- (NSString *)lastDay {
    NSDate *lastDayDate = [NSDate dateWithDaysBeforeNow:1];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *firstDay = [formatter stringFromDate:lastDayDate];
    
    return firstDay;
}

- (NSString *)lastDayWithCustomDate{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] - D_DAY;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *firstDay = [formatter stringFromDate:newDate];
    
    return firstDay;
}

- (NSString *)thisWeek {
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
    
    NSInteger weekDay = [comp weekday];
    NSInteger day = [comp day];
    
    long firstDiff;
    long lastDiff;
    
    if (weekDay == 1) {
        firstDiff = -6;
        lastDiff =  0;
    }
    else {
        firstDiff = [calendar firstWeekday] - weekDay + 1;
        lastDiff = 0;
    }
    
    NSDateComponents *firstDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
    NSString *dateString = [NSDate fromDate:firstDayOfWeek toDate:lastDayOfWeek];
    return dateString;
}

- (NSString *)last1Week{
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
    
    NSInteger weekDay = [comp weekday];
    NSInteger day = [comp day];
    
    long firstDiff;
    long lastDiff;
    
    if (weekDay == 1) {
        firstDiff = -7-6;
        lastDiff = -7+0;
    }
    else {
        firstDiff = -7+[calendar firstWeekday] - weekDay + 1;
        lastDiff = -7+8 - weekDay;
    }
    
    NSDateComponents *firstDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
    
    NSString *dateString = [NSDate fromDate:firstDayOfWeek toDate:lastDayOfWeek];
    return dateString;
}

- (NSString *)last2Week {
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSInteger unitFlagsR = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:nowDate];
    
    NSInteger weekDay = [comp weekday];
    NSInteger day = [comp day];
    
    long firstDiff;
    long lastDiff;
    
    if (weekDay == 1) {
        firstDiff = -14-6;
        lastDiff = -14+0;
    }
    else {
        firstDiff = -14+[calendar firstWeekday] - weekDay + 1;
        lastDiff = -14+8-weekDay;
    }
    
    NSDateComponents *firstDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:unitFlagsR fromDate:nowDate];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
    
    NSString *dateString = [NSDate fromDate:firstDayOfWeek toDate:lastDayOfWeek];
    return dateString;
}

- (NSString *)thisMonthFirstDay {
    NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags
                                         fromDate:nowDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [calendar dateFromComponents:comp];
    NSString *firstDay = [formatter stringFromDate:date];
    return firstDay;
    
}
- (NSString *)thisMonthLastDay {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.month = 1;
    comp.day = -1;
    
    
    NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth;
    NSDate *nowDate = [NSDate date];
    NSDateComponents *firstDaycomp = [calendar components:unitFlags
                                         fromDate:nowDate];
    
    
    NSDate *firstDay = [calendar dateFromComponents:firstDaycomp];
    NSDate *date = [calendar dateByAddingComponents:comp
                                             toDate:firstDay
                                            options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDayStr = [formatter stringFromDate:date];
    return firstDayStr;
    
}

- (NSString *)lastMonthLastDay {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.month = 0;
    comp.day = -1;
    
    
    NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth;
    NSDate *nowDate = [NSDate date];
    NSDateComponents *firstDaycomp = [calendar components:unitFlags
                                                 fromDate:nowDate];
    
    
    NSDate *firstDay = [calendar dateFromComponents:firstDaycomp];
    NSDate *date = [calendar dateByAddingComponents:comp
                                             toDate:firstDay
                                            options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDayStr = [formatter stringFromDate:date];
    return firstDayStr;
    
}

- (NSString *)thisYearFirstDay {
    
    NSInteger unitFlags = NSCalendarUnitYear;
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags
                                         fromDate:nowDate];
    
    NSDate *date = [calendar dateFromComponents:comp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDayStr = [formatter stringFromDate:date];
    return firstDayStr;
    
}
- (NSString *)thisYearLastDay {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.year = 1;
    comp.day = -1;
    
    
    NSInteger unitFlags = NSCalendarUnitYear;
    
    NSDate *nowDate = [NSDate date];
    NSDateComponents *comp2 = [calendar components:unitFlags
                                         fromDate:nowDate];
    
    NSDate *date2 = [calendar dateFromComponents:comp2];
    
    NSDate *date = [calendar dateByAddingComponents:comp
                                             toDate:date2
                                            options:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDayStr = [formatter stringFromDate:date];
    return firstDayStr;
  
}

- (NSString *)lastYearLastDay {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.year = 0;
    comp.day = -1;
    
    
    NSInteger unitFlags = NSCalendarUnitYear;
    
    NSDate *nowDate = [NSDate date];
    NSDateComponents *comp2 = [calendar components:unitFlags
                                          fromDate:nowDate];
    
    NSDate *date2 = [calendar dateFromComponents:comp2];
    
    NSDate *date = [calendar dateByAddingComponents:comp
                                             toDate:date2
                                            options:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDayStr = [formatter stringFromDate:date];
    return firstDayStr;
    
}

+ (NSString *)fromDate:(NSDate *)foromDate toDate:(NSDate *)toDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *firstDay = [formatter stringFromDate:foromDate];
    NSString *lastDay = [formatter stringFromDate:toDate];
    NSString *dateStr = [NSString stringWithFormat:@"[%@_%@]",firstDay,lastDay];
    return dateStr;
}

+ (NSString *)dateFormatString {
    return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString {
    return @"HH:mm:ss";
}

+ (NSString *)timestampFormatString {
    return @"yyyy-MM-dd HH:mm:ss";
}

// preserving for compatibility
+ (NSString *)dbFormatString {
    return [NSDate timestampFormatString];
}

+ (NSString *)dateFormatString:(NSDate *)date {
    NSString *showDate = nil;
    NSDate *curendate = [NSDate date];
    NSInteger inter = [date dayCompare:curendate];

    if (ABS(inter) > 1) {
        showDate = [date stringWithFormat:@"yyyy-MM-dd HH:mm"];
    } else if (inter == 0) {
        {
            if ([date dayFCompare:date] == 0 || [date compare:date] == NSOrderedSame) {
                showDate = [NSString stringWithFormat:@"Today %@", [date stringWithFormat:@"HH:mm"]];
            } else if (1 != labs([date dayFCompare:date]) || [date compare:date] == NSOrderedAscending) {
                showDate = [date stringWithFormat:@"yyyy-MM-dd HH:mm"];
            } else {
                showDate = [NSString stringWithFormat:@"Yesterday %@", [date stringWithFormat:@"HH:mm"]];
            }
        }
    } else if (1 == inter) {
        long cuday = [date dayFCompare:date];
        if (labs(cuday) > 1) {
            showDate = [date stringWithFormat:@"yyyy-MM-dd HH:mm"];
        } else {
            showDate = [NSString stringWithFormat:@"Yesterday %@", [date stringWithFormat:@"HH:mm"]];
        }
    } else {
        showDate = [date stringWithFormat:@"yyyy-MM-dd HH:mm"];
    }

    return showDate;
}

#pragma mark - Schedule

- (NSDate *)lastDayOfMonth {
    NSInteger dayCount = [self numberOfDaysInMonthCount];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

    NSDateComponents *comp =
        [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];

    [comp setDay:dayCount];

    return [calendar dateFromComponents:comp];
}

- (NSInteger)numberOfDaysInMonthCount {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    //    [calendar setTimeZone:[NSTimeZone timeZoneWithName:TIMEZONE]];

    NSRange dayRange = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];

    return dayRange.length;
}

- (NSInteger)numberOfWeekInMonthCount {

    NSCalendar *calender = [NSCalendar currentCalendar];
    NSRange weekRange = [calender rangeOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:self];
    return weekRange.length;
}

- (NSDateComponents *)componentsOfDate {

    return [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |
                                                    NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute
                                           fromDate:self];
}

#pragma mark - Methods Statics
+ (NSDateComponents *)componentsOfCurrentDate {

    return [NSDate componentsOfDate:[NSDate date]];
}

+ (NSDateComponents *)componentsOfDate:(NSDate *)date {

    return [[NSCalendar currentCalendar]
        components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday |
                   NSCalendarUnitWeekOfMonth | NSCalendarUnitHour | NSCalendarUnitMinute
          fromDate:date];
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [NSDate componentsWithYear:year month:month day:day];

    return [calendar dateFromComponents:components];
}


+ (NSDate *)dateWithHour:(NSInteger)hour min:(NSInteger)min {

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [NSDate componentsWithHour:hour min:min];

    return [calendar dateFromComponents:components];
}

+ (NSString *)stringTimeOfDate:(NSDate *)date {

    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setDateFormat:@"HH:mm"];

    return [dateFormater stringFromDate:date];
}

+ (NSDateComponents *)componentsWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];

    return components;
}

+ (NSDateComponents *)componentsWithHour:(NSInteger)hour min:(NSInteger)min {

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:hour];
    [components setMinute:min];

    return components;
}

+ (BOOL)isTheSameDateTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB {

    return ([compA day] == [compB day] && [compA month] == [compB month] && [compA year] == [compB year]);
}

+ (BOOL)isTheSameTimeTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB {

    return ([compA hour] == [compB hour] && [compA minute] == [compB minute]);
}


@end
