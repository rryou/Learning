//
//  TTLoochaDrawContext.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 9/24/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import "TTLoochaDrawContext.h"

@implementation TTLoochaDrawContext

+ (TTLoochaDrawContext *)sharedInstance
{
    static TTLoochaDrawContext *instance = nil;
    if (instance == nil) {
        instance = [[TTLoochaDrawContext alloc] init];
    }
    return instance;
}

- (void)reset
{
    self.foregroundColor = nil;
    self.backgroundColor = nil;
    self.paragraphStyle = nil;
}

@end

TTLoochaDrawContext *TTLoochaGetDrawContext()
{
    return [TTLoochaDrawContext sharedInstance];
}
