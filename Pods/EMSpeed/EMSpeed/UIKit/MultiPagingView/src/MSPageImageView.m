//
//  MSPageImageView.m
//  UI
//
//  Created by Samuel on 15/4/9.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSPageImageView.h"
#import "UIImageView+DownloadIcon.h"
#import "MSPageItem.h"

@implementation MSPageImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    
    return self;
}


- (void)updatePageView:(id <MSPageModel>)pageModel
{
    if ([pageModel isKindOfClass:[MSPageItem class]]) {
        MSPageItem *page = (MSPageItem *)pageModel;
        [self ms_setImageWithURL:[NSURL URLWithString:page.img] localCache:YES];
    }
}

@end