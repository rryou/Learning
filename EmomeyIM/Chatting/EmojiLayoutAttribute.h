//
//  DMEmo.h
//  EmojProj
//
//  Created by ding xiuwei on 15/6/16.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ItemShowTypeFixCount  =  1 ,       //每页 固定个数
    ItemShowTypeFlow      =  1 << 1,   //每页 流式 排满
} ItemShowType;

@interface EmojiLayoutAttribute : NSObject

@property(nonatomic,assign)BOOL isAction;
@property(nonatomic,assign)ItemShowType type;
@property(nonatomic,assign)NSInteger  itemW;
@property(nonatomic,assign)NSInteger  itemH;

@property(nonatomic,assign)NSInteger  pageCountColum; //每一页 有多少列
@property(nonatomic,assign)NSInteger  pageCountRow;   //每一页 有多少行
@property(nonatomic,assign)NSInteger  pageCount;      //每一页 有多少个

@property(nonatomic,assign)NSInteger  pageNum;        //在每个type中 是第几页
@property(nonatomic,assign)NSInteger  pageSunNum;     //在每个type中 总共有几页

@property(nonatomic,assign)NSInteger  typeSortNum;    //第几个type 为下面的tabbar使用

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) UIEdgeInsets sectionInsets;

-(NSInteger)calcluatePageCountWithMaxSize:(CGSize)maxSz;

@end
