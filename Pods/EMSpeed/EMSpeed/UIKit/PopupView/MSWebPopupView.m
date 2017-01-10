//
//  EMSocialViewController.m
//  Social
//
//  Created by Sam Chen on 13-4-16.
//  Copyright (c) 2013年 emoney. All rights reserved.
//

#import "MSWebPopupView.h"
#import <EMSpeed/MSContext.h>
#import <EMSpeed/MSUIKitCore.h>
#import <EMSpeed/UIImage+Utility.h>

const CGFloat kWebPopupAutoDismissSeconds   = 1.5f;
const CGFloat kWebPopupTitleYOffset         = 15.0f;
const CGFloat kWebPopupTitleHeight          = 25.0f;
const CGFloat kWebPopupContentOffset        = 30.0f;
const CGFloat kWebPopupBetweenLabelOffset   = 20.0f;
const CGFloat kWebPopupSingleButtonWidth    = 160.0f;
const CGFloat kWebPopupCoupleButtonWidth    = 107.0f;
const CGFloat kWebPopupButtonHeight         = 40.0f;
const CGFloat kWebPopupButtonBottomOffset   = 10.0f;



@implementation MSMaskBackgroundView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.popView) {
        UITouch *touch = [touches anyObject];
        
        CGRect frame = self.popView.frame;
        CGPoint point = [touch locationInView:self];
        
        if (!CGRectContainsPoint(frame, point)) {
            [self.popView dismiss];
        }
    }
}

@end



@interface MSWebPopupView ()
{
    float _fWebPopWidth;
    float _fWebPopHeight;
    float _fWebViewHeight;
}
@property (nonatomic, strong) UIScrollView *myScrollView;
@property (nonatomic, strong) UIWebView *contentWebView;
@property (nonatomic, strong) MSMaskBackgroundView *backImageView;

@end

@implementation MSWebPopupView


+ (CGFloat)webPopWidth
{
    return (MSScreenWidth() - 30.0f);
}

+ (CGFloat)webPopHeight
{
    return floor(MSScreenHeight() * 5 / 8);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
        contentText:(NSString *)content
    leftButtonTitle:(NSString *)leftTitle
          leftBlock:( ms_popupview_event_block_t)leftBlock
   rightButtonTitle:(NSString *)rigthTitle
         rightBlock:( ms_popupview_event_block_t)rightBlock
{
    if (self = [super init]) {
        _fWebPopWidth = MSScreenWidth() - 30.0f;
        _fWebPopHeight = floor(MSScreenHeight() * 5 / 8);
        
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = [UIColor whiteColor];
        UIFont* titleFont = [UIFont boldSystemFontOfSize:20.0f];
        CGSize aSize = sizeWithFont(title, titleFont);
        if(aSize.width > (_fWebPopWidth - 16))
        {
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kWebPopupTitleYOffset, _fWebPopWidth, kWebPopupTitleHeight * 2)];
            self.titleLabel.numberOfLines = 0;
        }
        else
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kWebPopupTitleYOffset, _fWebPopWidth, kWebPopupTitleHeight)];
        self.titleLabel.font = titleFont;
        self.titleLabel.textColor = RGB(0x51, 0x96, 0xef);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = title;
        [self addSubview:self.titleLabel];
        
        float fTitleHeight = CGRectGetMaxY(self.titleLabel.frame);
        _fWebViewHeight = _fWebPopHeight - kWebPopupButtonBottomOffset - kWebPopupButtonHeight - fTitleHeight - 2;
        CGFloat contentLabelWidth = _fWebPopWidth - 16;
        self.myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake((_fWebPopWidth - contentLabelWidth) * 0.5, CGRectGetMaxY(self.titleLabel.frame), contentLabelWidth, _fWebViewHeight)];
        [self addSubview:self.myScrollView];
        
        self.contentWebView = [[UIWebView alloc] initWithFrame:CGRectMake((_fWebPopWidth - contentLabelWidth) * 0.5, 0, contentLabelWidth, _fWebViewHeight)];
        self.contentWebView.backgroundColor = [UIColor clearColor];
        [self.contentWebView setUserInteractionEnabled:NO];
        [(UIScrollView *)[[self.contentWebView subviews] objectAtIndex:0] setBounces:YES];
        [self.contentWebView setScalesPageToFit:NO];
        self.contentWebView.delegate = self;
        [self.myScrollView addSubview:self.contentWebView];
        [self.contentWebView loadHTMLString:content baseURL:nil];
        
        CGRect leftBtnFrame = CGRectZero;
        CGRect rightBtnFrame = CGRectZero;
        
        if (!leftTitle && !rigthTitle) {
            // do nothing
            self.isAutoDismiss = YES;
            self.autoDismissDelaySeconds = kWebPopupAutoDismissSeconds;
        }
        else {
            self.isAutoDismiss = NO;
            
            if (!leftTitle) {
                rightBtnFrame = CGRectMake((_fWebPopWidth - kWebPopupSingleButtonWidth) * 0.5, _fWebPopHeight - kWebPopupButtonBottomOffset - kWebPopupButtonHeight, kWebPopupSingleButtonWidth, kWebPopupButtonHeight);
                _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _rightBtn.frame = rightBtnFrame;
                
            }else {
                leftBtnFrame = CGRectMake((_fWebPopWidth - 2 * kWebPopupCoupleButtonWidth - kWebPopupButtonBottomOffset) * 0.5, _fWebPopHeight - kWebPopupButtonBottomOffset - kWebPopupButtonHeight, kWebPopupCoupleButtonWidth, kWebPopupButtonHeight);
                rightBtnFrame = CGRectMake(CGRectGetMaxX(leftBtnFrame) + kWebPopupButtonBottomOffset, _fWebPopHeight - kWebPopupButtonBottomOffset - kWebPopupButtonHeight, kWebPopupCoupleButtonWidth, kWebPopupButtonHeight);
                _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _leftBtn.frame = leftBtnFrame;
                _rightBtn.frame = rightBtnFrame;
            }
            
            [_rightBtn setBackgroundImage:[UIImage ms_imageWithColor:RGB(0x51, 0x96, 0xef)] forState:UIControlStateNormal];
            [_rightBtn setTitle:rigthTitle forState:UIControlStateNormal];
            [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_rightBtn];
            
            [_leftBtn setBackgroundImage:[UIImage ms_imageWithColor:RGB(0xea, 0xea, 0xea)] forState:UIControlStateNormal];
            [_leftBtn setBackgroundImage:[UIImage ms_imageWithColor:RGB(0xda, 0xda, 0xda)] forState:UIControlStateHighlighted];
            [_leftBtn setTitle:leftTitle forState:UIControlStateNormal];
            _leftBtn.titleLabel.font = _rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            [_leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [_leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            _leftBtn.layer.masksToBounds = _rightBtn.layer.masksToBounds = YES;
            _leftBtn.layer.cornerRadius = _rightBtn.layer.cornerRadius = 3.0;
            [self addSubview:_leftBtn];
            
            self.leftBlock = leftBlock;
            self.rightBlock = rightBlock;
        }
    }
    return self;
}


- (instancetype)initWithTitle:(NSString *)title
        contentText:(NSString *)content
        buttonTitle:(NSString *)buttonTitle
              block:( ms_popupview_event_block_t)block
{
    return [[[self class] alloc] initWithTitle:title
                                   contentText:content
                               leftButtonTitle:nil
                                     leftBlock:nil
                              rightButtonTitle:buttonTitle
                                    rightBlock:block];
}


- (instancetype)initWithTitle:(NSString *)title
        contentText:(NSString *)content
{
    return [[[self class] alloc] initWithTitle:title
                                   contentText:content
                               leftButtonTitle:nil
                                     leftBlock:nil
                              rightButtonTitle:nil
                                    rightBlock:nil];
}

- (instancetype)initWithTitle:(NSString *)title
{
    return [[[self class] alloc] initWithTitle:nil
                                   contentText:title
                               leftButtonTitle:nil
                                     leftBlock:nil
                              rightButtonTitle:nil
                                    rightBlock:nil];
}

- (void)leftBtnClicked:(id)sender
{
    if (self.leftBlock) {
        self.leftBlock(self);
    }
    [self dismiss];
}

- (void)rightBtnClicked:(id)sender
{
    if (self.rightBlock) {
        self.rightBlock(self);
    }
    [self dismiss];
}

- (void)show
{
    self.frame = CGRectMake((MSScreenWidth() - _fWebPopWidth) * 0.5, - _fWebPopHeight - 30, _fWebPopWidth, _fWebPopHeight);
    
    [super show];
}

- (void)dismiss
{
    [super dismiss];
}

- (void)removeFromSuperview
{
    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
    [super removeFromSuperview];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        return;
    }
    UIView *parentView = [self parentView];
    
    if (!self.backImageView) {
        self.backImageView = [[MSMaskBackgroundView alloc] initWithFrame:parentView.bounds];
    }
    self.backImageView.popView = self;
    self.backImageView.backgroundColor = [UIColor blackColor];
    self.backImageView.alpha = 0.6f;
    [parentView addSubview:self.backImageView];
    self.transform = CGAffineTransformMakeRotation(0);
    CGRect afterFrame = CGRectMake((CGRectGetWidth(parentView.bounds) - _fWebPopWidth) * 0.5, (CGRectGetHeight(parentView.bounds) - _fWebPopHeight) * 0.5, _fWebPopWidth, _fWebPopHeight);
    self.frame = afterFrame;
    [super willMoveToSuperview:newSuperview];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize actualSize = [webView sizeThatFits:CGSizeZero];
    CGRect newFrame = webView.frame;
    newFrame.size.height = actualSize.height;
    webView.frame = newFrame;
    
    self.myScrollView.contentSize = CGSizeMake(webView.frame.size.width, webView.frame.size.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGRect frame = self.myScrollView.frame;
    CGPoint point = [touch locationInView:self];

    if (CGRectContainsPoint(frame, point)) {
        [self dismiss];
    }
}

@end




