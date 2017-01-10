//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "ChattingCellContext.h"
#import "ChattingContent.h"

@interface ChattingTipLabel : UILabel <ReusableViewProtocol>

@property (nonatomic, strong) NSString *reuseIdentifier;

// maxWidth : 视图的最大宽度
+ (CGSize)viewSizeWithText:(NSString *)text maxWidth:(CGFloat)maxWidth;

@end
