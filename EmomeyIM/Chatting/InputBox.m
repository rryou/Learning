//
//  InputBox.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 7/1/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import "InputBox.h"
#import <EMSpeed/MSUIKitCore.h>
#import "SSTextView.h"
#import "UserInfo.h"
#define kInputBoxHeight 44
#define kItemHeight     30
#define kMarginLeft     6
#define kMarginRight    4
#define kSendWidth      44
#define kViewGap        5
#define kCountWidth     10
#define kInputBoxMaxHeight  180
//(kInputBoxHeight - kItemHeight + kItemHeight*2)
#define kNewTipWidth    8

@implementation EmojiTextAttachment

@end

@interface InputBox ()<UITextViewDelegate>
{
    UIButton *_countBtn;
    CustomResponderTextView *_textView;
    BOOL _firstLoad;
    UIView *_optionNewTipView;
}
//@property (nonatomic, strong) NSMutableString *contentStr;
//@property (nonatomic, strong) NSMutableArray *inputtextValue;
@end

@implementation InputBox

- (UIView *)optionNewTipView{
    if (_optionNewTipView == nil) {
        _optionNewTipView = [[UIView alloc] initWithFrame:CGRectMake(kItemHeight - kNewTipWidth/2 - 4, -kNewTipWidth/2 + 4, kNewTipWidth, kNewTipWidth)];
        _optionNewTipView.backgroundColor =RGB(243, 00, 18);
        //RCColorWithValue(0xe60012);
        _optionNewTipView.clipsToBounds = YES;
        _optionNewTipView.layer.cornerRadius = kNewTipWidth/2;
        _optionNewTipView.userInteractionEnabled = NO;
        _optionNewTipView.hidden = YES;
        [_optionBtn addSubview:_optionNewTipView];
    }
    return _optionNewTipView;
}

- (void)dealloc{
    [_textView removeObserver:self forKeyPath:@"contentSize"];
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame capabilities:InputBoxCapability_Normal];
}

- (instancetype)initWithFrame:(CGRect)frame capabilities:(InputBoxCapability)capabilities{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.image = [[UIImage imageNamed:@"inputbox_bar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 3, 0, 3)];
        
        const CGFloat y = (kInputBoxHeight - kItemHeight)/2;
        CGFloat x = kMarginLeft;
        CGFloat right = frame.size.width - kMarginRight;
        
        if (capabilities & InputBoxCapability_Emoji) {
            _emojiBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, kItemHeight, kItemHeight)];
            [self addSubview:_emojiBtn];
            [self configBtn:_emojiBtn imageName:@"inputbox_emoji" touchImageName:@"inputbox_emoji_touch"];
            
            _textModeBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, kItemHeight, kItemHeight)];
            [self addSubview:_textModeBtn];
            [self configBtn:_textModeBtn imageName:@"inputbox_textMode" touchImageName:@"inputbox_textMode_touch"];
            _textModeBtn.hidden = YES;
            
            x += kItemHeight + kViewGap;
        }
        
        if (capabilities & InputBoxCapability_Attachment) {
            _optionBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, kItemHeight, kItemHeight)];
            [self addSubview:_optionBtn];
            [self configBtn:_optionBtn imageName:@"AddMore" touchImageName:@"AddMoreSelected"];
            x += kItemHeight + kViewGap;
        }
        
        _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(right - kSendWidth, y, kSendWidth, kItemHeight)];
        [self addSubview:_sendBtn];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _sendBtn.backgroundColor =RGB(200, 200, 200);
        _sendBtn.layer.cornerRadius = 2;
        right -= kSendWidth + kViewGap;
        
        _textView = [[CustomResponderTextView alloc] initWithFrame:CGRectMake(x, y, right - x, kItemHeight)];
        [self addSubview:_textView];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _textView.layer.cornerRadius = 2;
        _textView.layer.borderWidth = 0.5;
        CGColorRef lineColor = RGB(240,250,230).CGColor;
       _textView.layer.borderColor = lineColor;
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.backgroundColor = [UIColor clearColor];
        
        _countBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kCountWidth, kCountWidth)];
        [self addSubview:_countBtn];
        _countBtn.center = CGPointMake(CGRectGetMaxX(_optionBtn.frame) - 4, y + 4);
        _countBtn.backgroundColor = RGB(243,89, 48);
        
        _countBtn.layer.cornerRadius = kCountWidth/2;
        _countBtn.clipsToBounds = YES;
        _countBtn.userInteractionEnabled = NO;
        _countBtn.titleLabel.font = [UIFont systemFontOfSize:8];
        _countBtn.hidden = YES;
        
        [_textView addObserver:self
                    forKeyPath:@"contentSize"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];
    }
    return self;
}

- (void)configBtn:(UIButton *)btn imageName:(NSString *)imageName touchImageName:(NSString *)touchImageName{
    [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:touchImageName] forState:UIControlStateHighlighted];
}

- (void)updateAttachmentCount:(NSInteger)attachmentCount{
    if (attachmentCount == 0) {
        _countBtn.hidden = YES;
    }else {
        _countBtn.hidden = NO;
        [_countBtn setTitle:[NSString stringWithFormat:@"%d", (int)attachmentCount] forState:UIControlStateNormal];
    }
}

- (void)beginEditing{
    [_textView becomeFirstResponder];
}

- (void)appendEmoji:(NSString *)emojiName strValue:(NSString *)strValue{
    EmojiTextAttachment *attach = [[EmojiTextAttachment alloc] init];
    attach.image = [UIImage imageNamed:emojiName];
    attach.bounds = CGRectMake(0, 0, 20, 20);
    attach.emojiTag = strValue;
    NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attach];
    NSMutableAttributedString *newattString = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    NSRange newRange = self.textView.selectedRange;
    newRange = NSMakeRange(newRange.location,strValue.length );
    [newattString beginEditing];
    [newattString appendAttributedString:attachString];
    [newattString endEditing];
    _textView.attributedText = newattString;
    [_textView scrollRangeToVisible:NSMakeRange([newattString length], 0)];
}

- (void)appendText:(NSString *)text{
    if (text == nil) {
        return;
    }
    NSMutableAttributedString *attachString = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    [attachString appendAttributedString:[[NSAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:text]]];
    _textView.attributedText = attachString;
    [_textView scrollRangeToVisible:NSMakeRange([attachString length], 0)];
}

- (void)reset
{
    _textView.text = nil;
     _sendBtn.backgroundColor =RGB(200, 200, 200);
    [self updateAttachmentCount:0];
}

- (void)showNewTip:(BOOL)show forCapabilities:(InputBoxCapability)capabilities
{
    if (capabilities & InputBoxCapability_Attachment) {
        if (show) {
            self.optionNewTipView.hidden = !show;
        }
        else {
            _optionNewTipView.hidden = !show;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
        [self.delegate inputTextViewContentHeightChanged:newContentSize.height];
    }
}

- (NSString *)getContentStr{
    NSMutableAttributedString *tempStr =[[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
    NSMutableString *postStr  =[NSMutableString stringWithString:tempStr.string];
    [tempStr enumerateAttributesInRange:NSMakeRange(0, tempStr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        EmojiTextAttachment *textAtt = attrs[NSAttachmentAttributeName];
        if (textAtt) {
            NSString *emojiValue = textAtt.emojiTag;
            [postStr replaceCharactersInRange:range withString:[NSString stringWithFormat:@"[1,%@]",emojiValue]];
        }else{
            [tempStr.string substringWithRange:range];
           [postStr replaceCharactersInRange:range withString:[NSString stringWithFormat:@"[0,%@]",  [tempStr.string substringWithRange:range]]];
        }
    }];
   return postStr;
}

- (NSString *)textContent{
    NSString *tempstr ;
    if (_textView.attributedText) {
       tempstr = _textView.attributedText.string;
    }
    return tempstr;
}

- (void)setTextContent:(NSString *)textContent {
    _textView.text = textContent;
}

+ (CGFloat)viewHeight{
    return kInputBoxHeight;
}

+ (CGFloat)viewHeightWithTextViewContentHeight:(CGFloat)contentHeight{
    if (contentHeight < kItemHeight) {
        return kInputBoxHeight;
    }
    CGFloat height = kInputBoxHeight - kItemHeight + contentHeight;
    if (height > kInputBoxMaxHeight) {
        height = kInputBoxMaxHeight;
    }
    return height;
}

+ (CGFloat)maxViewHeight{
    return kInputBoxMaxHeight;
}

- (BOOL)editing{
    return [_textView isFirstResponder];
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if ([self.delegate respondsToSelector:@selector(inputBox: shouldChangeTextInRange: replacementText:)]){
//        [self.delegate inputBox:self shouldChangeTextInRange:range replacementText:text];
//    }
//    return  YES;
//}
//
//- (bool)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange{
//    
//    
//    return YES;
//}
//
//- (bool)textViewShouldEndEditing:(UITextView *)textView{
//    if ([self.delegate respondsToSelector:@selector(inputBoxShouldBeginEditing:)]){
//       return  [self.delegate inputBoxShouldBeginEditing:self];
//    }
//    return YES;
//}

//- (void)textViewDidEndEditing:(UITextView *)textView{
//    if ([self.delegate respondsToSelector:@selector(inputBoxDidEndEditing:)]){
//        [self.delegate inputBoxDidEndEditing:self];
//    }
//    _textBottonView.backgroundColor =  RGB(197, 213, 239);
//}

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    _textBottonView.backgroundColor= RGB(144, 173, 224);
//    return YES;
//}
@end

