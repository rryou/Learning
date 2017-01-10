//
//  MSTextStatusBar.m
//  YCStock
//
//  Created by meiosis chen on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MSStatusBarWindow.h"

const CGFloat kStatusBarAnimationDuration = .3f;
const CGFloat kStatusBarAnimationDelay = .5f;


@interface MSStatusBarWindow()

@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, retain) UIView<MSStatusBarUpdating> *statusBar0;
@property (nonatomic, retain) UIView<MSStatusBarUpdating> *statusBar1;
@end


@implementation MSStatusBarWindow

@synthesize array = _array;
@synthesize isAnimating = _isAnimating;
@synthesize statusBar0 = _statusBar0;
@synthesize statusBar1 = _statusBar1;


+ (MSStatusBarWindow *)sharedManager
{
    static MSStatusBarWindow *__sharedStatusBarWindow;
    @synchronized(self) {
        if (__sharedStatusBarWindow == nil) {
            __sharedStatusBarWindow = [[MSStatusBarWindow alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
        }
    }
    
    return __sharedStatusBarWindow;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.clipsToBounds = YES;
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        self.array = [NSMutableArray array];
        self.isAutoHidden = YES;
        _isSwaped = NO;
    }
    return self;
}

+ (void)showStatusBarWithModel:(id<MSStatusBarModel>)data
{
    [self hiddenStatusBarAnimated:NO];
    [[MSStatusBarWindow sharedManager].array addObject:data];
    [[MSStatusBarWindow sharedManager] showStartStatusBar];
}

+ (void)showStatusBarWithData:(id<MSStatusBarModel>)data
                  autoDismiss:(BOOL)autoDismiss
{
    [self hiddenStatusBarAnimated:NO];
    [[MSStatusBarWindow sharedManager].array addObject:data];
    [[MSStatusBarWindow sharedManager] showStartStatusBar];
}

+ (void)showStatusBarWithArray:(NSArray *)array
{
    [self hiddenStatusBarAnimated:NO];
    [[MSStatusBarWindow sharedManager].array addObjectsFromArray:array];
    [[MSStatusBarWindow sharedManager] showStartStatusBar];
}

+ (void)hiddenStatusBarAnimated:(BOOL)animated
{
    [[MSStatusBarWindow sharedManager] hiddenStatusBarAnimated:animated];
}

- (void)hiddenStatusBarAnimated:(BOOL)animated {
    if (animated) {
        self.alpha = 1.f;
        [UIView animateWithDuration:kStatusBarAnimationDuration animations:^{
            self.alpha = 0.f;
        } completion:^(BOOL finished) {
            if (finished) {
                self.hidden = YES;
                [self.array removeAllObjects];
                for (UIView *view in self.subviews) {
                    [view removeFromSuperview];
                }
                self.statusBar0 = nil;
                self.statusBar1 = nil;
                self.isAnimating = NO;
            }
        }];
    }
    else{
        self.hidden = YES;
        [self.array removeAllObjects];
        for (UIView *view in [MSStatusBarWindow sharedManager].subviews) {
            [view removeFromSuperview];
        }
        self.statusBar0 = nil;
        self.statusBar1 = nil;
        self.isAnimating = NO;
    }
}

- (UIView<MSStatusBarUpdating> *)currentStatusBar
{
    return _isSwaped ? _statusBar1 : _statusBar0;
}

- (UIView<MSStatusBarUpdating> *)nextStatusBar
{
    return _isSwaped ? _statusBar0 : _statusBar1;
}

- (BOOL)hasNext
{
    if ([[MSStatusBarWindow sharedManager].array count] > 0) {
        return YES;
    }
    
    return NO;
}

- (void)showStartStatusBar
{
    if (![self hasNext] || _isAnimating) {
        return;
    }
    
    [MSStatusBarWindow sharedManager].hidden = NO;
    [MSStatusBarWindow sharedManager].alpha = 1.f;
    
    if ([[MSStatusBarWindow sharedManager].array count] > 0) {
        id<MSStatusBarModel> data = [[MSStatusBarWindow sharedManager].array objectAtIndex:0];
        UIView<MSStatusBarUpdating> *view = [data statusBarWithData:data];
        if (_isSwaped) {
            _statusBar1 = view;
        }
        else {
            _statusBar0 = view;
        }
        [view updateStatusBar:data];
        [self addSubview:view];
    }
    
    if ([[MSStatusBarWindow sharedManager].array count] > 1) {
        id<MSStatusBarModel> data = [[MSStatusBarWindow sharedManager].array objectAtIndex:1];
        UIView<MSStatusBarUpdating> *view = [data statusBarWithData:data];
        if (_isSwaped) {
            _statusBar0 = view;
        }
        else {
            _statusBar1 = view;
        }
        [view updateStatusBar:data];
        [self addSubview:view];
    }
    
    if ([[MSStatusBarWindow sharedManager].array count] == 1) {
        [self playSingleAnimation];
    }
    else {
        [self playMultiStartAnimation];
    }
}

- (void)showNextStatusBar
{
    if (![self hasNext] || _isAnimating) {
        return;
    }
    
    [MSStatusBarWindow sharedManager].hidden = NO;
    [MSStatusBarWindow sharedManager].alpha = 1.f;
    
    if ([[MSStatusBarWindow sharedManager].array count] > 1) {
        id<MSStatusBarModel> data = [[MSStatusBarWindow sharedManager].array objectAtIndex:1];
        UIView<MSStatusBarUpdating> *view = [data statusBarWithData:data];
        if (_statusBar0 == nil) {
            _statusBar0 = view;
        }
        else if (_statusBar1 == nil){
            _statusBar1 = view;
        }
        [view updateStatusBar:data];
        [self addSubview:view];
    }
    
    if ([[MSStatusBarWindow sharedManager].array count] == 1) {
        [self playMultiEndAnimation];
    }
    else {
        [self playMultiNextAnimation];
    }
}

- (void)playSingleAnimation
{
    if (_isAnimating) {
        return;
    }
    
    _isAnimating = YES;
    
    UIView *currentView = _statusBar0 ? _statusBar0 : _statusBar1;
    
    currentView.frame = [self currentStatusBarDesFrame];
    
    currentView.alpha = 0.f;
    [UIView animateWithDuration:kStatusBarAnimationDuration animations:^{
        currentView.alpha = 1.f;
        currentView.frame = [self currentStatusBarDesFrame];
        
    } completion:^(BOOL finished) {
        if (finished) {
            if (self.isAutoHidden) {
                currentView.alpha = 1.f;
                [UIView animateWithDuration:kStatusBarAnimationDuration
                                      delay:kStatusBarAnimationDelay
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                    currentView.alpha = 0.f;
                } completion:^(BOOL finished) {
                    if (finished) {
                        // 出列
                        [self.array removeAllObjects];
                        [currentView removeFromSuperview];
                        _statusBar0 = nil;
                        _statusBar1 = nil;
                        
                        _isAnimating = NO;
                    }
                }];
            }
        }
    }];
}


- (void)playMultiStartAnimation
{
    UIView *currentView = [self currentStatusBar];
    UIView *nextView = [self nextStatusBar];
    
    currentView.frame = [self currentStatusBarOriginFrame];
    nextView.frame = [self nextStatusBarOriginFrame];
    [UIView animateWithDuration:kStatusBarAnimationDuration
                     animations:^{
        currentView.frame = [self currentStatusBarDesFrame];
        nextView.frame = [self nextStatusBarDesFrame];
        
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:kStatusBarAnimationDuration
                                  delay:kStatusBarAnimationDelay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 currentView.frame = [self dismissStatusBarDesFrame];
                                 nextView.frame = [self currentStatusBarDesFrame];
                                 
                             } completion:^(BOOL finished) {
                                 if (finished) {
                                     // 出列
                                     if([self.array count] > 0) {
                                         [self.array removeObjectAtIndex:0];
                                     }
                                     
                                     if (_statusBar0.frame.origin.y == [self dismissStatusBarDesFrame].origin.y) {
                                         [_statusBar0 removeFromSuperview];
                                         _statusBar0 = nil;
                                     }
                                     else if (_statusBar1.frame.origin.y == [self dismissStatusBarDesFrame].origin.y) {
                                         [_statusBar1 removeFromSuperview];
                                         _statusBar1 = nil;
                                     }
                                     
                                     _isSwaped = !_isSwaped;
                                     _isAnimating = NO;
                                     
                                     if ([self hasNext]) {
                                         [self showNextStatusBar];
                                     }
                                 }
                             }];
        }
    }];
}

- (void)playMultiNextAnimation
{
    UIView *currentView = [self currentStatusBar];
    UIView *nextView = [self nextStatusBar];
        
    currentView.frame = [self currentStatusBarDesFrame];
    nextView.frame = [self currentStatusBarOriginFrame];
    [UIView animateWithDuration:kStatusBarAnimationDuration
                          delay:kStatusBarAnimationDelay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         currentView.frame = [self dismissStatusBarDesFrame];
                         nextView.frame = [self currentStatusBarDesFrame];
                         
                     } completion:^(BOOL finished) {
                         if (finished) {
                             // 出列
                             if([self.array count] > 0) {
                                 [self.array removeObjectAtIndex:0];
                             }
                             
                             if (_statusBar0.frame.origin.y == [self dismissStatusBarDesFrame].origin.y) {
                                 [_statusBar0 removeFromSuperview];
                                 _statusBar0 = nil;
                             }
                             else if (_statusBar1.frame.origin.y == [self dismissStatusBarDesFrame].origin.y) {
                                 [_statusBar1 removeFromSuperview];
                                 _statusBar1 = nil;
                             }
                             
                             _isSwaped = !_isSwaped;
                             _isAnimating = NO;
                             
                             if ([self hasNext]) {
                                 [self showNextStatusBar];
                             }
                         }
                     }];
}

- (void)playMultiEndAnimation
{
    UIView *currentView = _statusBar0 ? _statusBar0 : _statusBar1;
    
    currentView.frame = [self currentStatusBarDesFrame];
    
    [UIView animateWithDuration:kStatusBarAnimationDuration
                     animations:^{
        currentView.frame = [self currentStatusBarDesFrame];
        
    } completion:^(BOOL finished) {
        if (finished) {
            if (!self.isAutoHidden && [self.array count] == 1) {
                // 不是自动隐藏 且只有自己一个
                // 那就一直显示着
            }
            else{
                currentView.alpha = 1.f;
                [UIView animateWithDuration:kStatusBarAnimationDuration
                                      delay:kStatusBarAnimationDelay
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                    
                    currentView.alpha = 0.f;
                    
                } completion:^(BOOL finished) {
                    if (finished) {
                        // 出列
                        if([self.array count] > 0) {
                            [self.array removeObjectAtIndex:0];
                        }
                        
                        [currentView removeFromSuperview];
                        if (_statusBar0) {
                            _statusBar0 = nil;
                        }
                        if (_statusBar1) {
                            _statusBar1 = nil;
                        }
                        
                        _isAnimating = NO;
                        
                        // 虽然是播放最后的动画, 如果在动画期间又添加新的model, 则继续播放
                        if ([self hasNext]) {
                            [self showNextStatusBar];
                        }
                    }
                }];
            }
        }
    }];
}

# pragma mark - frames

- (CGRect)currentStatusBarOriginFrame
{
    return CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (CGRect)nextStatusBarOriginFrame
{
    return CGRectMake(0, self.frame.size.height * 2, self.frame.size.width, self.frame.size.height);
}

- (CGRect)currentStatusBarDesFrame
{
    return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (CGRect)nextStatusBarDesFrame
{
    return CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (CGRect)dismissStatusBarDesFrame
{
    return CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

@end
