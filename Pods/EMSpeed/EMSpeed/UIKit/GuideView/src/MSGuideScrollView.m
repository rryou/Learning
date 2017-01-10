//
//  EMFunctionGuidView.m
//  EMStock
//
//  Created by xoHome on 14-10-20.
//  Copyright (c) 2014年 flora. All rights reserved.
//

#import "MSGuideScrollView.h"
#import "UIView+Genie.h"
#import "MSGuideScrollImageCell.h"

const CGFloat kGuidViewShowInterval = 3.0f;

@implementation MSGuideScrollView

- (id)initWithItems:(NSArray *)items;
{
    self = [super init];
    if (self) {
        self.completion = NULL;
        self.pagingEnabled = YES;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = NO;
        NSMutableArray *marr = [NSMutableArray array];
        
        for (int i = 0; i < [items count];i++)
        {
            NSObject<MSGuideScrollModel> *item = [items objectAtIndex:i];
            NSAssert([item conformsToProtocol:@protocol(MSGuideScrollModel)], @"item 没有实现 EMGuideScrollModel");
            
            UIView<MSGuideScrollUpdating> *cell = [MSGuideScrollView guidCellForGuidScrollView:self atIndex:i withObject:item];
            cell.clipsToBounds = YES;
            [self addSubview:cell];
            [marr addObject:cell];
        }
        
        _items = items;
        _cells = [NSArray arrayWithArray:marr];
        
        [self addTapGestureRecognizerOnLastCell];
        
    }
    return self;
}

- (void)addTapGestureRecognizerOnLastCell
{
    if ([_cells count] > 0)
    {
        UIView<MSGuideScrollUpdating> *cell = [_cells lastObject];
        cell.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLastCell)];
        recognizer.numberOfTapsRequired = 1;
        [cell addGestureRecognizer:recognizer];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    CGFloat beginX = 0;
    
    for (UIView *cell in _cells)
    {
        cell.frame = CGRectMake(beginX, 0, size.width, size.height);
        beginX += size.width;
    }
}

#pragma mark -
#pragma mark dismiss

- (void)dismissAnimated:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissAnimated:) object:nil];
    
    float duration = animated ? .3 : 0;
    
    if (!CGRectEqualToRect(CGRectZero, self.endRect))
    {
        duration = 0.5f;
        for (UIView *aview in _cells) {
            aview.backgroundColor = [UIColor clearColor];
        }
        [self genieInTransitionWithDuration:duration destinationRect:self.endRect destinationEdge:BCRectEdgeBottom completion:^{
            if (self.completion)
            {
                self.completion();
            }
            [self removeFromSuperview];
        }];
    }
    else {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowAnimatedContent animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.completion)
            {
                self.completion();
            }
            [self removeFromSuperview];
        }];
    }
}

- (void)dismiss
{
    [self dismissAnimated:YES];
}

- (void)didTapLastCell
{
    [self dismissAnimated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO)
    {
        if (scrollView.contentOffset.x == [_cells count] * scrollView.frame.size.width)
        {
            [self dismissAnimated:NO];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == [_cells count] * scrollView.frame.size.width)
    {
        [self dismissAnimated:NO];
    }
}


+ (id)showGuideScrollViewWithItems:(NSArray *)items
                            InView:(UIView *)view
                          fromRect:(CGRect)rect
{
    return [self showGuideScrollViewWithItems:items InView:view fromRect:rect autoDismissDelay:3.0f completion:NULL];
}


+ (id)showGuideScrollViewWithItems:(NSArray *)items
                            InView:(UIView *)view
                          fromRect:(CGRect)rect
                           endRect:(CGRect)endRect
{
    return [self showGuideScrollViewWithItems:items InView:view fromRect:rect endRect:endRect];
}


+ (id)showGuideScrollViewWithItems:(NSArray *)items
                            InView:(UIView *)view
                          fromRect:(CGRect)rect
                  autoDismissDelay:(CGFloat)delay
{
    return [self showGuideScrollViewWithItems:items InView:view fromRect:rect autoDismissDelay:delay completion:NULL];
}


+ (id)showGuideScrollViewWithItems:(NSArray *)items
                            InView:(UIView *)view
                          fromRect:(CGRect)rect
                           endRect:(CGRect)endRect
                  autoDismissDelay:(CGFloat)delay
{
    return [self showGuideScrollViewWithItems:items InView:view fromRect:rect endRect:endRect autoDismissDelay:delay completion:NULL];
}


+ (id)showGuideScrollViewWithItems:(NSArray *)items
                            InView:(UIView *)view
                          fromRect:(CGRect)rect
                  autoDismissDelay:(CGFloat)delay
                        completion:(void (^)(void))completion
{
    return [self showGuideScrollViewWithItems:items InView:view fromRect:rect endRect:CGRectZero autoDismissDelay:delay completion:completion];
}

+ (id)showGuideScrollViewWithItems:(NSArray *)items
                            InView:(UIView *)view
                          fromRect:(CGRect)rect
                           endRect:(CGRect)endRect
                  autoDismissDelay:(CGFloat)delay
                        completion:(void (^)(void))completion
{
    MSGuideScrollView *guidView = [[MSGuideScrollView alloc] initWithItems:items];
    guidView.endRect = endRect;
    
    if (CGRectEqualToRect(rect, CGRectZero))
    {
        rect = view.bounds;
    }
    
    guidView.frame = rect;
    if ([items count] > 1)
    {
        guidView.contentSize = CGSizeMake(([items count]+1)*rect.size.width, rect.size.height);
    }
    else
    {
        guidView.contentSize = rect.size;
    }
    
    [view addSubview:guidView];
    
    if (delay > 0)
    {
        [guidView performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
    }
    
    if (completion)
    {
        guidView.completion = completion;
    }
    
    return guidView;
}



+ (UIView<MSGuideScrollUpdating> *)guidCellForGuidScrollView:(MSGuideScrollView *)guidView
                                                     atIndex:(int)index
                                                  withObject:(NSObject<MSGuideScrollModel> *)object
{
    if ([object isKindOfClass:[UIImage class]])
    {
        MSGuideScrollImageCell *cell = [[MSGuideScrollImageCell alloc] init];
        [cell updateGuideViewWithModel:object];
        return cell;
    }
    else
    {
        UIView<MSGuideScrollUpdating> *cell = [[[object cellClass] alloc] init];
        [cell updateGuideViewWithModel:object];
        return cell;
    }
}

@end
