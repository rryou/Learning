//
//  EMHorizontalPagingView.m
//  Coll
//
//  Created by Samuel on 15/4/16.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSHorizontalCollectionView.h"
#import "MSCollectionDataSource.h"

@implementation MSHorizontalCollectionView

@synthesize collectionView = _collectionView;
@synthesize pageControl = _pageControl;
@synthesize dataSource = _dataSource;
@synthesize alignment = _alignment;
@synthesize pageControlEdgeInsets = _pageControlEdgeInsets;
@synthesize enablePageControl = _enablePageControl;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initUI];
        [self setConfig];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setConfig];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initUI];
}

- (void)initUI {
    UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _collectionView.pagingEnabled = YES;
    _collectionView.delegate = self;
    [self addSubview:_collectionView];

}

- (void)setConfig {
    _enablePageControl = YES;
    self.pageControlEdgeInsets = UIEdgeInsetsMake(0, 10, 10, 10);
    self.alignment = MSHorizontalPagingControlAlignmentLeft;
}

- (UIPageControl *)pageControl
{
    if (_enablePageControl && _pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        [self addSubview:_pageControl];
    }
    
    return _pageControl;
}

- (void)setEnablePageControl:(BOOL)enablePageControl
{
    _enablePageControl = enablePageControl;
    _pageControl.hidden = !_enablePageControl;
}

- (void)setDataSource:(MSCollectionDataSource *)dataSource
{
    _collectionView.dataSource = dataSource;
//    [dataSource registerCellForView:_collectionView];
//    
    if ([dataSource.sections count] > 0) {
        self.pageControl.numberOfPages = [[dataSource itemsAtSection:0] count];
        int index = _collectionView.contentOffset.x/self.frame.size.width;
        self.pageControl.currentPage = index;
    }
}

- (MSCollectionDataSource *)dataSource
{
    return (MSCollectionDataSource *)_collectionView.dataSource;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _collectionView.frame = self.bounds;
    
    switch (self.alignment) {
        case MSHorizontalPagingControlAlignmentLeft:
        {
            CGSize size = [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages];
            CGPoint pageControlCenter = CGPointMake(ceilf(size.width/2.f)+_pageControlEdgeInsets.right, self.bounds.size.height-_pageControlEdgeInsets.bottom);
            self.pageControl.center = pageControlCenter;
        }
            break;
        case MSHorizontalPagingControlAlignmentCenter:
        {
            CGPoint pageControlCenter = CGPointMake(self.center.x, self.bounds.size.height-_pageControlEdgeInsets.bottom);
            self.pageControl.center = pageControlCenter;
        }
            break;
        case MSHorizontalPagingControlAlignmentRight:
        {
            CGSize size = [self.pageControl sizeForNumberOfPages:self.pageControl.numberOfPages];
            CGPoint pageControlCenter = CGPointMake(self.bounds.size.width-ceilf(size.width/2.f)-_pageControlEdgeInsets.left, self.bounds.size.height-_pageControlEdgeInsets.bottom);
            self.pageControl.center = pageControlCenter;
        }
            break;
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_collectionView.dataSource isKindOfClass:[MSCollectionDataSource class]]) {
        MSCollectionDataSource *ds = (MSCollectionDataSource *)_collectionView.dataSource;
        id<MSCollectionCellModel> item = [ds itemAtIndexPath:indexPath];
        
        return item.layoutSize;
    }
    
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MSHorizontalCollectionView:didTapModel:atIndexPath:)]) {
        
        MSCollectionDataSource *ds = (MSCollectionDataSource *)_collectionView.dataSource;
        id<MSCollectionCellModel> item = [ds itemAtIndexPath:indexPath];
        if (item) {
            [self.delegate MSHorizontalCollectionView:self didTapModel:item atIndexPath:indexPath];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x/self.frame.size.width;
    self.pageControl.currentPage = index;
}

@end
