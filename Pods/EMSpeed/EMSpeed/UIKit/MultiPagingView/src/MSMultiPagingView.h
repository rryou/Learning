//
//  EMMallScrollADView.h
//  EMStock
//
//  Created by zhangzhiyao on 14-10-9.
//  Copyright (c) 2014年 flora. All rights reserved.
//
//广告模块，可展示一张广告图片、也可展示多张广告图片
//
//
//

#import <UIKit/UIKit.h>
#import "StyledPageControl.h"

@class MSMultiPagingView;
@protocol MSPageModel;

@protocol MSPagingViewDelegate <NSObject>

@optional
- (void)adView:(MSMultiPagingView *)adView didSelectAdData:(NSObject<MSPageModel> *)data;

@end


typedef NS_ENUM(NSUInteger, MSMultiPagingPageControlAlignment)
{
    MSMultiPagingPageControlAlignmentLeft,
    MSMultiPagingPageControlAlignmentCenter,
    MSMultiPagingPageControlAlignmentRight,
};



@interface MSMultiPagingView : UIView <UIScrollViewDelegate>{
    UIImageView *_placeholderImageView;
    UIScrollView *_scrollView;
    StyledPageControl *_pageControl;
    int _current;
    
    NSMutableArray *_imageviews;
    NSArray *_pageItems;
    
    NSTimer *_timer;
}

@property (nonatomic, weak) id<MSPagingViewDelegate> delegate;
@property (nonatomic, strong) NSArray *pageItems;
@property (nonatomic, assign) MSMultiPagingPageControlAlignment pageControlAlignment; // 默认是居中

@end
