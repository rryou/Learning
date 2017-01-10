//
//  InputBox.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 7/1/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomResponderTextView.h"
typedef enum {
    InputBoxCapability_Text       = 0,
    InputBoxCapability_Emoji      = 1 << 0,
    InputBoxCapability_Attachment = 1 << 1,
    InputBoxCapability_Normal = InputBoxCapability_Text | InputBoxCapability_Emoji | InputBoxCapability_Attachment
} InputBoxCapability;
@class InputBox;
@protocol InputBoxDelegate <NSObject>

- (void)inputTextViewContentHeightChanged:(CGFloat)contentHeight;

- (BOOL)inputBox:(InputBox *)boxView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)inputBoxDidEndEditing:(InputBox *)boxView;
- (bool)inputBoxShouldBeginEditing:(InputBox *)boxView;
@end

@interface InputBox : UIImageView

@property (nonatomic, readonly) CustomResponderTextView *textView;
//@property (nonatomic, readonly) UIView *textBottonView;
@property (nonatomic, readonly) UIButton *emojiBtn;
@property (nonatomic, readonly) UIButton *textModeBtn; // 与emojiBtn相互切换
@property (nonatomic, readonly) UIButton *optionBtn;
@property (nonatomic, readonly) UIButton *sendBtn;
@property (nonatomic, retain) NSString *msgPrefix;
@property (nonatomic, assign) id<InputBoxDelegate> delegate;
@property (nonatomic, readwrite, assign) NSString *textContent;

- (instancetype)initWithFrame:(CGRect)frame capabilities:(InputBoxCapability)capabilities;

- (void)updateAttachmentCount:(NSInteger)attachmentCount;

- (void)beginEditing;

- (BOOL)editing;

- (void)appendEmoji:(NSString *)emojiName strValue:(NSString *)strValue;

- (NSString *)getContentStr;

- (void)appendText:(NSString *)text;

- (void)reset;

// 目前仅支持 InputBoxCapability_Attachment
- (void)showNewTip:(BOOL)show forCapabilities:(InputBoxCapability)capabilities;

+ (CGFloat)viewHeight;

+ (CGFloat)viewHeightWithTextViewContentHeight:(CGFloat)contentHeight;

+ (CGFloat)maxViewHeight;

@end

@interface EmojiTextAttachment : NSTextAttachment
@property(strong, nonatomic) NSString *emojiTag;
@end




