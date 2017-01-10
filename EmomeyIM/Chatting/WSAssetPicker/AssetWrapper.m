//
//  AssetWrapper.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 14-3-7.
//  Copyright (c) 2014年 Real Cloud. All rights reserved.
//

#import "AssetWrapper.h"
#import "UIImage+Extras.h"
#import <ImageIO/ImageIO.h>

@interface AssetWrapper ()
{
    
}

@end

@implementation AssetWrapper

@synthesize asset;

- (void)dealloc
{
    self.asset = nil;
}

- (UIImage *)image
{
    return [[UIImage alloc] initWithContentsOfFile:_originImagePath];
}

- (UIImage *)thumbnail
{
    return [[UIImage alloc] initWithContentsOfFile:_thumbnailPath];
}

@end
