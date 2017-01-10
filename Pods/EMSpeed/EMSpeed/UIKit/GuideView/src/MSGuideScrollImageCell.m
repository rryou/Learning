//
//  EMGuideImageView.m
//  UIDemo
//
//  Created by Samuel on 15/4/27.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSGuideScrollImageCell.h"


@implementation MSGuideScrollImageItem
@synthesize cellClass;
@synthesize contentMode;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellClass = [MSGuideScrollImageCell class];
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

@end

@implementation MSGuideScrollImageCell

- (void)updateGuideViewWithModel:(id<MSGuideScrollModel>)model
{
    if ([model isKindOfClass:[UIImage class]]) {
        self.image = (UIImage *)model;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    else if ([model isKindOfClass:[MSGuideScrollImageItem class]]) {
        MSGuideScrollImageItem *item = (MSGuideScrollImageItem *)model;
        self.image = item.image;
        self.contentMode = item.contentMode;
    }
}

@end
