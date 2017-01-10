//
//  EMOverlayerFunctionGuidCell.m
//  EMStock
//
//  Created by xoHome on 14-10-22.
//  Copyright (c) 2014年 flora. All rights reserved.
//

#import "MSGuideScrollOverlayerCell.h"

@implementation MSGuideScrollOverlayerItem
@synthesize cellClass;
@synthesize contentMode;

- (id)init
{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeCenter;
        self.cellClass = [MSGuideScrollOverlayerCell class];
    }
    return self;
}

@end

@implementation MSGuideScrollOverlayerCell



- (void)updateGuideViewWithModel:(id<MSGuideScrollModel>)model
{
    if ([model isKindOfClass:[MSGuideScrollOverlayerItem class]]) {
        MSGuideScrollOverlayerItem *item = model;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.6f];
        self.contentMode = item.contentMode;
        self.image = item.image;
    }
}

@end
