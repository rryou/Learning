//
//  HandleDataModel.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.

#import <UIKit/UIKit.h>

UIColor *UIColorFromRGB(long rgbValue);
UIColor *UIColorFromARGB(long argbValue);

@interface UIColor (Oxygen)
//16进制颜色转UIColor
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
@end
