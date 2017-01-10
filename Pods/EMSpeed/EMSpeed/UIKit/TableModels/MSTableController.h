//
//  EMSTableViewController.h
//  EMStock
//
//  Created by Mac mini 2012 on 15-2-13.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "MSViewController.h"

@class MSMutableDataSource;
@class MSDataSource;

/**
 *  tableController 列表
 */
@interface MSTableController : MSViewController <UITableViewDelegate>{

    UITableView *_tableView;
    UIView *_emptyView;
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
 *  空视图, 默认会有一个空视图
 */
@property (nonatomic, strong) UIView *emptyView;

/**
 *  是否自动显示空视图
 */
@property (nonatomic, assign) BOOL autoDisplayEmptyView;

/**
 *  重新加载列表界面
 *
 *  @param dataSource 数据源
 */
- (void)reloadPages:(MSMutableDataSource *)dataSource;


/**
 *  注册tableview cell
 *  子类实现
 */
- (void)tableViewDidRegisterTableViewCell; // 子类实现


@end



