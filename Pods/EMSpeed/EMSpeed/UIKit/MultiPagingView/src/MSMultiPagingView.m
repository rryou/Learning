//
//  EMMallScrollADView.m
//  EMStock
//
//  Created by zhangzhiyao on 14-10-9.
//  Copyright (c) 2014年 flora. All rights reserved.
//

#import "MSMultiPagingView.h"
#import <EMSpeed/MSUIKitCore.h>
#import <EMSpeed/UIImageView+DownloadIcon.h>
#import "MSPageModel.h"
#import "MSPageUpdating.h"
#import "MSPageImageView.h"

#define kADPlaceHolderMaxSize CGSizeMake(100,70)

@implementation MSMultiPagingView

@synthesize pageItems = _pageItems;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadViews];
    }
    return self;
}

- (void)loadViews
{
    self.pageControlAlignment = MSMultiPagingPageControlAlignmentCenter;
    
    self.clipsToBounds = YES;
    _placeholderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:MSUIResName(@"overlay")]];
    _placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_placeholderImageView];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScrollView:)];
    [_scrollView addGestureRecognizer:tapGesture];
    
    _pageControl = [[StyledPageControl alloc] initWithFrame:CGRectZero];
    _pageControl.pageControlStyle = PageControlStyleDefault;
    _pageControl.hidesForSinglePage = YES;
    [self addSubview:_pageControl];
    
    [self bringSubviewToFront:_pageControl];
    
    _imageviews = [[NSMutableArray alloc] init];
    
    _timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(changePage) userInfo:nil repeats:YES];
}

- (void)dealloc
{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize placeHolderSize = CGSizeMake(MIN(.5*self.frame.size.width, kADPlaceHolderMaxSize.width), MIN(self.frame.size.height, kADPlaceHolderMaxSize.height));
    _placeholderImageView.frame = CGRectMake(.5* (self.frame.size.width - placeHolderSize.width), .5 * (self.frame.size.width - placeHolderSize.height),placeHolderSize.width, placeHolderSize.height);
    CGRect rect = self.bounds;
    _scrollView.frame = rect;
    
    _pageControl.frame = CGRectMake(0, 0, 60, 10);
    switch (self.pageControlAlignment) {
        case MSMultiPagingPageControlAlignmentLeft:
            _pageControl.center = CGPointMake(45, rect.size.height - 12);
            break;
        case MSMultiPagingPageControlAlignmentCenter:
            _pageControl.center = CGPointMake(CGRectGetMidX(rect), rect.size.height - 12);
            break;
        case MSMultiPagingPageControlAlignmentRight:
            _pageControl.center = CGPointMake(rect.size.width - 45, rect.size.height - 12);
            break;
    }
    
    for (UIView *view in _imageviews)
    {
        view.frame = rect;
        rect.origin.x += rect.size.width;
    }
    _scrollView.contentSize = CGSizeMake(rect.origin.x, rect.size.height);
}

- (void)setPageItems:(NSArray *)pageItems
{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    
    [_imageviews removeAllObjects];
    _pageItems = pageItems;
    int count = (int)[pageItems count];
    
    for (UIView *aView in [_scrollView subviews])
    {
        [aView removeFromSuperview];
    }
    
    CGRect rect = self.bounds;
    for (int i = 0 ; i<count; i++)
    {
        NSObject<MSPageModel> *aData = [_pageItems objectAtIndex:i];
        UIView<MSPageUpdating> *page = [[MSPageImageView alloc] initWithFrame:rect];
        [page updatePageView:aData];
        [_scrollView addSubview:page];
        [_imageviews addObject:page];
        rect.origin.x += rect.size.width;
    }
    _scrollView.contentSize = CGSizeMake(rect.origin.x, rect.size.height);
    _scrollView.contentOffset = CGPointZero;
    
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = count;
    if (count > 1) {
        [_timer fire];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int offsetx = scrollView.contentOffset.x;
    int page = floorf((offsetx + scrollView.frame.size.width/2. - 1)*1.0/scrollView.frame.size.width);
    if (page < 0) {
        page = 0;
    }
    else if (page > _pageControl.numberOfPages - 1) {
        page = _pageControl.numberOfPages - 1;
    }
    _pageControl.currentPage = page;
}

- (void)didTapScrollView:(UITapGestureRecognizer *)recognizer
{
    if (_delegate)
    {
        CGPoint location = [recognizer locationInView:_scrollView];
        if ([_delegate respondsToSelector:@selector(adView:didSelectAdData:)])
        {
            NSUInteger index = (int)(location.x/self.frame.size.width);
            NSObject<MSPageModel> *aData = [_pageItems objectAtIndex:index];
            [_delegate adView:self didSelectAdData:aData];
        }
    }
}

- (void)changePage {
    int totalPages = [_pageControl numberOfPages];
    if (totalPages > 1) {
        int curPage = _pageControl.currentPage;
        int nextPage = (curPage == totalPages - 1)?0:curPage++;
        [_scrollView setContentOffset:CGPointMake(nextPage * _scrollView.frame.size.width, 0) animated:curPage != totalPages - 1];
    }
}


@end
