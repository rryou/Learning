//
//  HandleDataModel.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.
#import "NSDate+Extends.h"
//#import "NSDateAdditions.h"

@implementation NSDate(Extends)

- (NSDateComponents *)dateComponents
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond | kCFCalendarUnitWeekday;
    return [calendar components:unitFlags fromDate:self];
}

//获取日
- (NSUInteger)getDay{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit) fromDate:self];
	return [dayComponents day];
}
//获取月
- (NSUInteger)getMonth
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dayComponents = [calendar components:(NSMonthCalendarUnit) fromDate:self];
	return [dayComponents month];
}
//获取年
- (NSUInteger)getYear
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dayComponents = [calendar components:(NSYearCalendarUnit) fromDate:self];
	return [dayComponents year];
}

//获取小时
- (int )getHour {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger unitFlags =NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
	NSDateComponents *components = [calendar components:unitFlags fromDate:self];
	NSInteger hour = [components hour];
	return (int)hour;
}
//获取分钟
- (int)getMinute {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger unitFlags =NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit;
	NSDateComponents *components = [calendar components:unitFlags fromDate:self];
	NSInteger minute = [components minute];
	return (int)minute;
}

#pragma mark - 时间格式展示
- (NSString *)publishDateWithReference:(NSDate *)reference {
    float diff = [reference timeIntervalSinceDate:self];
    float day_diff = floor(diff / 86400);
    NSString * timerdayString = [[self description] substringToIndex:10];
    NSString * todayDateString = [[reference description] substringToIndex:10];
    if([timerdayString isEqualToString:todayDateString]) {
        return [self parseDateWithFormat:@"hh:mm"];
    }
    NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    if ([yesterdayString isEqualToString:timerdayString] ) {
        return [self parseDateWithFormat:@"昨天 hh:mm"];
    }
//    if (day_diff <= 0) {
//        return [self parseDateWithFormat:@"hh:mm"];
//    }else if(day_diff == 1){
//        return [self parseDateWithFormat:@"昨天 hh:mm"];
//    }
    else if (day_diff < 6) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:self];
        NSInteger weekday = [comps weekday]; // 星期几（注意，周日是“1”，周一是“2”。。。。）
        if (weekday == 0) {
            weekday = 6;
        }else if(weekday ==1){
            weekday = 7;
        }else{
            weekday = weekday -1;
        }
        return [NSString stringWithFormat:@"星期%@ %@", [self getWeekDay:weekday],[self parseDateWithFormat:@"hh:mm"]];
    }else{
        return [self parseDateWithFormat:@"yyyy-MM-dd hh:mm"];
        
    }
    
    // 在当年的不显示年份
//    if([reference getYear] == [self getYear]){
//        return [self parseDateWithFormat:@"yyyy-MM-dd"];
//    }
//    else{
//        return [self parseDateWithFormat:@"yyyy-MM-dd"];
//    }
}

- (NSString *)getWeekDay:(NSInteger) day{
    NSString *weekday;
    switch (day) {
        case 1:
            weekday = @"一";
            break;
        case 2:
            weekday = @"二";
            break;
        case 3:
            weekday = @"三";
            break;
        case 4:
            weekday = @"四";
            break;
        case 5:
            weekday = @"五";
            break;
        case 6:
            weekday = @"六";
            break;
        case 7:
            weekday = @"日";
            break;
            
        default:
            break;
    }
    return weekday;
}


- (NSDate *)getNewYearFirstDay
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setMonth:1];
    [components setDay:1];
    [components setYear:[self getYear]];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:components];
    return date;
}


- (NSUInteger)getTotalDaysOfCurrentYearUntilNow
{
    NSDate *oldDate = [self getNewYearFirstDay];
    float diff = [oldDate timeIntervalSinceDate:self];
    NSInteger day_diff = labs((NSInteger)floor(diff / 86400));
	return (int)day_diff;
}

- (NSUInteger)getDaysOfYear
{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calender components:(NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit | NSWeekCalendarUnit)
                                          fromDate:[NSDate date]];
    NSUInteger count = 0;
    for (int i=1; i <= 12; i++) {
        [comps setMonth:i];
        NSRange range = [calender rangeOfUnit:NSDayCalendarUnit
                                       inUnit: NSMonthCalendarUnit
                                      forDate: [calender dateFromComponents:comps]];
        count += range.length;
    }
    
    NSLog(@"%ld", (long)count);
    return count;
}

- (NSString *)prettyDateWithReference:(NSDate *)reference{
    return [self publishDateWithReference:reference];
//    float diff = [reference timeIntervalSinceDate:self];
//    float day_diff = floor(diff / 86400);
//    if (day_diff <= 0) {
//        if (diff < 60) return NSLocalizedString(@"just now", @"");
//        if (diff < 120) return [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"minute ago", @"")];
//        if (diff < 3600) return [NSString stringWithFormat:@"%d %@", (int)floor( diff / 60 ), NSLocalizedString(@"minute ago", @"")];
//        if (diff < 7200) return [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"hours ago", @"")];
//        if (diff < 86400) return [NSString stringWithFormat:@"%d %@", (int)floor( diff / 3600 ), NSLocalizedString(@"hours ago", @"")];
//    } /*
//       else if (day_diff == 1) {
//       return [NSString stringWithFormat:@"%d%@", (int)day_diff, NSLocalizedString(@"days ago", @"")];
//       } else if (day_diff < 7) {
//       return [NSString stringWithFormat:@"%d%@", (int)day_diff, NSLocalizedString(@"days ago", @"")];
//       } 
//       else if (day_diff < 31) {
//       return [NSString stringWithFormat:@"%d%@", (int)ceil( day_diff / 7 ), NSLocalizedString(@"weeks ago", @"")];
//       } else if (day_diff < 365) {
//       return [NSString stringWithFormat:@"%d%@", (int)ceil( day_diff / 30 ), NSLocalizedString(@"months ago", @"")];
//       } else {
//       return [NSString stringWithFormat:@"%d%@", (int)ceil( day_diff / 365 ), NSLocalizedString(@"years ago", @"")];
//       }*/
//    
//    return [self parseDateWithFormat:@"MM-dd HH:mm"];
}

- (NSString *)prettyDateWithReference:(NSDate *)reference format:(NSString *)format {
    float diff = [reference timeIntervalSinceDate:self];
    float day_diff = floor(diff / 86400);
    if (day_diff <= 0) {
        if (diff < 60) return NSLocalizedString(@"just now", @"");
        if (diff < 120) return [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"minute ago", @"")];
        if (diff < 3600) return [NSString stringWithFormat:@"%d %@", (int)floor( diff / 60 ), NSLocalizedString(@"minute ago", @"")];
        if (diff < 7200) return [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"hours ago", @"")];
        if (diff < 86400) return [NSString stringWithFormat:@"%d %@", (int)floor( diff / 3600 ), NSLocalizedString(@"hours ago", @"")];
    } /*
       else if (day_diff == 1) {
       return [NSString stringWithFormat:@"%d%@", (int)day_diff, NSLocalizedString(@"days ago", @"")];
       } else if (day_diff < 7) {
       return [NSString stringWithFormat:@"%d%@", (int)day_diff, NSLocalizedString(@"days ago", @"")];
       }
       else if (day_diff < 31) {
       return [NSString stringWithFormat:@"%d%@", (int)ceil( day_diff / 7 ), NSLocalizedString(@"weeks ago", @"")];
       } else if (day_diff < 365) {
       return [NSString stringWithFormat:@"%d%@", (int)ceil( day_diff / 30 ), NSLocalizedString(@"months ago", @"")];
       } else {
       return [NSString stringWithFormat:@"%d%@", (int)ceil( day_diff / 365 ), NSLocalizedString(@"years ago", @"")];
       }*/
    
    return [self parseDateWithFormat:format];
}

- (NSString *)prettyDateWithReferenceMMDD:(NSDate *)reference {
    float diff = [reference timeIntervalSinceDate:self];
    float day_diff = floor(diff / 86400);
    if (day_diff <= 0) {
        if (diff < 60) return NSLocalizedString(@"just now", @"");
        if (diff < 120) return [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"minute ago", @"")];
        if (diff < 3600) return [NSString stringWithFormat:@"%d %@", (int)floor( diff / 60 ), NSLocalizedString(@"minute ago", @"")];
        if (diff < 7200) return [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"hours ago", @"")];
        if (diff < 86400) return [NSString stringWithFormat:@"%d %@", (int)floor( diff / 3600 ), NSLocalizedString(@"hours ago", @"")];
    }
    return [self parseDateWithFormat:@"MM-dd"];
}

- (NSString *)prettyDateWithReferenceHHmm:(NSDate *)reference {
    float diff = [reference timeIntervalSinceDate:self];
    float day_diff = floor(diff / 86400);
    if (day_diff <= 0) {
        if (diff < 60) return NSLocalizedString(@"just now", @"");
        if (diff < 120) return [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"minute ago", @"")];
        if (diff < 3600) return [NSString stringWithFormat:@"%d %@", (int)floor( diff / 60 ), NSLocalizedString(@"minute ago", @"")];
        if (diff < 7200) return [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"hours ago", @"")];
        if (diff < 86400) return [NSString stringWithFormat:@"%d %@", (int)floor( diff / 3600 ), NSLocalizedString(@"hours ago", @"")];
    }
    return [self parseDateWithFormat:@"HH:mm"];
}

NSDateFormatter *dateFormatterWithFormat(NSString *format)
{
    static NSMutableDictionary *formatterDict = nil;
    if (formatterDict == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatterDict = [[NSMutableDictionary alloc] init];
        });
    }
    @synchronized(formatterDict) {
        NSDateFormatter *formatter = [formatterDict objectForKey:format];
        if (formatter == nil) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = format;
            [formatterDict setObject:formatter forKey:format];
        }
        return formatter;
    }
}

- (NSString *)prettyDate {
    return [self prettyDateWithReference:[NSDate date]];
}

- (NSString*) parseDateWithFormat:(NSString*)theFormat {
    NSDateFormatter *dateFormatter = dateFormatterWithFormat(theFormat);
//    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//    dateFormatter.dateFormat = theFormat;
    
    // 大写H日期格式将默认为24小时制，小写的h日期格式将默认为12小时制
    
	return [dateFormatter stringFromDate:self];
}

+ (NSString*) parseDateWithFormat:(NSString*)theFormat withTimeStr:(NSString *)timeStr
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStr floatValue]/1000];
    return [NSDate parseDateWithFormat:theFormat theDate:date];
}

+ (NSString*) parseDateWithFormat:(NSString*)theFormat theDate:(NSDate*)theDate
{
    NSDateFormatter *dateFormatter = dateFormatterWithFormat(theFormat);
	
//    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//    dateFormatter.dateFormat = theFormat;
	return [dateFormatter stringFromDate:theDate];
}

+ (NSDate *)dateFromString:(NSString *)dateString formatter:(NSString*)theFormatter
{
    
    NSDateFormatter *dateFormatter = dateFormatterWithFormat(@"yyyy-MM-dd");
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
//    [dateFormatter autorelease];
    
    return destDate;
    
}

- (BOOL)isToday
{
    NSDate *today = [NSDate date];
    NSTimeInterval delt = [self timeIntervalSinceDate:today];
    return delt >= 0 && delt < 24*60*60;
}

- (BOOL)isYestoday
{
    NSDate *today = [NSDate date];
    NSTimeInterval delt = [self timeIntervalSinceDate:today] - 24*60*60;
    return delt >= 0 && delt < 24*60*60;
}
@end
