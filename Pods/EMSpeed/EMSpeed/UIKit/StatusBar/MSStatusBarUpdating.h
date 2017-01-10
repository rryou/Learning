//
//  MSStatusBarUpdating.h
//  UI
//
//  Created by Samuel on 15/4/9.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSStatusBarModel.h"

@protocol MSStatusBarUpdating <NSObject>

@required
- (void)updateStatusBar:(id<MSStatusBarModel>)model;


@end

