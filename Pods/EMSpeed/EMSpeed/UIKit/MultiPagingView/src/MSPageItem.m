//
//  EMPageData.m
//  UI
//
//  Created by Samuel on 15/4/9.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSPageItem.h"
#import "MSPageImageView.h"

@implementation MSPageItem
@synthesize title;
@synthesize img;
@synthesize url;
@synthesize viewClass;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.title = [dictionary objectForKey:@"title"];
        self.img = [dictionary objectForKey:@"image"];
        self.url = [dictionary objectForKey:@"linkurl"];
        self.viewClass = [MSPageImageView class];
    }
    return self;
}


- (UIView *)viewWithData:(id<MSPageModel>)data
{
    UIView *view = [[self.viewClass alloc] initWithFrame:CGRectZero];
    return view;
}

@end
