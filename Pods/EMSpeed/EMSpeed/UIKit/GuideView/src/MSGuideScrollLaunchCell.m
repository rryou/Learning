//
//  EMLaunchGuidView.m
//  EMStock
//
//  Created by flora on 14/11/14.
//  Copyright (c) 2014年 flora. All rights reserved.
//

#import "MSGuideScrollLaunchCell.h"

@implementation MSGuideScrollLaunchItem
@synthesize contentMode;
@synthesize cellClass;

- (id)init
{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeCenter;
        self.cellClass = [MSGuideScrollLaunchCell class];
    }
    return self;
}

@end

@implementation MSGuideScrollLaunchCell

- (void)updateGuideViewWithModel:(id<MSGuideScrollModel>)model
{
    if ([model isKindOfClass:[MSGuideScrollLaunchItem class]]) {
        MSGuideScrollLaunchItem *item = model;
        self.backgroundColor = item.backgroundColor;
        self.contentMode = item.contentMode;
        self.image = item.image;
    }
}

@end
