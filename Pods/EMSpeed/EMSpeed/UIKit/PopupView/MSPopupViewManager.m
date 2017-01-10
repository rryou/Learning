//
//  EMPopupViewManager.m
//  EMStock
//
//  Created by Samuel on 15/3/24.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import "MSPopupViewManager.h"
#import "MSPopupView.h"

@interface MSPopupViewManager()

@property (nonatomic, strong) NSMutableArray *popupViews;

@end


@implementation MSPopupViewManager

+ (MSPopupViewManager *)sharedManager
{
    static MSPopupViewManager *__popupViewManager = nil;
    @synchronized(self) {
        if (__popupViewManager == nil) {
            __popupViewManager = [[MSPopupViewManager alloc] init];
        }
    }
    
    return __popupViewManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.popupViews = [NSMutableArray array];
    }
    
    return self;
}

- (BOOL)enqueuePopupView:(MSPopupView *)popupView
{
    @synchronized(self) {
        if (![self.popupViews containsObject:popupView]) {
            [self.popupViews addObject:popupView];
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)dequeuePopupView:(MSPopupView *)popupView
{
    @synchronized(self) {
        if ([self.popupViews count] > 0) {
            if ([self.popupViews containsObject:popupView]) {
                [self.popupViews removeObject:popupView];
                return YES;
            }
        }
        return NO;
    }
}

- (BOOL)dequeuePopupView
{
    @synchronized(self) {
        if ([self.popupViews count] > 0) {
            [self.popupViews removeObjectAtIndex:0];
            return YES;
        }
        return NO;
    }
}


- (MSPopupView *)firstPopupView
{
    if ([self.popupViews count] > 0) {
        MSPopupView *popupView = [self.popupViews objectAtIndex:0];
        return popupView;
    }
    
    return nil;
}


- (BOOL)isEnqueueEmpty
{
    return [self.popupViews count] <= 0;
}


- (BOOL)isInQueue:(MSPopupView *)view
{
    return [self.popupViews containsObject:view];
}


- (void)dequeueAll
{
    [self.popupViews removeAllObjects];
}

@end
