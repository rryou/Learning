//
//  LoochaUtil.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 7/17/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import "LoochaUtil.h"

@implementation LoochaUtil

+ (long long)longLongValueOf:(NSObject *)obj
{
    if ([obj isKindOfClass:[NSString class]]) {
        return [(NSString *)obj longLongValue];
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)obj longLongValue];
    }
    return 0;
}

+ (CGSize)labelSizeThatFit:(CGSize)size text:(NSString *)text font:(UIFont *)font numberOfLines:(NSUInteger)numberOfLines
{
    static UILabel *label;
    if (label == nil) {
        label = [[UILabel alloc] init];
    }
    label.text = text;
    label.font = font;
    label.numberOfLines = numberOfLines;
    return [label sizeThatFits:size];
}

+ (CGSize)labelSizeThatFit:(CGSize)size attributedText:(NSAttributedString *)attributedText font:(UIFont *)font numberOfLines:(NSUInteger)numberOfLines
{
    static UILabel *label;
    if (label == nil) {
        label = [[UILabel alloc] init];
    }
    label.attributedText = attributedText;
    label.font = font;
    label.numberOfLines = numberOfLines;
    return [label sizeThatFits:size];
}

+ (CGSize)labelSizeThatFit:(CGSize)size font:(UIFont *)font numberOfLines:(NSUInteger)numberOfLines
{
    return [self labelSizeThatFit:size text:@"X" font:font numberOfLines:numberOfLines];
}

+ (CGFloat)labelHeightThatFitFont:(UIFont *)font
{
    return [self labelSizeThatFit:CGSizeMake(100, 100) font:font numberOfLines:1].height;
}

+ (CGRect)frameBestFitInRect:(CGRect)r originWidth:(CGFloat)originWidth originHeight:(CGFloat)originHeight {
    if (r.size.width == 0 || originWidth == 0) {
        return CGRectZero;
    }
    CGFloat k1 = r.size.height/r.size.width;
    CGFloat k2 = originHeight/originWidth;
    CGRect frame;
    if (k1 > k2) {
        frame.size.width = r.size.width;
        frame.size.height = k2 * r.size.width;
    }
    else {
        if (k2 == 0) {
            return CGRectZero;
        }
        frame.size.height = r.size.height;
        frame.size.width = r.size.height/k2;
    }
    frame.origin.x = r.origin.x + (r.size.width - frame.size.width)/2;
    frame.origin.y = r.origin.y + (r.size.height - frame.size.height)/2;
    return frame;
}

+ (CGRect)frameBestFillInRect:(CGRect)r originWidth:(CGFloat)originWidth originHeight:(CGFloat)originHeight {
    if (r.size.width == 0 || originWidth == 0) {
        return CGRectZero;
    }
    CGFloat k1 = r.size.height/r.size.width;
    CGFloat k2 = originHeight/originWidth;
    CGRect frame;
    if (k1 > k2) {
        if (k2 == 0) {
            return CGRectZero;
        }
        frame.size.height = r.size.height;
        frame.size.width = r.size.height/k2;
    }
    else {
        frame.size.width = r.size.width;
        frame.size.height = k2 * r.size.width;
    }
    frame.origin.x = r.origin.x + (r.size.width - frame.size.width)/2;
    frame.origin.y = r.origin.y + (r.size.height - frame.size.height)/2;
    return frame;
}

+ (NSString *)urlStringWithServer:(NSString *)server relativePath:(NSString *)relativePath {
    NSString *fullPath = nil;
    if ([server hasSuffix:@"/"]) {
        if ([relativePath hasPrefix:@"/"]) {
            fullPath = [server stringByReplacingCharactersInRange:NSMakeRange([server length]-1, 1) withString:relativePath];
        }
        else {
            fullPath = [server stringByAppendingString:relativePath];
        }
    }
    else {
        if ([relativePath hasPrefix:@"/"]) {
            fullPath = [server stringByAppendingString:relativePath];
        }
        else {
            fullPath = [server stringByAppendingFormat:@"/%@", relativePath];
        }
    }
    return fullPath;
}

+ (NSString *)urlStringWithServer:(NSString *)server formattedRelativePath:(NSString *)fRelativePath, ... {
    va_list args;
    va_start(args, fRelativePath);
    NSString *relativePath = [[NSString alloc] initWithFormat:fRelativePath arguments:args];
    va_end(args);
    return [server stringByAppendingPathComponent:relativePath];
}

@end
