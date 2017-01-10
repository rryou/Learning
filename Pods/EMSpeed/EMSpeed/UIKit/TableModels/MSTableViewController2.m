//
//  MSTableViewController2.m
//  Pods
//
//  Created by flora on 16/6/7.
//
//

#import "MSTableViewController2.h"
#import "MSMutableDataSource.h"
#import "MSTableEmptyView.h"

@implementation MSTableViewController2
@synthesize statusView = _statusView;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
        }
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    [self loadTableView];
}

- (void)loadTableView
{
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.frame = self.view.bounds;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    if ( [self isViewLoaded] && nil == self.view.window)
    {
        _tableView = nil;
        self.view = nil;
    }
    [super didReceiveMemoryWarning];
}

- (void)reloadPages:(MSMutableDataSource *)dataSource
{
    // datasource
    if (self.dataSource != dataSource) {
        self.dataSource = dataSource;
        _tableView.dataSource = dataSource;
    }
    [_tableView reloadData];
    
    if ([self shouldUpdateStatusViewWhenDataSourceLoaded])
    {
        [self updateStatusView];
    }
}

- (BOOL)shouldUpdateStatusViewWhenDataSourceLoaded
{
    return YES;
}

- (void)updateStatusView
{
    if ([self.dataSource isEmpty] || self.dataSource == nil)
    {
        if (_statusView == nil) {
            _statusView = [[MSTableEmptyView alloc] initWithFrame:_tableView.bounds];
            _statusView.frame = _tableView.bounds;
        }
        [self.view addSubview:self.statusView];
        self.statusView.hidden = NO;
    }
    else
    {
        [_statusView removeFromSuperview];
        _statusView.hidden = YES;
    }
}

#pragma mark UITableView delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MSCellModel> cellModel = [self.dataSource itemAtIndexPath:indexPath];

    CGFloat height = [MSCellFactory tableView:tableView heightForRowAtIndexPath:indexPath cellModel:cellModel];
    
    return height;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _statusView.frame = _tableView.bounds;
}

@end
