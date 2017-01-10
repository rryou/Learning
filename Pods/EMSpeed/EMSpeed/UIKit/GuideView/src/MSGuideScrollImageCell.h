//
//  EMGuideImageView.h
//  UIDemo
//
//  Created by Samuel on 15/4/27.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSGuideScrollModel.h"
#import "MSGuideScrollUpdating.h"

@interface MSGuideScrollImageItem : NSObject <MSGuideScrollModel>

@property (nonatomic, strong) UIImage *image;
@end


@interface MSGuideScrollImageCell : UIImageView <MSGuideScrollUpdating>

@end
