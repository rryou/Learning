//
//  MSDataSource.h
//  EMSpeed
//
//  Created by Mac mini 2012 on 15-2-13.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCellFactory.h"

/**
 *  tableview的数据
 */

@interface MSDataSource : NSObject<UITableViewDataSource> {
    
    NSMutableArray *_sections;
    NSMutableArray *_items;
    
}

/**
 *  section 的数组，每个section是NSString
 */
@property (nonatomic, strong, readonly) NSArray *sections;


/**
 *  items 的数组, 每个item都是id<CellModel>的NSArray
 */
@property (nonatomic, strong, readonly) NSArray *items;


/**
 *  初始化
 *
 *  @param aItems    id<MSCellModel>数组
 *  @param aSections section数组
 *
 *  @return MSDataSource
 */
- (instancetype)initWithItems:(NSArray *)aItems sections:(NSArray *)aSections;


/**
 *  取section标题
 *
 *  @param section section的下标
 *
 *  @return section标题
 */
- (NSString *)titleAtSection:(NSUInteger)section;


/**
 *  根据section的标题取下标, 如果重复的返回第一个匹配的
 *
 *  @param title 标题
 *
 *  @return section的下标
 */
- (NSUInteger)sectionIndexWithTitle:(NSString *)title;


/**
 *  取section下的items
 *
 *  @param section section的下标
 *
 *  @return section下面的items
 */
- (NSArray *)itemsAtSection:(NSUInteger)section;


/**
 *  取某个title下面的items
 *
 *  @param title section的title名称
 *
 *  @return 某个section的title下面的items
 */
- (NSArray *)itemsAtSectionWithTitle:(NSString *)title;


/**
 *  根据indexPath取某个item
 *
 *  @param indexPath 下标
 *
 *  @return 某个实现MSCellModel 协议的item
 */
- (id <MSCellModel>)itemAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  根据index取某个item, section下标默认为0
 *
 *  @param indexPath 下标
 *
 *  @return 某个实现MSCellModel 协议的item
 */
- (id <MSCellModel>)itemAtIndex:(NSUInteger)index;


/**
 *  某个section下面items的个数
 *
 *  @param section section下标
 *
 *  @return items个数
 */
- (NSUInteger)numberOfItemsAtSection:(NSUInteger)section;


- (NSIndexPath *)indexPathOfItem:(id<MSCellModel>)cellModel;

/**
 *  是否空的数据
 *
 *  @return 是否为空数据
 */
- (BOOL)isEmpty;

@end


@interface MSDataSource(creation)

- (instancetype)initWithDatasource:(MSDataSource *)datasource;

@end
