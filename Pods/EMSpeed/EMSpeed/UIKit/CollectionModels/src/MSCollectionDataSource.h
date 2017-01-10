//
//  MSCollectionDataSource.h
//  EMSpeed
//
//  Created by Mac mini 2012 on 15-2-13.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCollectionCellModel.h"
#import "MSCollectionCellUpdating.h"

/**
 *  
 controller里面delegate回调, 这个记得拷贝一下哦~不然尺寸会不对的
 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
 {
    id<MSCollectionCellModel> item = [_ds itemAtIndexPath:indexPath];
    return item.layoutSize;
 }
 */


/**
 *  tableview的数据
 */

@interface MSCollectionDataSource : NSObject <UICollectionViewDataSource> {
@protected
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
 *  @param aItems    id<MSCollectionCellModel>数组
 *  @param aSections section数组
 *
 *  @return MSCollectionDataSource
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
 *  @return 该section下的items数组
 */
- (NSArray *)itemsAtSection:(NSUInteger)section;
- (NSArray *)itemsAtSectionWithTitle:(NSString *)title;


- (NSIndexPath *)indexPathOfItem:(id<MSCollectionCellModel>)cellModel;


// 取某个EMBaseItem
- (id <MSCollectionCellModel>)itemAtIndexPath:(NSIndexPath *)indexPath;
- (id <MSCollectionCellModel>)itemAtIndex:(NSUInteger)index;


@end
