//
//  MSPageUpdating.h
//  UI
//
//  Created by Samuel on 15/4/8.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSPageModel.h"

@protocol MSPageUpdating

@required
- (void)updatePageView:(id<MSPageModel>)pageModel;

@end
