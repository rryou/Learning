//
//  EMHorizontalPagingView.h
//  Coll
//
//  Created by Samuel on 15/4/16.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSCollectionDataSource;
@protocol MSCollectionCellModel;


typedef NS_ENUM(NSUInteger, MSHorizontalPagingControlAlignment)
{
    MSHorizontalPagingControlAlignmentLeft,
    MSHorizontalPagingControlAlignmentCenter,
    MSHorizontalPagingControlAlignmentRight,
};


@class MSHorizontalCollectionView;

@protocol MSHorizontalCollectionViewDelegate <NSObject>

@optional
- (void)MSHorizontalCollectionView:(MSHorizontalCollectionView *)collectionView
                       didTapModel:(id<MSCollectionCellModel>)model
                       atIndexPath:(NSIndexPath *)indexPath;
@end


@interface MSHorizontalCollectionView : UIView <UICollectionViewDelegate, UIScrollViewDelegate>{
    
    UICollectionView *_collectionView;
    UIPageControl *_pageControl;
    MSCollectionDataSource *_dataSource;
    
    MSHorizontalPagingControlAlignment _alignment;
    UIEdgeInsets _pageControlEdgeInsets;
    
    __unsafe_unretained id<MSHorizontalCollectionViewDelegate> _delegate;
}

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) UIPageControl *pageControl;
@property (nonatomic, assign) BOOL enablePageControl;

@property (nonatomic, strong) MSCollectionDataSource *dataSource;
@property (nonatomic, assign) MSHorizontalPagingControlAlignment alignment;
@property (nonatomic, assign) UIEdgeInsets pageControlEdgeInsets;

@property (nonatomic, assign) id<MSHorizontalCollectionViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end