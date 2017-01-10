//
//  LoochaUtil.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 7/17/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LoochaUtil : NSObject

+ (long long)longLongValueOf:(NSObject *)obj;

+ (CGSize)labelSizeThatFit:(CGSize)size text:(NSString *)text font:(UIFont *)font numberOfLines:(NSUInteger)numberOfLines;
+ (CGSize)labelSizeThatFit:(CGSize)size font:(UIFont *)font numberOfLines:(NSUInteger)numberOfLines;
+ (CGFloat)labelHeightThatFitFont:(UIFont *)font;

+ (CGSize)labelSizeThatFit:(CGSize)size attributedText:(NSAttributedString *)attributedText font:(UIFont *)font numberOfLines:(NSUInteger)numberOfLines;

+ (int)ageForBirthday:(NSString *)birthday;

+ (CGRect)frameBestFitInRect:(CGRect)r originWidth:(CGFloat)originWidth originHeight:(CGFloat)originHeight;
+ (CGRect)frameBestFillInRect:(CGRect)r originWidth:(CGFloat)originWidth originHeight:(CGFloat)originHeight;

+ (NSString *)urlStringWithServer:(NSString *)server relativePath:(NSString *)relativePath;
+ (NSString *)urlStringWithServer:(NSString *)server formattedRelativePath:(NSString *)fRelativePath, ...;

@end
