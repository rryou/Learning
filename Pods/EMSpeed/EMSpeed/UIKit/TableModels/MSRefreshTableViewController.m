//
//  MSRefreshTableViewController.m
//  TTTT
//
//  Created by Mac mini 2012 on 15-3-2.
//  Copyright (c) 2015年 Mac mini 2012. All rights reserved.
//

#import "MSRefreshTableViewController.h"


@interface MSRefreshTableViewController () {
    
    BOOL _isEmptyViewHidden;
}

@end

@implementation MSRefreshTableViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.enableRefreshHeader = YES;
        self.enableRefreshFooter = YES;
        self.refreshWhenFirstViewDidAppear = YES;
        self.refreshWhenPushBack = NO;
        _isBackFromPush = NO;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.enableRefreshHeader = YES;
    self.enableRefreshFooter = YES;
    self.refreshWhenFirstViewDidAppear = YES;
    self.refreshWhenPushBack = NO;
    _isBackFromPush = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRefresh];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.refreshWhenFirstViewDidAppear)
    {
        self.refreshWhenFirstViewDidAppear = NO;
        [self headerRefreshing];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ((_isBackFromPush && self.refreshWhenPushBack))
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.tableView.mj_header beginRefreshing];
#pragma clang diagnostic pop
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isBackFromPush = YES;
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    __weak MSRefreshTableViewController* weakSelf = self;
    
    if (_enableRefreshHeader) {
        
        _refreshHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            [weakSelf headerRefreshing];
        }];
        self.tableView.mj_header = _refreshHeader;
    }
    else{
        self.tableView.mj_header = nil;
    }
    
    if (_enableRefreshFooter) {
        _refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf footerRefreshing];
        }];
        self.tableView.mj_footer = _refreshFooter;
    }
    else{
        self.tableView.mj_footer = nil;
    }
#pragma clang diagnostic pop

}

- (void)setEnableRefreshHeader:(BOOL)enableRefreshHeader
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    __weak MSRefreshTableViewController* weakSelf = self;
    
    _enableRefreshHeader = enableRefreshHeader;
    
    if (self.isViewLoaded) {
        if (_enableRefreshHeader) {
            
            _refreshHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
                [weakSelf headerRefreshing];
            }];
            self.tableView.mj_header = _refreshHeader;
        }
        else {
            self.tableView.mj_header = nil;
        }
    }
#pragma clang diagnostic pop
}

- (void)setEnableRefreshFooter:(BOOL)enableRefreshFooter
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    __weak MSRefreshTableViewController* weakSelf = self;
    
    _enableRefreshFooter = enableRefreshFooter;
    
    if (self.isViewLoaded) {
        if (_enableRefreshFooter) {
            _refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [weakSelf footerRefreshing];
            }];
            self.tableView.mj_footer = _refreshFooter;
        }
        else {
            self.tableView.mj_footer = nil;
        }
    }
#pragma clang diagnostic pop
}


- (void)headerRefreshing
{
    // 子类实现
    // 不要忘记调用
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self.tableView.mj_header endRefreshing];
#pragma clang diagnostic pop
}

- (void)footerRefreshing
{
    // 子类实现
    // 不要忘记调用
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self.tableView.mj_header endRefreshing];
#pragma clang diagnostic pop
}


@end
