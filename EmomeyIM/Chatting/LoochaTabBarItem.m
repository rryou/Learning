//
//  LoochaTabBarItem.m
//  TabBarTest
//
//  Created by RealCloud on 14-8-14.
//  Copyright (c) 2014年 RealCloud. All rights reserved.
//

#import "LoochaTabBarItem.h"

@implementation LoochaTabBarItem

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image{
    return [self initWithTitle:title image:image selectedImage:nil];
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage{
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        _selectedImage = selectedImage;
        _contentOffset = UIOffsetZero;
        _enabled = YES;
        _width = .0;
    }
    
    return self;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state{
    
}

- (UIImage *)backgroundImageForState:(UIControlState)state{
    return nil;
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state{
    
}

- (NSDictionary *)titleTextAttributesForState:(UIControlState)state{
    return nil;
}

@end
