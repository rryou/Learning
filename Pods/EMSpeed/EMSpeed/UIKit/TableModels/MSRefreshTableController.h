//
//  MSRefreshTableController.h
//  MMTableViewDemo
//
//  Created by Mac mini 2012 on 15-2-27.
//  Copyright (c) 2015年 Mac mini 2012. All rights reserved.
//

#import "MSTableController.h"
#import <MJRefresh/MJRefresh.h>

@protocol MSRefreshProtocol <NSObject>

@required
// 触发下拉刷新操作(动画)调用
- (void)refreshHeaderDidRefresh:(MJRefreshHeader *)refreshHeader;

@optional
// 下拉刷新(动画) 在view will/did appear时候是否需要触发, animated是否需要动画
- (BOOL)willRefreshHeaderWhenViewWillAppear:(BOOL *)animated;
- (BOOL)willRefreshHeaderWhenViewDidAppear:(BOOL *)animated;

// 底部上拉刷新触发时调用
- (void)refreshFooterDidRefresh:(MJRefreshFooter *)refreshFooter;

// 自定义refresh header & footer
- (MJRefreshHeader *)refreshHeaderOfTableView;
- (MJRefreshFooter *)refreshFooterOfTableView;

@end


typedef enum : NSUInteger {
    MSRefreshFooterStatusNoInit,      // 未初始化
    MSRefreshFooterStatusIdle,        // 闲置状态, 等待下次上拉
    MSRefreshFooterStatusNoMoreData,  // 没有更多
    MSRefreshFooterStatusHidden,      // 隐藏
    
} MSRefreshFooterStatus;


@interface MSRefreshTableController : MSTableController <MSRefreshProtocol>
{
    
}

@property (nonatomic, strong, readonly) MJRefreshHeader *refreshHeader;
@property (nonatomic, strong, readonly) MJRefreshFooter *refreshFooter;

- (void)beginHeaderRefreshing; // 手动调用 下拉刷新动作
- (void)beginFooterRefreshing; // 上拉

- (void)endHeaderRefreshing; // 结束刷新状态
- (void)endFooterRefreshing;

- (void)setRefreshFooterStatus:(MSRefreshFooterStatus)status; // 设置footer状态
- (MSRefreshFooterStatus)refreshFooterStatus;


// TODO 这里的过期提示此版本注释掉了 等后面重新设计好再开启
// @Ryan
// 兼容老版本
@property (nonatomic, assign) BOOL enableRefreshHeader; //DEPRECATED_ATTRIBUTE;
@property (nonatomic, assign) BOOL enableRefreshFooter; //DEPRECATED_ATTRIBUTE;
@property (nonatomic, assign) BOOL refreshWhenFirstViewDidAppear; //DEPRECATED_ATTRIBUTE;
@property (nonatomic, assign) BOOL refreshWhenPushBack; //DEPRECATED_ATTRIBUTE;


- (void)headerRefreshing; //DEPRECATED_ATTRIBUTE;
- (void)footerRefreshing; //DEPRECATED_ATTRIBUTE;

@end
