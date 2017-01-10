//
//  MSPageImageView.h
//  UI
//
//  Created by Samuel on 15/4/9.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPageUpdating.h"

@interface MSPageImageView : UIImageView <MSPageUpdating> {
}

- (instancetype)initWithFrame:(CGRect)frame;
- (void)updatePageView:(id <MSPageModel>)pageModel;

@end