//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChattingContent.h"

@class ChattingCollectionView;
@class ChattingMessageCell;
@interface ChattingCellAction : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) dispatch_block_t handler;

- (void)excute;

+ (instancetype)actionWithTitle:(NSString *)title handler:(dispatch_block_t)handler;

@end

@protocol ChattingCollectionViewDataSource <UICollectionViewDataSource>

- (ChattingContent *)collectionView:(ChattingCollectionView *)collectionView chattingContentAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol ChattingCollectionViewDelegate <UICollectionViewDelegate>

@optional

- (NSArray *)collectionView:(ChattingCollectionView *)collectionView menuItemsOnLongPressingBubbleViewInCell:(ChattingMessageCell *)cell;

- (void)collectionView:(ChattingCollectionView *)collectionView didPressFailedButtonOnCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ChattingCollectionView : UICollectionView

@property (nonatomic, assign) id <ChattingCollectionViewDelegate> delegate;
@property (nonatomic, assign) id <ChattingCollectionViewDataSource> dataSource;

- (NSIndexPath *)indexPathForDescendantOfView:(UIView *)descendantOfView;

@end
