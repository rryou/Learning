//
//  EMMultiDataSource.h
//  EMStock
//
//  Created by Mac mini 2012 on 15-2-26.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCollectionDataSource.h"

@interface MSMutableCollectionDataSource : MSCollectionDataSource {
}

/**
 *  默认取数据的URL
 */
@property (nonatomic, copy) NSString *URL;

/**
 *  下拉刷新的url
 */
@property (nonatomic, copy) NSString *refreshURL;

/**
 *  上拉刷新的url
 */
@property (nonatomic, copy) NSString *nextPageURL;


/**
 *  添加一条新的section
 *
 *  @param section 标题
 *  @param items   列表内容数组
 */
- (void)addNewSection:(NSString *)section withItems:(NSArray *)items;


/**
 *  插入一条新的section
 *
 *  @param section      标题
 *  @param items        列表数据内容数组
 *  @param sectionIndex 插入的下标
 */
- (void)insertSection:(NSString *)section
                items:(NSArray *)items
       atSectionIndex:(NSUInteger)sectionIndex;


/**
 *  添加一条列表数据内容
 *
 *  @param item      列表数据内容
 *  @param indexPath 插入的下标
 */
- (void)insertItem:(id<MSCollectionCellModel>)item indexPath:(NSIndexPath *)indexPath;

/**
 *  删除一条列表数据内容
 *
 *  @param indexPath 插入的下标
 */
- (void)removeItem:(NSIndexPath *)indexPath;


/**
 *  删除一条section
 *
 *  @param section section
 */
- (void)removeSection:(NSUInteger)section;


/**
 *  将列表数据内容添加到某个已存在的section后面
 *
 *  @param items   列表数据内容
 *  @param section section的下标
 */
- (void)appendItems:(NSArray *)items atSection:(NSUInteger)section;


/**
 *  根据section标题, 将列表数据内容添加到某个已存在的section后面
 *
 *  @param items 列表数据内容
 *  @param title 标题
 */
- (void)appendItems:(NSArray *)items atSectionTitle:(NSString *)title;



@end
