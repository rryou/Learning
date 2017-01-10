///
//  HandleDataModel.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSArray(Extends)
/**
 *  将数组按照 count 个 分组 放入到新的 数组中
 *
 *  @param count 每一个数组的个数
 *
 *  @return 数组里放的是数组
 */
- (NSMutableArray *)divideGroupWithPreCount:(NSUInteger)count;

@end
