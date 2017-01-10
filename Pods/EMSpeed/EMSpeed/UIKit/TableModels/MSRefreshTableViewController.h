//
//  MSRefreshTableViewController.h
//  TTTT
//
//  Created by Mac mini 2012 on 15-3-2.
//  Copyright (c) 2015年 Mac mini 2012. All rights reserved.
//

#import "MSStoryboardTableController.h"
#import "MJRefresh.h"

/**
 *  同MSRefreshTableController, 主要用于storyboard
 */

@interface MSRefreshTableViewController : MSStoryboardTableController {
    BOOL _isBackFromPush;
    
    MJRefreshHeader *_refreshHeader;
    MJRefreshFooter *_refreshFooter;
}


/**
 *  初始化时设置, 默认YES
 */
@property (nonatomic, assign) BOOL enableRefreshHeader;


/**
 *  初始化时设置, 默认YES
 */
@property (nonatomic, assign) BOOL enableRefreshFooter;


/**
 *  当viewDidAppear显示时, 是否要刷新, 默认是YES
 */
@property (nonatomic, assign) BOOL refreshWhenFirstViewDidAppear;


/**
 *  从其他界面返回viewDidAppear时, 是否需要刷新, 默认是NO
 */
@property (nonatomic, assign) BOOL refreshWhenPushBack;


/**
 *  下拉刷新触发时调用, 子类实现即可
 */
- (void)headerRefreshing;


/**
 *  上拉刷新触发时调用, 子类实现即可
 */
- (void)footerRefreshing;


@end

