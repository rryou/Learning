//
//  TTUnderlineStyle.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 1/18/16.
//  Copyright © 2016 Real Cloud. All rights reserved.
//

#import "TTUnderlineStyle.h"
#import "TTStyleContext.h"

@implementation TTUnderlineStyle

+ (instancetype)styleWithColor:(UIColor *)color width:(CGFloat)width next:(TTStyle*)next {
    TTUnderlineStyle *style = [[TTUnderlineStyle alloc] init];
    style.color = color;
    style.width = width;
    style.next = next;
    return style;
}

- (void)draw:(TTStyleContext*)context {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = context.frame;
    
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, _width);
    [self.color setStroke];
    
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    return [self.next draw:context];
}

@end
