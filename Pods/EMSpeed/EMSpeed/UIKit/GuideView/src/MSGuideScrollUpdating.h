//
//  EMGuideScrollCell.h
//  UIDemo
//
//  Created by Samuel on 15/4/27.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSGuideScrollModel.h"

@protocol MSGuideScrollUpdating <NSObject>
@required

- (void)updateGuideViewWithModel:(id<MSGuideScrollModel>)model;

@end
