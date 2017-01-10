//
//  EMMTableViewController.m
//  EMSpeed
//
//  Created by Mac mini 2012 on 15-2-13.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import "MSTableController.h"
#import "MSMutableDataSource.h"
#import "MSTableEmptyView.h"



@implementation MSTableController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
        }
        
        self.autoDisplayEmptyView = YES;
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    if (self.tableView) {
//        [self tableViewDidRegisterTableViewCell];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UITableView *)tableView
{
    if (_tableView==nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.frame = self.view.bounds;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
    }
    
    return _tableView;
}

- (void)tableViewDidRegisterTableViewCell
{
    // 子类实现
    NSLog(@"子类未实现 tableViewDidRegisterTableViewCell");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)reloadPages:(MSMutableDataSource *)dataSource
{
    // empty view
    if (self.autoDisplayEmptyView && ([dataSource isEmpty] || dataSource == nil))
    {
        [self.view addSubview:self.emptyView];
        self.emptyView.hidden = NO;
    }
    else{
        [_emptyView removeFromSuperview];
        _emptyView.hidden = YES;
    }
    
    // datasource
    if (self.dataSource != dataSource) {
        self.dataSource = dataSource;
        _tableView.dataSource = dataSource;
    }
    [_tableView reloadData];
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


- (void)viewDidUnload
{
    _tableView = nil;
    [super viewDidUnload];
}


#pragma mark UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [self.dataSource.items objectAtIndex:indexPath.section];
    CGFloat height = tableView.rowHeight;
    
    id<MSCellModel> item = [items objectAtIndex:indexPath.row];
    height = item.height;
    
    if (height == 0) {
        if ([item respondsToSelector:@selector(calculateHeight)]) {
            height = [item calculateHeight];
        }
    }
    
    return height;
}


# pragma mark - EmptyView 

- (UIView *)emptyView
{
    if (_emptyView == nil) {
        _emptyView = [[MSTableEmptyView alloc] initWithFrame:_tableView.bounds];
    }
    
    return _emptyView;
}

- (void)setEmptyView:(UIView *)emptyView
{
    _emptyView = emptyView;
}


- (BOOL)isEmptyDatasource
{
    return [self.dataSource isEmpty];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _emptyView.frame = _tableView.bounds;
    [_emptyView setNeedsLayout];
}

@end
