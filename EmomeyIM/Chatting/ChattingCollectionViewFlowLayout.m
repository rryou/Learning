//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingCollectionViewFlowLayout.h"

@interface ChattingCollectionViewFlowLayout ()
{
    CGFloat _springDamping;
    CGFloat _springFrequency;
}
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) NSMutableSet *visibleIndexPaths;
@property (nonatomic, strong) NSMutableArray *indexPathsToAnimate;

@property (assign, nonatomic) CGFloat latestDelta;
@end
@implementation ChattingCollectionViewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = 10;
        self.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
         _springinessEnabled = NO;
         _springResistanceFactor = 500;
         _springDamping = 0.5;
         _springFrequency = 0.8;
 
    }
    return self;
}
- (void)dealloc
{
    [_dynamicAnimator removeAllBehaviors];
    _dynamicAnimator = nil;
    [_visibleIndexPaths removeAllObjects];
    _visibleIndexPaths = nil;
}
#pragma mark - Setters
- (void)setSpringinessEnabled:(BOOL)springinessEnabled
{
    if (_springinessEnabled == springinessEnabled) {
        return;
    }
    _springinessEnabled = springinessEnabled;
    
    if (!springinessEnabled)
    {
        [_dynamicAnimator removeAllBehaviors];
        [_visibleIndexPaths removeAllObjects];
    }
//    [self invalidateLayoutWithContext:[UICollectionViewFlowLayoutInvalidationContext context]];
    [self invalidateLayout];
}
#pragma mark - Getters
- (UIDynamicAnimator *)dynamicAnimator
{
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return _dynamicAnimator;
}

- (NSMutableSet *)visibleIndexPaths
{
    if (!_visibleIndexPaths) {
        _visibleIndexPaths = [NSMutableSet new];
    }
    return _visibleIndexPaths;
}
@end
