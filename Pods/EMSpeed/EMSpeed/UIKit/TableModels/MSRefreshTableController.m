//
//  MSRefreshTableController.m
//  MMTableViewDemo
//
//  Created by Mac mini 2012 on 15-2-27.
//  Copyright (c) 2015年 Mac mini 2012. All rights reserved.
//

#import "MSRefreshTableController.h"

@interface MSRefreshTableController () {
    NSUInteger _numberOfControllersInStack;
    
    BOOL _refreshWhenFirstViewDidAppear;
    BOOL _enableRefreshHeader;
    BOOL _enableRefreshFooter;
    
}


@property (nonatomic, strong, readwrite) MJRefreshHeader *refreshHeader;
@property (nonatomic, strong, readwrite) MJRefreshFooter *refreshFooter;

@end

@implementation MSRefreshTableController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _refreshWhenFirstViewDidAppear = YES;
        _enableRefreshHeader = YES;
        _enableRefreshFooter = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _numberOfControllersInStack = 0;
    
    [self loadHeaderRefresh];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if ([self respondsToSelector:@selector(willRefreshHeaderWhenViewWillAppear:)]) {
        BOOL animated = NO;
        
        if ([self willRefreshHeaderWhenViewWillAppear:&animated]) {
            if (animated) {
                [self beginHeaderRefreshing];
            }
            else {
                if ([self respondsToSelector:@selector(refreshHeaderDidRefresh:)])
                {
                    [self refreshHeaderDidRefresh:_refreshHeader];
                }
            }
        }
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // 兼容老版本逻辑
        if (self.refreshWhenFirstViewDidAppear) {
            self.refreshWhenFirstViewDidAppear = NO;
            if ([self respondsToSelector:@selector(headerRefreshing)]) {
                [self headerRefreshing];
            }
        }
#pragma clang diagnostic pop
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(willRefreshHeaderWhenViewDidAppear:)]) {
        BOOL animated = NO;
        
        if ([self willRefreshHeaderWhenViewDidAppear:&animated]) {
            if (animated) {
                [self beginHeaderRefreshing];
            }
            else {
                if ([self respondsToSelector:@selector(refreshHeaderDidRefresh:)])
                {
                    [self refreshHeaderDidRefresh:_refreshHeader];
                }
            }
        }
    }
    else {
        // 兼容老版本逻辑
        BOOL isPushBack = _numberOfControllersInStack > 0 && _numberOfControllersInStack - 1 == [self.navigationController.viewControllers count];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (isPushBack && self.refreshWhenPushBack) {
            [self.refreshHeader beginRefreshing];
        }
#pragma clang diagnostic pop
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _numberOfControllersInStack = [self.navigationController.viewControllers count];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)refreshHeaderDidRefresh:(MJRefreshHeader *)refreshHeader {
    
}

# pragma mark - Refresh Header
- (BOOL)loadHeaderRefresh
{
    if ([self refreshHeader]) {
        return YES;
    }
    
    return NO;
}


- (MJRefreshHeader *)refreshHeader
{
    if (!_refreshHeader && _enableRefreshHeader) {
        if ([self respondsToSelector:@selector(refreshHeaderOfTableView)]) {
            _refreshHeader = [self refreshHeaderOfTableView];
        }
        
        if (!_refreshHeader) {
            _refreshHeader = [MJRefreshGifHeader headerWithRefreshingBlock:NULL];
        }
        
        __weak __typeof(self)weakSelf = self;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _refreshHeader.refreshingBlock = ^(){
            if ([weakSelf respondsToSelector:@selector(refreshHeaderDidRefresh:)])
            {
                [weakSelf refreshHeaderDidRefresh:weakSelf.refreshHeader];
            }
            else if ([weakSelf respondsToSelector:@selector(headerRefreshing)]) {
                [weakSelf headerRefreshing];
            }
        };
#pragma clang diagnostic pop
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (_tableView.mj_header != _refreshHeader) {
        _tableView.mj_header = _refreshHeader;
    }
#pragma clang diagnostic pop
    return _refreshHeader;
}

- (void)beginHeaderRefreshing
{
    [self.refreshHeader beginRefreshing];
}


- (MJRefreshHeader *)refreshHeaderOfTableView
{
    return _refreshHeader;
}


- (void)setRefreshHeaderHidden:(BOOL)refreshHeaderHidden
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.tableView.mj_header.hidden = refreshHeaderHidden;
#pragma clang diagnostic pop
}


- (BOOL)refreshHeaderHidden
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (self.tableView.mj_header && self.tableView.mj_header.hidden);
#pragma clang diagnostic pop
}


- (void)endHeaderRefreshing
{
    [self.refreshHeader endRefreshing];
}


# pragma mark - Refresh Footer

- (BOOL)loadFooterRefresh
{
    if ([self refreshFooter]) {
        return YES;
    }
    
    return NO;
}


- (MJRefreshFooter *)refreshFooter
{
    if (!_refreshFooter && _enableRefreshFooter){
        if ([self respondsToSelector:@selector(refreshFooterOfTableView)]) {
            _refreshFooter = [self refreshFooterOfTableView];
        }
        
        if (!_refreshFooter) {
            _refreshFooter = [MJRefreshAutoFooter footerWithRefreshingBlock:NULL];
        }
        
        __weak __typeof(self)weakSelf = self;

        _refreshFooter.refreshingBlock = ^(){
            if ([weakSelf respondsToSelector:@selector(refreshFooterDidRefresh:)])
            {
                [weakSelf refreshFooterDidRefresh:weakSelf.refreshFooter];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            else if ([weakSelf respondsToSelector:@selector(footerRefreshing)]) {
                [weakSelf footerRefreshing];
            }
#pragma clang diagnostic pop
        };
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (_tableView.mj_footer != _refreshFooter) {
        _tableView.mj_footer = _refreshFooter;
    }
#pragma clang diagnostic pop
    return _refreshFooter;
}


- (void)beginFooterRefreshing
{
    [self.refreshFooter beginRefreshing];
}


- (MJRefreshFooter *)refreshFooterOfTableView
{
    return _refreshFooter; // 
}


- (BOOL)refreshFooterHidden
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (self.tableView.mj_footer && self.tableView.mj_footer.hidden);
#pragma clang diagnostic pop
}


- (void)endFooterRefreshing
{
    [self.refreshFooter endRefreshing];
}


- (void)setRefreshFooterStatus:(MSRefreshFooterStatus)status
{
    if (status == MSRefreshFooterStatusIdle) {
        self.refreshFooter.hidden = NO;
        [self.refreshFooter resetNoMoreData];
    }
    else if (status == MSRefreshFooterStatusNoMoreData) {
        self.refreshFooter.hidden = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.refreshFooter noticeNoMoreData];
#pragma clang diagnostic pop
    }
    else if (status == MSRefreshFooterStatusHidden) {
        [self.refreshFooter setHidden:YES];
    }
    else if (status == MSRefreshFooterStatusNoInit) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _tableView.mj_footer = nil;
        _refreshFooter = nil;
#pragma clang diagnostic pop
    }
}

- (MSRefreshFooterStatus)refreshFooterStatus
{
    if (!_refreshFooter) {
        return MSRefreshFooterStatusNoInit;
    }
    else if (_refreshFooter.hidden) {
        return MSRefreshFooterStatusHidden;
    }
    else if (_refreshFooter.state == MJRefreshStateNoMoreData) {
        return MSRefreshFooterStatusNoMoreData;
    }
    
    return MSRefreshFooterStatusIdle;
}


# pragma mark - DEPRECATED

-(void)setEnableRefreshHeader:(BOOL)enable
{
    _enableRefreshHeader = enable;
    
    if (_enableRefreshHeader) {
        [self refreshHeader];
    }
    else {
        _refreshHeader = nil;
        if (_tableView) {
            _tableView.mj_header = nil;
        }
    }
}

- (void)setEnableRefreshFooter:(BOOL)enable
{
    _enableRefreshFooter = enable;
    
    if (_enableRefreshFooter) {
        [self refreshFooter];
    }
    else {
        _refreshFooter = nil;
        if (_tableView) {
            _tableView.mj_footer = nil;
        }
    }
}


- (void)headerRefreshing
{
    // do noting
}

- (void)footerRefreshing
{
    // do noting
}

@end
