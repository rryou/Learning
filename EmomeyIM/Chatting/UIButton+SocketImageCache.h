//
//  UIButton+SocketImageCache.h
//  EmomeyIM
//
//  Created by yourongrong on 2016/10/26.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SocketDownImageBlock)(UIImage *image, NSString *filedid);
@interface UIButton (SocketImageCache)

- (void)sk_setimageWith:(NSString *)fileId forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;

- (void)sk_setimageWith:(NSString *)fileId forState:(UIControlState)state completed:(SocketDownImageBlock)completedBlock;

@end
