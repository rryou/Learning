//
//  TTUnderlineStyle.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 1/18/16.
//  Copyright © 2016 Real Cloud. All rights reserved.
//

#import "TTStyle.h"

@interface TTUnderlineStyle : TTStyle

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat width;

+ (instancetype)styleWithColor:(UIColor *)color width:(CGFloat)width next:(TTStyle*)next;

@end
