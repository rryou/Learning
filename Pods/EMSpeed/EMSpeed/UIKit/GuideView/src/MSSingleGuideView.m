//
//  EMFunctionGuidView.m
//  EMStock
//
//  Created by xoHome on 14-10-21.
//  Copyright (c) 2014年 flora. All rights reserved.
//

#import "MSSingleGuideView.h"

@implementation MSSingleGuideView

- (id)initWithItems:(NSArray *)items
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.6f];
        for (EMSingleGuideItem *vpoint in items)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:vpoint.image];
            imageView.frame = CGRectMake(vpoint.point.x, vpoint.point.y, vpoint.image.size.width, vpoint.image.size.height);
            [self addSubview:imageView];
        }
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        recognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:recognizer];
    }
    return self;
}


+ (MSSingleGuideView *)showSingleGuideViewInWithItems:(NSArray *)items
                                               inView:(UIView *)view
{
    MSSingleGuideView *guidView = [[MSSingleGuideView alloc] initWithItems:items];
    guidView.frame = view.bounds;
    [view addSubview:guidView];

    return guidView;
}

- (void)dismissAnimated:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    if (animated)
    {
        if (self.completion)
        {
            self.completion();
        }
        [self removeFromSuperview];
    }
    else
    {
        [UIView animateWithDuration:.2f
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             if (self.completion)
                             {
                                 self.completion();
                             }
                         }];
    }
}

- (void)dismiss
{
    [self dismissAnimated:YES];
}


+ (MSSingleGuideView *)showSingleGuidViewWithitems:(NSArray *)array
                                            inView:(UIView *)view
                              dismissAutomatically:(BOOL)automatic
                                        completion:(void (^)(void))completion
{
    MSSingleGuideView *guidView = [MSSingleGuideView showSingleGuideViewInWithItems:array inView:view];
    guidView.completion = completion;
    if (automatic)
    {
        [guidView performSelector:@selector(dismiss) withObject:nil afterDelay:kGuidViewShowInterval];
    }
    
    return guidView;
}

@end


@implementation EMSingleGuideItem


@end

