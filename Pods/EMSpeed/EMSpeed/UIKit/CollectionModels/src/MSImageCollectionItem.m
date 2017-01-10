//
//  MSImageCollectionItem.m
//  Coll
//
//  Created by Samuel on 15/4/16.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSImageCollectionItem.h"
#import "MSImageCollectionViewCell.h"

@implementation MSImageCollectionItem

@synthesize layoutSize;
@synthesize Class;
@synthesize reuseIdentify;
@synthesize isRegisterByClass;

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.Class = [MSImageCollectionViewCell class];
        self.reuseIdentify = @"MSImageCollectionViewCell";
        self.isRegisterByClass = NO;
    }
    
    return self;
}

@end
