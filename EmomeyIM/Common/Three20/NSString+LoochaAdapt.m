//
//  NSString+LoochaAdapt.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 12/15/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import "NSString+LoochaAdapt.h"

@implementation NSString (LoochaAdapt)

static NSMutableParagraphStyle *cachedParagraphStyle() {
    static NSMutableParagraphStyle *paragraphStyle;
    if (paragraphStyle == nil) {
        paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    }
    return paragraphStyle;
}

- (CGSize)loocha_sizeWithFont:(UIFont *)font {
    static UIFont *lastFont;
    static NSDictionary *lastAttributes;
    
    if (lastFont == nil || lastFont != font) {
        lastFont = font;
        lastAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          font, NSFontAttributeName, nil];
    }
    return [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                              options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                           attributes:lastAttributes
                              context:NULL].size;
}

- (CGSize)loocha_sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode {
    static NSMutableDictionary *attributes;
    
    NSMutableParagraphStyle *paragraphStyle = cachedParagraphStyle();
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    if (attributes == nil) {
        attributes = [[NSMutableDictionary alloc] initWithCapacity:2];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    }
    if (font) {
        [attributes setObject:font forKey:NSFontAttributeName];
    }
    else {
        [attributes removeObjectForKey:NSFontAttributeName];
    }
    return [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                              options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                           attributes:attributes
                              context:NULL].size;
}

- (CGSize)loocha_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    static UIFont *lastFont;
    static NSDictionary *lastAttributes;
    
    if (lastFont == nil || lastFont != font) {
        lastFont = font;
        lastAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          font, NSFontAttributeName, nil];
    }
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                           attributes:lastAttributes
                              context:NULL].size;
}

- (CGSize)loocha_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    static NSMutableDictionary *attributes;
    
    NSMutableParagraphStyle *paragraphStyle = cachedParagraphStyle();
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    if (attributes == nil) {
        attributes = [[NSMutableDictionary alloc] initWithCapacity:2];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    }
    if (font) {
        [attributes setObject:font forKey:NSFontAttributeName];
    }
    else {
        [attributes removeObjectForKey:NSFontAttributeName];
    }
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                           attributes:attributes
                              context:NULL].size;
}

@end
