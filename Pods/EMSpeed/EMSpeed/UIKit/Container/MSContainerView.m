//
//  MSContainerView.m
//  NetEaseNews
//
//  Created by flora on 16/3/18.
//  Copyright © 2016年 WackoSix. All rights reserved.
//

#import "MSContainerView.h"
#import "MSNavigationView.h"

@interface MSContainerView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *viewControllers;

@property (weak, nonatomic) UICollectionView *collectionView;

@property (weak, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (assign, nonatomic) Class navigationViewClass;

@end

static NSString *CellID = @"ControllerCell";

@implementation MSContainerView
@synthesize navigationView = _navigationView;

#pragma mark - collectionView datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.viewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *view = [self.viewControllers[indexPath.item] view];
    
    [cell.contentView addSubview:view];
    
    view.frame = cell.bounds;
    
    return cell;
}

#pragma mark - collectionView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger index = scrollView.contentOffset.x / self.bounds.size.width;
    _navigationView.selectedItemIndex = index;
    _selectedIndex = index;
    [self didSelectControllerAtIndex:_selectedIndex];

}


#pragma mark - view

- (void)layoutSubviews
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    _navigationView.frame = CGRectMake(0, 0, width, 35);
    self.collectionView.frame = CGRectMake(0, _navigationView.frame.size.height, width, height - _navigationView.frame.size.height);
    
    self.flowLayout.itemSize = self.collectionView.bounds.size;
    
}

#pragma mark - init

- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
    return [self initWithViewControllers:viewControllers navigationClass:[MSNavigationView class]];
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers navigationClass:(Class<MSNavigatorView>)navigationClass
{
    self = [super init];
    if (self) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout = flowLayout;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        
        //设置collectionView的属性
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collectionView.pagingEnabled = YES;
        _collectionView = collectionView;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellID];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:collectionView];
        self.collectionView.scrollsToTop = NO;
        
        if (navigationClass == nil)
        {
            navigationClass = [MSNavigationView class];
        }
        
        //添加导航view
        typeof(self) __weak weakObj= self;
        MSNavigationView *view = [navigationClass navigationViewWithItems:nil itemClick:^(NSInteger selectedIndex) {
            
            [weakObj setSelectedIndex:selectedIndex];
        }];
        
        [self addSubview:view];
        
        _navigationView = view;
        
        self.viewControllers = viewControllers;
        __block NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:viewControllers.count];
        [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [arrM addObject:obj.title ? : @""];
        }];
        
        [self navigationView].items = arrM.copy;
        [self navigationView].selectedItemIndex = 0;
    }
    return self;
}

- (instancetype)init{
    
    if (self = [super init]) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout = flowLayout;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        
        //设置collectionView的属性
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collectionView.pagingEnabled = YES;
        _collectionView = collectionView;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellID];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:collectionView];
        self.collectionView.scrollsToTop = NO;
        
        //添加导航view
        typeof(self) __weak weakObj= self;
        MSNavigationView *view = [MSNavigationView navigationViewWithItems:nil itemClick:^(NSInteger selectedIndex) {
            
            _selectedIndex = selectedIndex;
            [self updateCollectViewSelection];
            [weakObj didSelectControllerAtIndex:selectedIndex];
        }];
        view.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:view];
        
        _navigationView = view;
        
    }
    return self;
}


- (UIViewController *)currentController
{
    if (_selectedIndex < [self.viewControllers count]) {
        return self.viewControllers[_selectedIndex];
    }
    return nil;
}

#pragma mark -
#pragma mark selection
#pragma mark - setting

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    
    _selectedIndex = selectedIndex;
    
    if (self.navigationView &&
        selectedIndex < [self.viewControllers count])
    {
        //选中navigationViewControl
        [self.navigationView setSelectedItemIndex:selectedIndex];
        //滚动collectionView
        [self updateCollectViewSelection];
    }
}
/**
 *  更新CollectionView的显示状态
 */
- (void)updateCollectViewSelection
{
    if (_selectedIndex >= 0)
    {
        CGFloat offsetX = self.bounds.size.width * _selectedIndex;
        self.collectionView.contentOffset = CGPointMake(offsetX, 0);
    }
}

- (void)didSelectControllerAtIndex:(NSInteger)index
{
    
}

@end
