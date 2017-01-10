//
//  AssetWrapper.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 14-3-7.
//  Copyright (c) 2014年 Real Cloud. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define LittleImageMax    800

@interface AssetWrapper : NSObject

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) NSString *originImagePath;  //原图路径
@property (nonatomic, strong) NSString *thumbnailPath;
@property (nonatomic, assign) BOOL isNeedBigImage;
@property (nonatomic, assign) NSUInteger fileSize;

- (UIImage *)thumbnail;
- (UIImage *)image;

@end
