//
//  MMTableViewController.m
//  MMTableViewDemo
//
//  Created by Mac mini 2012 on 15-2-28.
//  Copyright (c) 2015年 Mac mini 2012. All rights reserved.
//

#import "MSStoryboardTableController.h"
#import "MSMutableDataSource.h"
#import "MSTableEmptyView.h"

const CGFloat kMMCellDefaultHeight = 44;

@interface MSStoryboardTableController (){
}

@end

@implementation MSStoryboardTableController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTableView];
    [self tableViewDidRegisterTableViewCell];
}


- (void)createTableView
{
    self.tableView.frame = self.view.bounds;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
}

- (void)tableViewDidRegisterTableViewCell
{
    // 子类实现
}

- (void)reloadPages:(MSMutableDataSource *)dataSource
{
    // empty view
    if (self.autoDisplayEmptyView && [self isEmptyDatasource:dataSource]) {
        [self.view addSubview:self.emptyView];
        self.emptyView.hidden = NO;
    }
    else{
        [self emptyView].hidden = YES;
    }
    
    // datasource
    if (self.dataSource != dataSource) {
        self.dataSource = dataSource;
        self.tableView.dataSource = dataSource;
    }
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    if ( [self isViewLoaded] && nil == self.view.window)
    {
        self.tableView = nil;
    }
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload
{
    self.tableView = nil;
    [super viewDidUnload];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [self.dataSource.items objectAtIndex:indexPath.section];
    if ([arr count]>indexPath.row) {
        id<MSCellModel> item = [arr objectAtIndex:indexPath.row];
        if (item.height) {
            return item.height;
        }
    }
    
    return kMMCellDefaultHeight;
}



# pragma mark - EmptyView

- (UIView *)emptyView
{
    if (_emptyView == nil) {
        _emptyView = [[MSTableEmptyView alloc] initWithFrame:self.view.bounds];
    }
    
    return _emptyView;
}

- (void)setEmptyView:(UIView *)emptyView
{
    _emptyView = emptyView;
}

- (BOOL)isEmptyDatasource
{
    return [self isEmptyDatasource:self.dataSource];
}


- (BOOL)isEmptyDatasource:(MSDataSource *)dataSource
{
    if (dataSource) {
        return [dataSource.items count] == 0 || [dataSource.sections count] == 0;
    }
    
    return YES;
}



@end
