//
//  MSRefreshTableViewController2.h
//  Pods
//
//  Created by flora on 16/6/12.
//
//

#import "MSTableViewController2.h"

#import "MJRefresh.h"


@protocol MSRefreshProtocol2 <NSObject>

@required

// 触发下拉刷新操作(动画)调用
- (void)refreshHeaderDidRefresh:(MJRefreshHeader *)refreshHeader;

// 底部上拉刷新触发时调用
- (void)refreshFooterDidRefresh:(MJRefreshFooter *)refreshFooter;

/**
 *  viewwillappear\viewdidappear 的时候调用，供之类调用刷新数据
 *  只实现一个方法，防止重复首发包
 *  @param animated animated description
 */
- (void)headerRefreshingWhenViewWillAppear:(BOOL)animated;
- (void)headerRefreshingWhenViewDidAppear:(BOOL)animated;

// 自定义refresh header & footer
- (MJRefreshHeader *)refreshHeaderOfTableView;
- (MJRefreshFooter *)refreshFooterOfTableView;

@end

typedef enum : NSUInteger {
    MSRefreshFooterStatus2Idle,        // 闲置状态, 等待下次上拉
    MSRefreshFooterStatus2NoMoreData,  // 没有更多
    MSRefreshFooterStatus2Hidden,      // 隐藏
    
} MSRefreshFooterStatus2;


@interface MSRefreshTableViewController2 : MSTableViewController2 <MSRefreshProtocol2>
{
    
}

@property (nonatomic, assign) BOOL didSupportHeaderRefreshing;// default is yes
@property (nonatomic, assign) BOOL didSupportFooterRefreshing;//default is no

@property (nonatomic, strong, readonly) MJRefreshHeader *refreshHeader;
@property (nonatomic, strong, readonly) MJRefreshFooter *refreshFooter;

- (void)beginHeaderRefreshing; // 手动调用 下拉刷新动作 有动画
- (void)endHeaderRefreshing; // 结束刷新状态

- (void)beginFooterRefreshing; // 上拉 有动画
- (void)endFooterRefreshing;

- (void)setRefreshFooterStatus:(MSRefreshFooterStatus2)status; // 设置footer状态
- (MSRefreshFooterStatus2)refreshFooterStatus;


@end
