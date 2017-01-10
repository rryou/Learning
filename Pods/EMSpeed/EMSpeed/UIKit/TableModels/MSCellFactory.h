//
//  MSCellModel.h
//  MMTableViewDemo
//
//  Created by Mac mini 2012 on 15-2-27.
//  Copyright (c) 2015年 Mac mini 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 *  cell的viewmodel, 一个cell对应一个cellModel
 */

@protocol MSCellModel <NSObject>


/**todo 待移除
 *  cell的高度
 */
@property (nonatomic, assign) CGFloat height;//NS_DEPRECATED


/**todo 待移除
 *  cellmodel对应的cell的类
 */
@property (nonatomic, strong) Class Class;//NS_DEPRECATED

/**
 *  cell的重用名
 */
@property (nonatomic, strong) NSString *reuseIdentify; //NS_DEPRECATED

/**
 *  cell是否通过class注册, 默认是NO, 建议使用Xib创建, 效率高, 且不用设置这个参数
 */
@property (nonatomic, assign) BOOL isRegisterByClass;//NS_DEPRECATED

@optional

/**todo 待移除
 *  计算cell的高度
 *
 *  @return 高度
 */

- (CGFloat)calculateHeight;//NS_DEPRECATED

/**
 *  处理成cell model
 *
 *  @param item 数据
 */
- (void)parseItem:(id)item;


/**
 *  cellmodel对应的cell的nib 对象
 */
@property (nonatomic, strong) UINib *cellNib; //优先级高于cellClass

/**
 *  cellmodel对应的cell的类
 */
@property (nonatomic, strong) Class cellClass;


@end

/**
 *  cell需要实现的一个 更新界面的接口
 */
@protocol MSCellUpdating

@required

/**
 *  更新cell的界面中的内容
 *
 *  @param cellModel cell中显示的数据
 */
- (void)update:(id<MSCellModel>)cellModel;

@optional
- (void)update:(id<MSCellModel>)cellModel indexPath:(NSIndexPath *)indexPath;
+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;


@end


@interface MSCellModel : NSObject <MSCellModel>

@end


@interface MSCellFactory : NSObject

/**
 *
 *
 *  @param tableView
 *  @param indexPath
 *  @param model
 *
 *  @return
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath cellModel:(MSCellModel *)model;

/**
 *
 *
 *  @param tableViewModel
 *  @param tableView
 *  @param indexPath
 *  @param object
 *
 *  @return
 */
+ (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withCellModel:(MSCellModel *)cellModel;

@end






