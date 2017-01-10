//
//  LoochaTabBar.m
//  TabBarTest
//
//  Created by RealCloud on 14-8-14.
//  Copyright (c) 2014年 RealCloud. All rights reserved.
//

#import "LoochaTabBar.h"
#import "LCCircleProgressView.h"
#import <POP.h>
#import "NSString+LoochaAdapt.h"
#define kLoochaTabBarImageTitleGap 2

@interface LoochaTabBarItemView : UIButton

//@property (nonatomic, strong, readonly) UILabel *badgeLabel;
@property (nonatomic, strong, readonly) UIImageView *badgeImageView;
//@property (nonatomic) NSString *badgeValue;

@end

@interface LoochaTabBarItemView ()
{
    CGRect originalFrame;
}

//@property (nonatomic, strong, readwrite) UILabel *badgeLabel;
@property (nonatomic, strong, readwrite) UIImageView *badgeImageView;

@end

@implementation LoochaTabBarItemView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (UIImageView *)badgeImageView
{
    if (!_badgeImageView) {
        _badgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_news_badge"]];
        //_badgeImageView.backgroundColor = [UIColor redColor];
        _badgeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _badgeImageView.layer.cornerRadius = 4.5;
        [self addSubview:_badgeImageView];
    }
    
    return _badgeImageView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGRectGetWidth(self.imageView.frame) > 0) {
        _badgeImageView.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + 3, CGRectGetMinY(self.imageView.frame) - 5, 9, 9);
    } else {
        _badgeImageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 2, CGRectGetMinY(self.titleLabel.frame) - 9, 9, 9);
    }

}
@end


typedef enum {
    LoochaTabBarStatusShow,
    LoochaTabBarStatusMovingUp,
    LoochaTabBarStatusMovingDown,
    LoochaTabBarStatusHide
}LoochaTabBarStatus;

@interface LoochaTabBar ()

@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong, readwrite) UIButton *centerButton;
@property (nonatomic, strong) NSMutableArray *itemBadgeViews;

@property (nonatomic, readwrite) NSInteger lastSelectedItemIndex;

@property (nonatomic) CGFloat itemWidth;

@property (nonatomic) LoochaTabBarStatus status;

@property (nonatomic) BOOL useCustomItemView;
@property (nonatomic, strong, readwrite) LCCircleProgressView *circleProgressView;

@end

@implementation LoochaTabBar

- (void)dealloc
{
    if (_items.count > 0) {
        [_items removeObserver:self fromObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count)] forKeyPath:@"badgeValue"];
    }
}

- (id)init
{
    return [self initWithItems:nil];
}

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.selectedItemIndex = -1;
        self.lastSelectedItemIndex = -1;
        self.centerButtonWidth = kTabBarDefaultHeight / 2;
        
        self.items = items;
    }
    
    return self;
}

- (instancetype)initWithCustomItemViews:(NSArray *)items
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.selectedItemIndex = -1;
        self.lastSelectedItemIndex = -1;
        self.centerButtonWidth = kTabBarDefaultHeight / 2;
        
//        self.items = items;
        self.itemViews = [items mutableCopy];
        self.useCustomItemView = YES;
        
        for (NSInteger i = 0; i < items.count; i++) {
            UIView *view = items[i];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
            [view addGestureRecognizer:tap];
            view.tag = i;
            view.exclusiveTouch = YES;
            [self addSubview:view];
        }
        _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerButton addTarget:self action:@selector(centerRoundButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_centerButton];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame customItemViews:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        self.centerButtonWidth = CGRectGetWidth(frame) / 10;
        self.backgroundColor = [UIColor clearColor];
        
        self.selectedItemIndex = -1;
        self.lastSelectedItemIndex = -1;
        
        //        self.items = items;
        self.itemViews = [items mutableCopy];
        self.useCustomItemView = YES;
        
        for (NSInteger i = 0; i < items.count; i++) {
            UIView *view = items[i];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
            [view addGestureRecognizer:tap];
            view.tag = i;
            view.exclusiveTouch = YES;
            [self addSubview:view];
        }
        _centerButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2 - self.centerButtonWidth, 0, self.centerButtonWidth * 2, kTabBarDefaultHeight)];
//        [_centerButton setImage:[UIImage imageNamed:@"tabbar_center_btn"] forState:UIControlStateNormal];
//        [_centerButton setImage:[UIImage imageNamed:@"tab_show_image"] forState:UIControlStateNormal];
        _centerButton.exclusiveTouch = YES;
        [_centerButton setBackgroundImage:[UIImage imageNamed:@"tab_show_background"] forState:UIControlStateNormal];
        [_centerButton setBackgroundImage:[UIImage imageNamed:@"tab_show_background"] forState:UIControlStateHighlighted];
        [_centerButton addTarget:self action:@selector(centerRoundButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_centerButton];
        
        _showImageView = [[UIImageView alloc] initWithFrame:_centerButton.bounds];
        [_centerButton addSubview:_showImageView];
        _showImageView.image = [UIImage imageNamed:@"tab_show_image"];
        _showImageView.highlightedImage = [UIImage imageNamed:@"tab_show_image_uploading"];
//        _showImageView.highlightedImage = [UIImage imageNamed:@"freshpanmenu_cancel"];
        _showImageView.contentMode = UIViewContentModeCenter;
        
        [self layoutCustomSubviews];
    }
    
    return self;
}
- (void)beginProgress
{
    _showImageView.highlighted = YES;
    [_showImageView addSubview:self.circleProgressView];
}

- (void)setProgress:(CGFloat)progress;
{
    [self.circleProgressView setProgress:progress animated:YES];
}

- (void)endProgress
{
    [UIView animateWithDuration:0.25 animations:^{
        self.circleProgressView.alpha = 0.;
    } completion:^(BOOL finished) {
        [self.circleProgressView removeFromSuperview];
        self.circleProgressView = nil;
    }];
    
    _showImageView.highlighted = NO;
}

- (void)clean
{
    for (LoochaTabBarItemView *button in self.itemViews) {
        [button removeFromSuperview];
    }
    [self.itemViews removeAllObjects];
}

- (LoochaTabBarItemView *)existViewForItem:(LoochaTabBarItem *)item
{
    NSInteger index = [self.items indexOfObject:item];
    if (index != NSNotFound && index < self.itemViews.count) {
        return self.itemViews[index];
    }
    
    return nil;
}

- (LoochaTabBarItemView *)viewForItem:(LoochaTabBarItem *)item
{
    if (!item) {
        return nil;
    }
    
    LoochaTabBarItemView *view = [self existViewForItem:item];
    if (view) {
        return view;
    }
    
    view = [[LoochaTabBarItemView alloc] init];
    view.backgroundColor = item.backgroundColor ? item.backgroundColor : [UIColor clearColor];
    [view setImage:item.image forState:UIControlStateNormal];
//    [view setImage:(item.selectedImage ? item.selectedImage : item.image) forState:UIControlStateHighlighted];
    [view setImage:item.selectedImage forState:UIControlStateSelected];
    
    [view setTitle:item.title forState:UIControlStateNormal];
    [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [view setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//    [view setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    view.titleLabel.font = [UIFont systemFontOfSize:10.0];
    
    [view setBackgroundImage:item.backgroundImage forState:UIControlStateNormal];
    [view setBackgroundImage:item.backgroundImage forState:UIControlStateHighlighted];
    
    if (item.selectedBackgroundImage) {
        [view setBackgroundImage:item.selectedBackgroundImage forState:UIControlStateHighlighted | UIControlStateSelected];
        [view setBackgroundImage:item.selectedBackgroundImage forState:UIControlStateSelected];
    } else {
        [view setBackgroundImage:item.backgroundImage forState:UIControlStateHighlighted | UIControlStateSelected];
        [view setBackgroundImage:item.backgroundImage forState:UIControlStateSelected];
    }
    
    [view addTarget:self action:@selector(actionClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return view;
}


- (void)build
{
    [self clean];
    
    CGFloat totalWidth = 0;
    NSInteger count = 0;
    for (int index = 0; index < self.items.count; index++) {
        LoochaTabBarItem *item = self.items[index];
        totalWidth += item.width;
        if (item.width != 0) {
            count += 1;
        }
        
        UIButton *view = [self viewForItem:item];
        [self.itemViews addObject:view];
        [self addSubview:view];
        
        if (self.selectedItemIndex == index) {
            view.selected = YES;
        }
    }
    
    if (totalWidth < CGRectGetWidth(self.frame) && count < self.items.count) {
        self.itemWidth = (CGRectGetWidth(self.frame) - totalWidth) / (self.items.count - count);
    } else {
        self.itemWidth = CGRectGetWidth(self.frame) / self.items.count;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    return;
    
    if (self.useCustomItemView) {
        [self layoutCustomSubviews];
        return;
    }
    
    CGFloat totalWidth = 0;
    NSInteger count = 0;
    for (int index = 0; index < self.items.count; index++) {
        LoochaTabBarItem *item = self.items[index];
        totalWidth += item.width;
        if (item.width != 0) {
            count += 1;
        }
    }
    
    if (totalWidth < CGRectGetWidth(self.frame) && count < self.items.count) {
        self.itemWidth = (CGRectGetWidth(self.frame) - totalWidth) / (self.items.count - count);
    } else {
        self.itemWidth = CGRectGetWidth(self.frame) / self.items.count;
    }
    
    CGFloat x = 0;
    for (int i =0; i < self.items.count; i++) {
        LoochaTabBarItemView *view = self.itemViews[i];
        LoochaTabBarItem *item = self.items[i];
        if (item.width == 0) {
            view.frame = CGRectMake(x, kTabBarDefaultHeight - kTabBarItemDefaultHeight, self.itemWidth, kTabBarItemDefaultHeight);
            x += self.itemWidth;
        } else {
            view.frame = CGRectMake(x, kTabBarDefaultHeight - kTabBarItemDefaultHeight, item.width, kTabBarItemDefaultHeight);
            x += item.width;
        }
        
        CGSize imageSize = [view imageForState:UIControlStateNormal].size;
        CGSize titleSize =  [view.titleLabel.text loocha_sizeWithFont:view.titleLabel.font];
                
        view.imageEdgeInsets = UIEdgeInsetsMake((titleSize.height + kLoochaTabBarImageTitleGap) / -2 + item.contentOffset.vertical, titleSize.width / 2 + item.contentOffset.horizontal, (titleSize.height + kLoochaTabBarImageTitleGap) / 2 - item.contentOffset.vertical, titleSize.width / -2 - item.contentOffset.horizontal);
        view.titleEdgeInsets = UIEdgeInsetsMake((imageSize.height + kLoochaTabBarImageTitleGap) / 2 + item.contentOffset.vertical, imageSize.width / -2 + item.contentOffset.horizontal, (imageSize.height + kLoochaTabBarImageTitleGap) / -2 - item.contentOffset.vertical, imageSize.width / 2 - item.contentOffset.horizontal);
    }
    
    self.centerButton.frame = CGRectMake(CGRectGetWidth(self.frame) / 2 - self.centerButtonWidth, 0, self.centerButtonWidth * 2, self.centerButtonWidth * 2);
    [self bringSubviewToFront:self.centerButton];
}

- (void)layoutCustomSubviews
{
    CGFloat totalWidth = 0;
    NSInteger count = 0;
    for (int index = 0; index < self.itemViews.count; index++) {
        UIView<LoochaTabBarItemProtocol> *itemView = self.itemViews[index];
        totalWidth += itemView.width;
        if (itemView.width != 0) {
            count += 1;
        }
    }
    
    if (totalWidth < CGRectGetWidth(self.frame) && count < self.itemViews.count) {
        self.itemWidth = ceil((CGRectGetWidth(self.frame) - totalWidth) / (self.itemViews.count - count));
    } else {
        self.itemWidth = ceil(CGRectGetWidth(self.frame) / self.itemViews.count);
    }
    
    CGFloat x = 0;
    for (int i =0; i < self.itemViews.count; i++) {
        UIView<LoochaTabBarItemProtocol> *itemView = self.itemViews[i];
        if (itemView.width == 0) {
            itemView.frame = CGRectMake(x, kTabBarDefaultHeight - kTabBarItemDefaultHeight, self.itemWidth, kTabBarItemDefaultHeight);
            x += self.itemWidth;
        } else {
            itemView.frame = CGRectMake(x, kTabBarDefaultHeight - kTabBarItemDefaultHeight, itemView.width, kTabBarItemDefaultHeight);
            x += itemView.width;
        }
    }
    
    self.centerButtonWidth = self.itemWidth / 2;
    self.centerButton.frame = CGRectMake(x / 2 - self.centerButtonWidth, 0, self.centerButtonWidth * 2, kTabBarDefaultHeight);
}

#pragma mark - Getter/Setter
- (NSMutableArray *)itemViews
{
    if (!_itemViews) {
        _itemViews = [NSMutableArray arrayWithCapacity:self.items.count];
    }
    
    return _itemViews;
}

- (void)setItems:(NSArray *)items
{
    if (_items == items || items.count == 0) {
        return;
    }
    
    if (_items.count > 0) {
        [_items removeObserver:self fromObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count)] forKeyPath:@"badgeValue"];
    }
    
    _items = items;
    [_items addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count)] forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self build];
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex
{
    self.lastSelectedItemIndex = _selectedItemIndex;
    
    if (_selectedItemIndex == selectedItemIndex) {
        return;
    }
    
    if (self.lastSelectedItemIndex >= 0 && self.lastSelectedItemIndex < self.itemViews.count) {
        if (self.useCustomItemView) {
            UIView<LoochaTabBarItemProtocol> *view = self.itemViews[self.lastSelectedItemIndex];
            [view setSelected:NO animated:YES];
        } else {
            UIButton *lastButton = self.itemViews[self.lastSelectedItemIndex];
            lastButton.selected = NO;
        }
    }
    
    _selectedItemIndex = selectedItemIndex;
    if (selectedItemIndex >= 0 && selectedItemIndex < self.itemViews.count) {
        if (self.useCustomItemView) {
            UIView<LoochaTabBarItemProtocol> *view = self.itemViews[selectedItemIndex];
            [view setSelected:YES animated:YES];
        } else {
            UIButton *button = self.itemViews[selectedItemIndex];
            button.selected = YES;
        }
    }
}


#pragma mark - Action
- (void)actionClicked:(UIButton *)sender
{
    NSInteger index = [self.itemViews indexOfObject:sender];
    
    if ([self.delegate respondsToSelector:@selector(tabBar:canSelectItemAtIndex:)]
        && ![self.delegate tabBar:self canSelectItemAtIndex:index]) {
        return;
    }
    
    self.selectedItemIndex = [self.itemViews indexOfObject:sender];
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)]) {
        [self.delegate tabBar:self didSelectItemAtIndex:[self.itemViews indexOfObject:sender]];
    }
}

- (void)centerRoundButtonClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(tabBarDidClickOnCenterButton:)]) {
        [self.delegate tabBarDidClickOnCenterButton:self];
    }
}

- (void)actionTap:(UITapGestureRecognizer *)tap
{
    NSInteger index = tap.view.tag;
    [self selectItemIndex:index];
    
}

- (void)selectItemIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(tabBar:canSelectItemAtIndex:)]
        && ![self.delegate tabBar:self canSelectItemAtIndex:index]) {
        return;
    }
    
    self.selectedItemIndex = index;
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)]) {
        [self.delegate tabBar:self didSelectItemAtIndex:index];
    }
}

#pragma mark - Public Methods

- (void)show:(BOOL)animated
{
    if (self.status == LoochaTabBarStatusShow || self.status == LoochaTabBarStatusMovingUp) {
        return;
    }
    
    self.status = LoochaTabBarStatusMovingUp;
    
    CGRect targetFrame = self.frame;
    targetFrame.origin.y = CGRectGetHeight(self.superview.bounds) - CGRectGetHeight(self.frame);
    
    [UIView animateWithDuration:(animated ? 0.25 : 0) delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = targetFrame;
    } completion:^(BOOL finished) {
        self.status = LoochaTabBarStatusShow;
    }];
}

- (void)hide:(BOOL)animated
{
    if (self.status == LoochaTabBarStatusHide || self.status == LoochaTabBarStatusMovingDown) {
        return;
    }
    
    self.status = LoochaTabBarStatusMovingDown;
    
    CGRect targetFrame = self.frame;
    targetFrame.origin.y = CGRectGetHeight(self.superview.bounds);
    
    [UIView animateWithDuration:(animated ? 0.25 : 0) delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = targetFrame;
    } completion:^(BOOL finished) {
        self.status = LoochaTabBarStatusHide;
    }];
}

- (void)vibrate
{
    [UIView animateWithDuration:0.2 animations:^{
        self.layer.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 6);
    } completion:^(BOOL finished) {
        POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        springAnimation.velocity = @10;
        springAnimation.springBounciness = 20;
        springAnimation.springSpeed = 10.0;
        springAnimation.toValue = @(CGRectGetMidY(self.frame) - 6);
        [self.layer pop_addAnimation:springAnimation forKey:@"springAnimation"];
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[LoochaTabBarItem class]]/* && [keyPath isEqualToString:@"badgeValue"]*/) {
        NSInteger index = [self.items indexOfObject:object];
        LoochaTabBarItem *item = (LoochaTabBarItem *)object;
        LoochaTabBarItemView *view = self.itemViews[index];
        if (item.badgeValue == nil) {
            //view.badgeLabel.text = nil;
            view.badgeImageView.hidden = YES;
        } else {
            //view.badgeLabel.text = [change objectForKey:@"new"];
            view.badgeImageView.hidden = NO;
        }
    }
}

- (void)setBadgeValue:(NSString *)badgeValue atIndex:(int)index
{
    if (self.useCustomItemView) {
        UIView<LoochaTabBarItemProtocol> *itemView = self.itemViews[index];
        itemView.badgeValue = badgeValue;
        return;
    }
    
    if (index < 0 || index >= [self.items count]) {
        return;
    }
    LoochaTabBarItem *item = self.items[index];
    item.badgeValue = badgeValue;
}

@end

