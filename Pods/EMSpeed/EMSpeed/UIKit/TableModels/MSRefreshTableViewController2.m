//
//  MSRefreshTableViewController2.m
//  Pods
//
//  Created by flora on 16/6/12.
//
//

#import "MSRefreshTableViewController2.h"


@interface MSRefreshTableViewController2 ()

@property (nonatomic, strong, readwrite) MJRefreshHeader *refreshHeader;
@property (nonatomic, strong, readwrite) MJRefreshFooter *refreshFooter;

@end

@implementation MSRefreshTableViewController2


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.didSupportHeaderRefreshing = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化refreshHeader
    [self refreshHeader];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self headerRefreshingWhenViewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self headerRefreshingWhenViewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)headerRefreshingWhenViewWillAppear:(BOOL)animated
{
    //[self beginHeaderRefreshing]; 刷新有下拉动画
//    [self refreshHeaderDidRefresh:self.refreshHeader]; //刷新没有下啦动画
}

- (void)headerRefreshingWhenViewDidAppear:(BOOL)animated
{
   // [self beginHeaderRefreshing];刷新有下拉动画
//    [self refreshHeaderDidRefresh:self.refreshHeader]; //刷新没有下啦动画
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshHeaderDidRefresh:(MJRefreshHeader *)refreshHeader {
    
}

- (void)refreshFooterDidRefresh:(MJRefreshFooter *)refreshFooter
{
    
}

# pragma mark - Refresh Header


- (MJRefreshHeader *)refreshHeader
{
    if (!_refreshHeader && self.didSupportHeaderRefreshing)
    {
        _refreshHeader = [self refreshHeaderOfTableView];
    }
    
    if (_tableView.mj_header != _refreshHeader)
    {
        _tableView.mj_header = _refreshHeader;
    }
    return _refreshHeader;
}

- (MJRefreshHeader *)refreshHeaderOfTableView
{
    __weak __typeof(self)weakSelf = self;

    return [MJRefreshGifHeader headerWithRefreshingBlock:^(){
        [weakSelf refreshHeaderDidRefresh:weakSelf.refreshHeader];
    }];
}

- (void)beginHeaderRefreshing
{
    [self.refreshHeader beginRefreshing];
}

- (void)endHeaderRefreshing
{
    [self.refreshHeader endRefreshing];
}


# pragma mark - Refresh Footer


- (MJRefreshFooter *)refreshFooter
{
    if (!_refreshFooter && self.didSupportFooterRefreshing){
        _refreshFooter = [self refreshFooterOfTableView];
    }
    if (_tableView.mj_footer != _refreshFooter) {
        _tableView.mj_footer = _refreshFooter;
    }
    return _refreshFooter;
}


- (MJRefreshFooter *)refreshFooterOfTableView
{
    __weak __typeof(self)weakSelf = self;
    
    return  [MJRefreshAutoFooter footerWithRefreshingBlock:^(){
        [weakSelf refreshFooterDidRefresh:weakSelf.refreshFooter];
    }];
    
}

- (void)beginFooterRefreshing
{
    [self.refreshFooter beginRefreshing];
}


- (void)endFooterRefreshing
{
    [self.refreshFooter endRefreshing];
}


- (void)setRefreshFooterStatus:(MSRefreshFooterStatus2)status
{
    if (status == MSRefreshFooterStatus2Idle) {
        self.refreshFooter.hidden = NO;
        [self.refreshFooter resetNoMoreData];
    }
    else if (status == MSRefreshFooterStatus2NoMoreData) {
        self.refreshFooter.hidden = NO;
        [self.refreshFooter endRefreshingWithNoMoreData];
    }
    else if (status == MSRefreshFooterStatus2Hidden) {
        [self.refreshFooter setHidden:YES];
    }
}

- (MSRefreshFooterStatus2)refreshFooterStatus
{
    if (_refreshFooter.hidden) {
        return MSRefreshFooterStatus2Hidden;
    }
    else if (_refreshFooter.state == MJRefreshStateNoMoreData) {
        return MSRefreshFooterStatus2NoMoreData;
    }
    
    return MSRefreshFooterStatus2Idle;
}

@end
