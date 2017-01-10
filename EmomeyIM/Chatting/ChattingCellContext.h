//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CustomResponderTextView.h"
#import "ChattingCollectionView.h"

@protocol ReusableViewProtocol <NSObject>

@property (nonatomic, strong) NSString *reuseIdentifier;

- (void)prepareForReuse;

@end

@class ChattingCellContext;
@class ChattingMessageCell;

@protocol ChattingCellContextDelegate <NSObject>

@optional

- (CGSize)chattingCellContext:(ChattingCellContext *)context defaultSizeForViewWithIdentifier:(NSString *)identifier;

- (void)chattingCellContext:(ChattingCellContext *)context didSelectChattingContentView:(UIView *)chattingContentView forContentType:(ChattingContentType)contentType;
- (BOOL)chattingCellisAbleSupportChangeResponder;
@end

/**
 *  主要为ChattingCell提供上下文信息，同时提供内容重用机制，便于ChattingCell中各种不同风格的内容展示
 */
@interface ChattingCellContext : NSObject

@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, weak) id<ChattingCellContextDelegate> delegate;
@property (nonatomic, weak) ChattingCollectionView *chattingCollectionView;
@property (nonatomic, weak) CustomResponderTextView *customResponderTextView;
@property (nonatomic, assign) BOOL showIncomingUserName; // default : NO

- (void)registerClass:(Class)viewClass forViewWithReuseIdentifier:(NSString *)identifier;

- (void)enqueueReusableView:(UIView<ReusableViewProtocol> *)reusableView;

- (UIView<ReusableViewProtocol> *)dequeueReusableViewWithIdentifier:(NSString *)identifier;

- (void)willShowMenuInCell:(ChattingMessageCell *)cell;

- (void)willHideMenuInCell:(ChattingMessageCell *)cell;

@end
