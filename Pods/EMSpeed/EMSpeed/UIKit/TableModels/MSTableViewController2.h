//
//  MSTableViewController2.h
//  Pods
//
//  Created by flora on 16/6/7.
//
//

#import <UIKit/UIKit.h>
#import "MSViewController.h"

@class MSMutableDataSource;
@class MSDataSource;

@interface MSTableViewController2 : MSViewController <UITableViewDelegate>{
    
    UITableView *_tableView;
    UIView *_statusView;
}

/**
 *  tableview
 */
@property (nonatomic, strong) UITableView *tableView;


/**
 *  数据源
 */
@property (nonatomic, strong) MSMutableDataSource *dataSource;

/**
 *  空列表时显示一个状态图
 */
@property (nonatomic, strong) UIView * statusView;

/**
 *  重新加载列表界面
 *
 *  @param dataSource 数据源
 */
- (void)reloadPages:(MSMutableDataSource *)dataSource;

/**
 *  数据加载完成的时候，是否更新状态背景图
 * default is yes
 *  @return
 */
- (BOOL)shouldUpdateStatusViewWhenDataSourceLoaded;

/**
 *  根据当前数据管理statusView的显示状态
 */
- (void)updateStatusView;

@end
