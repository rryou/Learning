//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "ChattingContent.h"
#import "ChattingCollectionViewCell.h"
#import "ChattingCellContext.h"

extern NSString * const kChattingContentReuseIdentifier_ChattingTipLabel;
extern NSString * const kChattingContentReuseIdentifier_ChattingRichTipLabel;
extern NSString * const kChattingContentReuseIdentifier_TTLoochaStyledTextLabel;
extern NSString * const kChattingContentReuseIdentifier_PMAttachmentView;
extern NSString * const kChattingContentReuseIdentifier_ChatDynamicEmojiView;
// 为了使单行文本显示美观，需要对tt控件的内容缩进
extern UIEdgeInsets const kChattingContent_TTLoochaStyledText_EdgeInsets;

@protocol ChattingContentViewBuilder <NSObject>

- (ChattingCellDisplayAttribute *)displayAttributeOfChattingContent:(ChattingContent *)content prevContent:(ChattingContent *)prevContent;
- (UIView<ReusableViewProtocol> *)chattingContentViewOfChattingContent:(ChattingContent *)content;
- (UIView<ReusableViewProtocol> *)chattingContentViewOfChattingContent:(ChattingContent *)content
                                                                 index:(NSInteger)index;
- (UIView<ReusableViewProtocol> *)chattingBottomContentViewOfChattingContent:(ChattingContent *)content;
- (ChattingContentSource)sourceOfChattingContent:(ChattingContent *)content;
@end

@interface ChattingContentViewBuilder : NSObject <ChattingContentViewBuilder>
@property (nonatomic, readonly) ChattingCellContext *cellContext;
- (instancetype)initWithCellContext:(ChattingCellContext *)cellContext;
- (CGFloat)maxContentWidth;
- (ChattingCellDisplayAttribute *)displayAttributeOfChattingContent:(ChattingContent *)content;
//10 5
//@property (nonatomic, assign) NSTimeInterval
- (ChattingCellDisplayAttribute *)displayAttributeOfChattingContent:(ChattingContent *)content prevContent:(ChattingContent *)prevContent;
@end
