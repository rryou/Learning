//
//  NSString+LoochaAdapt.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 12/15/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (LoochaAdapt)

- (CGSize)loocha_sizeWithFont:(UIFont *)font;
- (CGSize)loocha_sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)loocha_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)loocha_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
