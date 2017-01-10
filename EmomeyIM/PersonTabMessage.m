//
//  PersonTabMessage.m
//  EmomeyIM
//
//  Created by yourongrong on 16/10/10.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "PersonTabMessage.h"

@implementation PersonTabMessage
- (id)init{
    self = [super init];
    if (self) {
        self.pagelistarray = [NSMutableArray array];
    }
    return self;
}
@end

@implementation LabelMessage
- (id)init{
    self = [super init];
    if (self) {
        self.itemarry = [NSMutableArray array];
    }
    return self;
}
@end
