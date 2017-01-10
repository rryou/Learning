//
//  EMLaunchGuidView.h
//  EMStock
//
//  Created by flora on 14/11/14.
//  Copyright (c) 2014年 flora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSGuideScrollModel.h"
#import "MSGuideScrollUpdating.h"

@interface MSGuideScrollLaunchItem : NSObject<MSGuideScrollModel>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *backgroundColor;

@end


@interface MSGuideScrollLaunchCell : UIImageView<MSGuideScrollUpdating>
{
    
}
@end
