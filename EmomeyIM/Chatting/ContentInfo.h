//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

 // 1: File, 2: Pic

#import "CMassGroup.h"
typedef NS_ENUM(NSInteger, ContentType) {
    NSContentType_File =1,
    NSContentType_Pic  =2
};
#import <Foundation/Foundation.h>
@interface ContentInfo : NSObject
@property (nonatomic, strong) NSString *filepath;
@property (nonatomic, strong) NSString *thumpPath;
@property (nonatomic, strong) NSString *fileExtra;
@property (nonatomic, assign) ContentType fileType;
@property (nonatomic, assign) NSInteger fileId;
@property (nonatomic, strong) NSData *hashdata;//16位
@end
