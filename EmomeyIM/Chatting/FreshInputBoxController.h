//
//  FreshInputBoxController.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 2/12/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
#import "ContentInfo.h"
#import "InputBox.h"
#import "InputBoxOptionView.h"
#import "BaseViewController.h"
#define kInputBox_Default_MaxPhotoCount 10
#define kInputBox_Default_MaxVideoCount 10

typedef enum {
    // 开始状态：不显示
    InputBoxBeginState_DisplayNone,
    // 开始状态：只显示工具条
    InputBoxBeginState_DisplayToolbar
} InputBoxBeginState;

typedef enum {
    kInputBoxState_Normal,
    kInputBoxState_Keyboard,
    kInputBoxState_OptionView,
    kInputBoxState_Emoji,
    kInputBoxState_Voice,
    kInputBoxState_Photo,
} InputBoxState;

@class FreshInputBoxController;

@protocol FreshInputBoxControllerDelegate <NSObject>

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController didChangeFrame:(CGRect)inputBoxFrame;
@optional

- (void)didCaptureATCharacterFromInputBoxController:(FreshInputBoxController *)inputBoxController;
- (BOOL)showAmuseViewWithAnimation;

@end

@protocol FreshInputBoxSeparatedlySender <NSObject>

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController sendText:(NSString *)text;
- (void)inputBoxController:(FreshInputBoxController *)inputBoxController sendAttachment:(ContentInfo *)attachment;
- (void)inputBoxController:(FreshInputBoxController *)inputBoxController shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
@optional

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController sendAttachments:(NSArray *)attachments;

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController sendPositon:(NSArray *)attachments;

@end

@interface FreshInputBoxController : BaseViewController
{
}

@property (nonatomic, weak, readonly) UIView *contextView;
@property (nonatomic, readonly) InputBoxBeginState beginState; // 默认是InputBoxBeginState_DisplayNone
@property (nonatomic, readonly) InputBoxState inputBoxState;
@property (nonatomic, readonly) InputBoxCapability capabilities;
@property (nonatomic, readonly) InputBoxOption options;
@property (nonatomic, assign) BOOL sendSeparatedly; // 是否分开发送
@property (nonatomic, assign) BOOL shouldCaptureATCharacter; // 捕获@
@property (nonatomic, assign) BOOL multiPhotosPick; // 支持一次发送多张图片, default:YES

@property (nonatomic, assign) NSUInteger maxPhotoCount; // 最多可以同时添加多少张图，默认kInputBox_Default_MaxPhotoCount
@property (nonatomic, assign) NSUInteger maxVideoCount; // 最多可以同时添加多少视频，默认kInputBox_Default_MaxVideoCount
@property (nonatomic, weak) id<FreshInputBoxControllerDelegate> delegate;
@property (nonatomic, weak) id<FreshInputBoxSeparatedlySender> separatedlySender;

//@property (nonatomic, readonly) NSArray *photoList;
@property (nonatomic, readwrite, assign) NSString *textContent;
@property (nonatomic, readonly) InputBox *inputBox;
 // InputBox *_inputBox;

- (instancetype)initWithParent:(UIViewController *)parent beginState:(InputBoxBeginState)beginState capabilities:(InputBoxCapability)capabilities;
- (instancetype)initWithParent:(UIViewController *)parent beginState:(InputBoxBeginState)beginState;

- (void)showInContextView:(UIView *)contextView options:(InputBoxOption)options;

- (void)observeTapInView:(UIView *)tapReceiver;

- (void)clearText;

- (void)fillATContent:(NSString *)ATContent;

- (void)openOptionPanel;

- (void)publish;

@end
