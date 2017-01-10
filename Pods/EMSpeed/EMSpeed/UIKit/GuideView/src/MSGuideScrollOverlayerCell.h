//
//  EMOverlayerFunctionGuidCell.h
//  EMStock
//
//  Created by xoHome on 14-10-22.
//  Copyright (c) 2014年 flora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSGuideScrollModel.h"
#import "MSGuideScrollUpdating.h"


@interface MSGuideScrollOverlayerItem : NSObject<MSGuideScrollModel>

@property (nonatomic, strong) UIImage *image;

@end


@interface MSGuideScrollOverlayerCell : UIImageView<MSGuideScrollUpdating>
{
    
}
@end
