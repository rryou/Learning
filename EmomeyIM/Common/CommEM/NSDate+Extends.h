//
//  HandleDataModel.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(Extends)
+ (NSDate *)dateFromString:(NSString *)dateString formatter:(NSString*)theFormatter;

- (NSDateComponents *)dateComponents;

- (NSUInteger)getDay;

- (NSUInteger)getMonth;

- (NSUInteger)getYear;

- (int )getHour;

- (int)getMinute;

- (NSString*) prettyDate;

- (NSString*) prettyDateWithReference:(NSDate*)reference;
- (NSString *)prettyDateWithReference:(NSDate *)reference format:(NSString *)format;

- (NSString*) parseDateWithFormat:(NSString*)theFormat;
+ (NSString*) parseDateWithFormat:(NSString*)theFormat theDate:(NSDate*)theDate;
- (NSString *)prettyDateWithReferenceMMDD:(NSDate *)reference;
- (NSString *)prettyDateWithReferenceHHmm:(NSDate *)reference;
+ (NSString*) parseDateWithFormat:(NSString*)theFormat withTimeStr:(NSString *)timeStr;

- (BOOL)isToday;
- (BOOL)isYestoday;

@end

NSDateFormatter *dateFormatterWithFormat(NSString *format);
