//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingContentViewBuilder.h"
#import "ChattingTipLabel.h"
#import "TTLoochaStyledTextLabel.h"
#import "TTLoochaStyledText.h"
#import "PMAppInfo.h"
#import "PMTextInfo.h"
#import "TTLoochaStyledTextLabel.h"
//#import "PMAttachmentView.h"
#import "ChattingImageView.h"
#import "EMCommData.h"

NSString * const kChattingContentReuseIdentifier_ChattingTipLabel = @"ChattingTipLabel";
NSString * const kChattingContentReuseIdentifier_ChattingRichTipLabel = @"ChattingRichTipLabel";
NSString * const kChattingContentReuseIdentifier_TTLoochaStyledTextLabel = @"TTLoochaStyledTextLabel";
//NSString * const kChattingContentReuseIdentifier_PMAttachmentView = @"PMAttachmentView";
NSString * const kChattingContentReuseIdentifier_ChatDynamicEmojiView = @"ChatDynamicEmojiView";
NSString * const kChattingContentReuseIdentifier_ChatGroupNewMember = @"ChatGroupNewMemberView";
NSString * const kChattingContentReuseIdentifier_ChatGiveMoneyView = @"ChatGiveMoneyView";
NSString * const kChattingContentReuseIdentifier_AssitantInfo= @"AssitantInfo";
NSString * const kChattingContentReuseIdentifier_ChattingImageView = @"ChattingImageView";
// 需要与ChattingIncomingCell 和 ChattingOutgoingCell 的ei同步修改，此处加多少，ei就得减去多少
UIEdgeInsets const kChattingContent_TTLoochaStyledText_EdgeInsets = {.top = 8, .left = 8, .bottom = 8, .right = 8};

@interface ChattingContentViewBuilder ()<ChattingImageViewDelegate>
@end

@implementation ChattingContentViewBuilder

- (instancetype)initWithCellContext:(ChattingCellContext *)cellContext {
    self = [super init];
    if (self) {
        _cellContext = cellContext;
        [_cellContext registerClass:[ChattingTipLabel class] forViewWithReuseIdentifier:kChattingContentReuseIdentifier_ChattingTipLabel];
        [_cellContext registerClass:[TTLoochaStyledTextLabel class] forViewWithReuseIdentifier:kChattingContentReuseIdentifier_TTLoochaStyledTextLabel];
        [_cellContext registerClass:[ChattingImageView class] forViewWithReuseIdentifier:kChattingContentReuseIdentifier_ChattingImageView];
    }
    return self;
}

- (CGFloat)maxContentWidth {
    return _cellContext.maxWidth * 0.6;
}

- (ChattingCellDisplayAttribute *)displayAttributeOfChattingContent:(ChattingContent *)content {
    ChattingCellDisplayAttribute *attri = [[ChattingCellDisplayAttribute alloc] init];
    
    switch (content.contentType) {
        case ChattingContent_Tip:
        {
            attri.msgContentSize = [ChattingTipLabel viewSizeWithText:content.text maxWidth:_cellContext.maxWidth - 24];
        }
            break;
        case ChattingContent_Text:
        case ChattingContent_SpecialEmo:{
            NSArray *arr = content.data;
            UIEdgeInsets ei = kChattingContent_TTLoochaStyledText_EdgeInsets;
            CGSize sz = [TTLoochaStyledTextLabel viewSizeWithContent:content.text
                                                     constraintWidth:[self maxContentWidth] - ei.left - ei.right
                                                        withFontSize:TTStyledTextFont
                                                                URLs:YES
                                                        withMaxLines:0
                                                         isMePublish:NO
                                                         withGiftArr:arr];
            attri.msgContentSize = CGSizeMake(sz.width + ei.left + ei.right, sz.height + ei.top + ei.bottom);
        }
            break;
        case ChattingContent_Image:{
            attri.msgContentSize = [ChattingImageView viewSizeWithContent:content maxWidth:[self maxContentWidth]];
        }
            break;
        default:
            attri.msgContentSize = CGSizeMake(80, 60);
            break;
    }
    
    return attri;
}

- (UIView<ReusableViewProtocol> *)chattingContentViewOfChattingContent:(ChattingContent *)content {
    switch (content.contentType) {
        case ChattingContent_Tip:
            return [self tipLabelOfContent:content];
        case ChattingContent_Text:
        case ChattingContent_SpecialEmo:
            return [self textLabelOfContent:content];
        case ChattingContent_Image:
            return [self ImageViewOfContent:content];
        default:
            break;
    }
    return nil;
}

- (UIView<ReusableViewProtocol> *)tipLabelOfContent:(ChattingContent *)content {
    ChattingTipLabel *tipLabel = (ChattingTipLabel *)[_cellContext dequeueReusableViewWithIdentifier:kChattingContentReuseIdentifier_ChattingTipLabel];
    tipLabel.text = content.text;
    return tipLabel;
}

- (UIView<ReusableViewProtocol> *)textLabelOfContent:(ChattingContent *)content {
    TTLoochaStyledTextLabel *textLabel = (TTLoochaStyledTextLabel *)[_cellContext dequeueReusableViewWithIdentifier:kChattingContentReuseIdentifier_TTLoochaStyledTextLabel];
    textLabel.contentInset = kChattingContent_TTLoochaStyledText_EdgeInsets;
    textLabel.contentStr = content.text;
    NSArray *arr = content.data;
   textLabel.text = [TTLoochaStyledText textFromLoochaText:content.text lineBreaks:YES URLs:YES isMeIPusblish:NO withGiftArr:arr];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor blackColor];
    textLabel.font = [UIFont systemFontOfSize:TTStyledTextFont];
    return textLabel;
}

- (UIView<ReusableViewProtocol> *)ImageViewOfContent:(ChattingContent *)content {
    ChattingImageView *imageView = (ChattingImageView *)[_cellContext dequeueReusableViewWithIdentifier:kChattingContentReuseIdentifier_ChattingImageView];
    imageView.delegate = self;
    imageView.dataArray = content.data;
    imageView.m_n64GroupID = content.m_n64GroupID;
    imageView.content = content;
    [imageView reloadImageData];
    return imageView;
}

- (ChattingCellDisplayAttribute *)displayAttributeOfChattingContent:(ChattingContent *)content prevContent:(ChattingContent *)prevContent {
    ChattingCellDisplayAttribute *attri = [self displayAttributeOfChattingContent:content];
    NSInteger prevUserID = prevContent.sender.m_nPlatformID;
    NSInteger thisUserID = content.sender.m_nPlatformID;
    NSTimeInterval deltTime = (content.createTime - prevContent.createTime)/1000;
    NSTimeInterval maxDelt = 61;
    if (prevUserID == thisUserID ) {
        maxDelt =61;
    }
    attri.showCellTopView = (deltTime > maxDelt);
    return attri;
}

- (ChattingContentSource)sourceOfChattingContent:(ChattingContent *)content {
    if (content.sender) {
        if (content.sender.m_n64AccountID == [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID) {
            return ChattingContentSource_Outgoing;
        }
        else {
            return ChattingContentSource_Incoming;
        }
    }
    return ChattingContentSource_System;
}

- (UIView<ReusableViewProtocol> *)chattingBottomContentViewOfChattingContent:(ChattingContent *)content {
    if (content.contentType == ChattingContent_Text){
        return [self textLabelOfContent:content];
    }else{
        return nil;
    }
}

- (void)scanImageEvent:(ChattingImageView *)view imagdata:(UIImage *)image{
    if ([self.cellContext.delegate respondsToSelector:@selector(chattingCellContext:didSelectChattingContentView:forContentType:)]) {
        [self.cellContext.delegate chattingCellContext:self.cellContext didSelectChattingContentView:view forContentType:ChattingContent_Image];
    }
}

@end
