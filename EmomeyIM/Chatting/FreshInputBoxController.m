//
//  FreshInputBoxController.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 2/12/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import "FreshInputBoxController.h"
#import "FreshMessageKeyboardController.h"
#import "InputBox.h"
#import "InputBoxOptionView.h"
#import "UIImage+Extras.h"
#import "EmojiView.h"
#import <EMSpeed/MSUIKitCore.h>
#import "DMEmo.h"
#import "WSAssetPickerController.h"
#import "AssetWrapper.h"
#import "LCSandboxManager.h"
#import "CommDataModel.h"
#import "EMCommData.h"
static NSString * const kFuncName_Snap = @"snap";
static NSString * const kFuncName_SendBouns = @"Send_Bonus";

#define kBottomDefaultHeight 216

@interface FreshInputBoxController () <
    InputBoxDelegate,
    FreshMessageKeyboardControllerDelegate,
    UITextViewDelegate,
    InputBoxOptionDelegate,
     EmojiViewDelegate,
    UIGestureRecognizerDelegate,
    WSAssetPickerControllerDelegate,
    UIImagePickerControllerDelegate
>
{
    FreshMessageKeyboardController *_keyboardController;
    CGFloat _toolbarBeginY;
    InputBox *_inputBox;
//    UIView *_inputBoxBottom;
    InputBoxState _inputBoxState;
    CGFloat _inputBoxHeight;
    UIView *_displayedInsideView; // 主面板里正在展示的视图
    BOOL _displayingMainView; // self.view是否已显示
    UITapGestureRecognizer *_tapRecognizer;
    NSUInteger _ATPosition;
}
@property (nonatomic, readonly) EmojiView *emojiView;
@property (nonatomic, readonly) InputBoxOptionView *optionView;
@property (nonatomic, strong) UIImage *bottomImage;

@end

@implementation FreshInputBoxController
@synthesize emojiView = _emojiView;
@synthesize optionView = _optionView;

- (void)dealloc {
}

- (instancetype)initWithParent:(UIViewController *)parent beginState:(InputBoxBeginState)beginState capabilities:(InputBoxCapability)capabilities {
    self = [super init];
    if (self) {
        _capabilities = capabilities;
        
        [parent addChildViewController:self];
        _keyboardController = [[FreshMessageKeyboardController alloc] init];
        _keyboardController.delegate = self;
        _beginState = beginState;
        _inputBoxHeight = [InputBox viewHeight];
        self.multiPhotosPick = NO;
        
        self.maxPhotoCount = kInputBox_Default_MaxPhotoCount;
        self.maxVideoCount = kInputBox_Default_MaxVideoCount;
//        _photoList = [[NSMutableArray alloc] init];
        _ATPosition = NSNotFound;
    }
    return self;
}

- (instancetype)initWithParent:(UIViewController *)parent beginState:(InputBoxBeginState)beginState {
    return [self initWithParent:parent beginState:beginState capabilities:InputBoxCapability_Normal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)beginObserving {
    [_keyboardController beginObservingKeyboard];
    _inputBox.textView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
      [self beginObserving];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_keyboardController endObservingKeyboard];
}

- (void)showInContextView:(UIView *)contextView options:(InputBoxOption)options{
    _contextView = contextView;
    _options = options;
    
    [_contextView addSubview:self.view];

    CGSize sz = _contextView.frame.size;
    self.view.frame = CGRectMake(0, sz.height, sz.width, 0);
    
    self.bottomImage = [UIImage resizableImageWithName:@"inputbox_option_bg"
                                             capInsets:UIEdgeInsetsMake(3, 1, 0, 1)
                                             fixedSize:CGSizeMake(sz.width, kBottomDefaultHeight)];
    [self loadInputBox];
    [_delegate inputBoxController:self didChangeFrame:_inputBox.frame];
}

- (void)observeTapInView:(UIView *)tapReceiver {
    if (_tapRecognizer) {
        if (_tapRecognizer.view != tapReceiver) {
            [tapReceiver removeGestureRecognizer:_tapRecognizer];
            _tapRecognizer = nil;
        }
    }
    if (_tapRecognizer == nil) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        _tapRecognizer.cancelsTouchesInView = NO;
        [tapReceiver addGestureRecognizer:_tapRecognizer];
        _tapRecognizer.delegate = self;
    }
}

- (void)actionTap:(UITapGestureRecognizer *)tap {
    if(_inputBox.textView.overrideNextReponser!=nil){
        return;
    }else{
       [self transformToNextState:kInputBoxState_Normal];
    }
}

- (NSString *)textContent {
    return [_inputBox getContentStr];
}

- (void)setTextContent:(NSString *)text {
    _inputBox.textContent = text;
}

- (void)clearText {
    [_inputBox reset];
}

- (void)fillATContent:(NSString *)ATContent {
    if (_ATPosition != NSNotFound) {
        UITextView *textView = _inputBox.textView;
        UITextPosition *targetPosition = [textView positionFromPosition:textView.beginningOfDocument offset:_ATPosition + 1];
        UITextRange *range = [textView textRangeFromPosition:targetPosition toPosition:targetPosition];
        [_inputBox.textView replaceRange:range withText:ATContent];
//        [_inputBox.textView insertText:ATContent];
        _ATPosition = NSNotFound;
    }
}

- (void)openOptionPanel {
    [self actionOption];
}

- (void)loadInputBox {
    CGSize sz = _contextView.frame.size;
    
    _toolbarBeginY = sz.height;
    if (_beginState == InputBoxBeginState_DisplayToolbar) {
        _toolbarBeginY -= [InputBox viewHeight];
    }
    _inputBox = [[InputBox alloc] initWithFrame:CGRectMake(0, _toolbarBeginY, sz.width, _inputBoxHeight) capabilities:_capabilities];
    [_contextView addSubview:_inputBox];
    _inputBox.delegate = self;
    _inputBox.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_inputBox.emojiBtn addTarget:self action:@selector(actionEmoji) forControlEvents:UIControlEventTouchUpInside];
    [_inputBox.textModeBtn addTarget:self action:@selector(actionTextMode) forControlEvents:UIControlEventTouchUpInside];
    [_inputBox.optionBtn addTarget:self action:@selector(actionOption) forControlEvents:UIControlEventTouchUpInside];
    [_inputBox.sendBtn addTarget:self action:@selector(actionPublish) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateNewTips];
}

- (BOOL)hadUsedNewFunction:(NSString *)func {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:func];
}

- (void)setFunction:(NSString *)func hadUsed:(BOOL)hadUsed {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:hadUsed forKey:func];
    [ud synchronize];
}

- (void)updateNewTips {
}

- (EmojiView *)emojiView {
    if (_emojiView == nil) {
        CGRect r = _contextView.frame;
        _emojiView = [[EmojiView alloc] initWithFrame:CGRectMake(0, r.size.height, r.size.width, [EmojiView viewHeight])];
        [_contextView addSubview:_emojiView];
        _emojiView.delegate = self;
    }
    return _emojiView;
}

- (InputBoxOptionView *)optionView {
    if (_optionView == nil) {
        CGRect r = _contextView.frame;
        _optionView = [[InputBoxOptionView alloc] initWithFrame:CGRectMake(0, r.size.height, r.size.width, [InputBoxOptionView viewHeight]) options:_options];
        _optionView.delegate = self;
        _optionView.image = self.bottomImage;
        [_contextView addSubview:_optionView];
        
        [self updateNewTips];
    }
    return _optionView;
}

- (UIView *)viewForState:(InputBoxState)state {
    switch (state) {
        case kInputBoxState_Emoji:
            return self.emojiView;
            break;
        case kInputBoxState_OptionView:
            return self.optionView;
        default:
            break;
    }
    return nil;
}

- (void)show:(BOOL)show contentView:(UIView *)contentView animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    dispatch_block_t block = ^(){
        if (show) {
            contentView.transform = CGAffineTransformMakeTranslation(0, -[InputBoxOptionView viewHeight]);
        }
        else {
            contentView.transform = CGAffineTransformIdentity;
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:block completion:completion];
    }
    else {
        block();
        if (completion) {
            completion(YES);
        }
    }
}

- (void)transformToNextState:(InputBoxState)nextSate completion:(void (^)(BOOL finished))completion {
    if (_inputBoxState == nextSate) {
        return;
    }
    InputBoxState oldState = _inputBoxState;
    _inputBoxState = nextSate;
    UIView *prevView = [self viewForState:oldState];
    UIView *nextView = [self viewForState:nextSate];
    
    if (oldState == kInputBoxState_Keyboard) {
        [_inputBox endEditing:YES];
        
        if (nextView) {
            [self show:YES contentView:nextView animated:YES completion:completion];
            [self updateBottom:[InputBoxOptionView viewHeight] animated:YES];
        }
        else { // back to normal
            // do nothing
        }
    }
    else if (prevView) {
        if (nextSate == kInputBoxState_Keyboard) {
            [_inputBox beginEditing];
            [self show:NO contentView:prevView animated:YES completion:completion];
        }
        else if (nextView) {
            [_contextView insertSubview:nextView aboveSubview:prevView];
            [self show:NO contentView:prevView animated:YES completion:nil];
            [self show:YES contentView:nextView animated:YES completion:completion];
        }
        else { // back to normal
            [self show:NO contentView:prevView animated:YES completion:completion];
            [self updateBottom:0 animated:YES];
        }
    }
    else { // normal
        if (nextSate == kInputBoxState_Keyboard) {
            [_inputBox beginEditing];
        }
        else if (nextView) {
            [self show:YES contentView:nextView animated:YES completion:completion];
            [self updateBottom:[InputBoxOptionView viewHeight] animated:YES];
        }else { // back to normal
            // do nothing
        }
    }
    [self updateInputMode];
}

- (void)transformToNextState:(InputBoxState)nextSate {
    [self transformToNextState:nextSate completion:nil];
}

- (void)updateBottom:(CGFloat)bottom animated:(BOOL)animated {
    dispatch_block_t block = ^(){
        CGSize sz = _contextView.frame.size;
        _inputBox.frame = CGRectMake(0, sz.height - _inputBoxHeight - bottom, sz.width, _inputBoxHeight);
        [_delegate inputBoxController:self didChangeFrame:_inputBox.frame];
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:block];
    }
    else {
        block();
    }
}

- (void)updateCounts {
//    [_inputBox updateAttachmentCount: [_photoList count]];
}

#pragma mark - FreshMessageKeyboardControllerDelegate

- (void)keyboardController:(FreshMessageKeyboardController *)keyboardController didChangeFrame:(CGRect)keyboardFrame {
    // ios7上有时会出现x=-320
    if (keyboardFrame.origin.x < 0 || keyboardFrame.origin.x > keyboardFrame.size.width) {
        return;
    }
    if (_inputBoxState == kInputBoxState_Normal) {
        _inputBoxState = kInputBoxState_Keyboard;
    }
    if (_inputBoxState == kInputBoxState_Keyboard) {
        CGRect rKeyboardFrame = [_contextView convertRect:keyboardFrame fromView:nil];
        [self updateBottom:CGRectGetHeight(_contextView.frame) - CGRectGetMinY(rKeyboardFrame) animated:NO];
    }
}

- (void)keyboardControllerKeyboardWillHide:(FreshMessageKeyboardController *)keyboardController {
    if (_inputBoxState == kInputBoxState_Keyboard) {
        _inputBoxState = kInputBoxState_Normal;
    }
    if (_inputBoxState == kInputBoxState_Normal) {
        [self updateBottom:0 animated:YES];
    }
}

- (void)keyboardControllerKeyboardDidHide:(FreshMessageKeyboardController *)keyboardController {
//    if (_inputBoxState == kInputBoxState_Normal) {
//        [self updateBottom:0 animated:NO];
//    }
}

#pragma mark - InputBoxDelegate

- (void)inputTextViewContentHeightChanged:(CGFloat)contentHeight {
    _inputBoxHeight = [InputBox viewHeightWithTextViewContentHeight:contentHeight];
    CGRect frame = _inputBox.frame;
    _inputBox.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - _inputBoxHeight, frame.size.width, _inputBoxHeight);
//    [self updateAmuseOrigin];
    [_delegate inputBoxController:self didChangeFrame:_inputBox.frame];
}

#pragma mark - PhizsViewsDelegate


- (void)sendMessage {
    [self actionPublish];
}
-(void)sendMoney{
    
}
#pragma mark - InputBoxOptionDelegate

- (void)didSelectInputBoxOption:(InputBoxOption)option {
    switch (option) {
//        case kInputBoxOption_Voice:
//        {
//            BOOL audioauth = [[UIDevice currentDevice] authorizationStatusForVideo:NO completion:^{
//                
//            }];
//            if (!audioauth) {
//                return;
//            }
//            [self actionVoice];
//        }
//            break;
//            
        case kInputBoxOption_PickPhoto:
            [self actionPickPhoto];
            break;
            
        case kInputBoxOption_TakePhoto:
            [self openPhotoCamara];
            break;

        default:
            break;
    }
}

#pragma 拍照，读取照片

- (void)actionPickPhoto {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    WSAssetPickerController *controller = [[WSAssetPickerController alloc] initWithAssetsLibrary:library];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)openPhotoCamara {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:NULL];//进入照相界面
}

- (void)openPhotoPicker {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    WSAssetPickerController *controller = [[WSAssetPickerController alloc] initWithAssetsLibrary:library];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - DLCImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if (info.count > 0) {
        UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *data = UIImageJPEGRepresentation(editImage,1);
        NSInteger fileSize = [data length];
        NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
        [myFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *strTime = [myFormatter stringFromDate:[NSDate date]];
        NSString *cachePath = [self filefolder];
        NSString *filePath =[cachePath stringByAppendingPathComponent:strTime];
        NSString *thumbnailPath = [filePath stringByAppendingString:@"_thumbnail"];
        [data writeToFile:thumbnailPath atomically:YES];
        ContentInfo *imageContent = [[ContentInfo alloc] init];
        imageContent.filepath = nil;
        imageContent.thumpPath = thumbnailPath;
        imageContent.fileType  =NSContentType_Pic;
        imageContent.fileExtra = @"png";
        [self.separatedlySender inputBoxController:self sendAttachment:imageContent];
    }
   [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - PhotoAppendViewDelegate

#pragma mark - InputBoxVoiceDelegate

#pragma mark - UITextViewDelegate


- (BOOL)inputBox:(InputBox *)boxView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (self.shouldCaptureATCharacter) {
        if ([text isEqualToString:@"@"]) {
            _ATPosition = range.location;
            if ([_delegate respondsToSelector:@selector(didCaptureATCharacterFromInputBoxController:)]) {
                [_delegate didCaptureATCharacterFromInputBoxController:self];
            }
        }
        else {
            _ATPosition = NSNotFound;
        }
    }
    return YES;
}

- (BOOL)inputBoxShouldBeginEditing:(InputBox *)boxView{
    [self transformToNextState:kInputBoxState_Keyboard];
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceive = YES;
    if (_inputBoxState == kInputBoxState_Normal) {
        shouldReceive = NO;
    }
    else {
        shouldReceive = ![touch.view isKindOfClass:[UIControl class]];
    }
    return shouldReceive;
}

//- (void)textViewDidBeginEditing:(UITextView *)textView {
//}
//
//#pragma mark - TextView notification
//
//- (void)installTextViewObserver {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didBeginEditing:)
//                                                 name:UITextViewTextDidBeginEditingNotification
//                                               object:_inputBox.textView];
//}
//
//- (void)uninstallTextViewObserver {
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UITextViewTextDidBeginEditingNotification
//                                                  object:_inputBox.textView];
//}
//
//- (void)didBeginEditing:(NSNotification *)notification {
//}

#pragma mark - Toolbar actions

#pragma mark - Toolbar actions

- (void)actionEmoji {
    if (_inputBoxState != kInputBoxState_Emoji) {
        [self transformToNextState:kInputBoxState_Emoji];
    }
}

- (void)actionTextMode {
    if (_inputBoxState == kInputBoxState_Emoji) {
        [self transformToNextState:kInputBoxState_Keyboard];
    }
}

- (void)updateInputMode {
    if (_inputBoxState == kInputBoxState_Emoji) {
        _inputBox.emojiBtn.hidden = YES;
        _inputBox.textModeBtn.hidden = NO;
    }
    else {
        _inputBox.emojiBtn.hidden = NO;
        _inputBox.textModeBtn.hidden = YES;
    }
}

- (void)actionOption {
    if (_inputBoxState == kInputBoxState_OptionView) {
        [self transformToNextState:kInputBoxState_Keyboard];
    }
    else {
        [self transformToNextState:kInputBoxState_OptionView];
    }
}

- (void)actionPublish {
    if (self.sendSeparatedly) {
        [_separatedlySender inputBoxController:self sendText:[self textContent]];
    }else {
        [self publish];
    }
    [_inputBox reset];
}

- (void)publish {
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self transformToNextState:kInputBoxState_Keyboard];
    return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.shouldCaptureATCharacter) {
        if ([text isEqualToString:@"@"]) {
            _ATPosition = range.location;
            if ([_delegate respondsToSelector:@selector(didCaptureATCharacterFromInputBoxController:)]) {
                [_delegate didCaptureATCharacterFromInputBoxController:self];
            }
        }
        else {
            _ATPosition = NSNotFound;
        }
    }
    if (text.length >0) {
        self.inputBox.sendBtn.backgroundColor =RGB(56, 110, 189);
    }else{
        NSString *tempStr= textView.text;
        tempStr = [tempStr stringByReplacingCharactersInRange:range withString:text];
        if (tempStr.length ==0) {
           self.inputBox.sendBtn.backgroundColor =RGB(200, 200, 200);
        }
    }
    if ([self.separatedlySender respondsToSelector:@selector(inputBoxController:shouldChangeTextInRange:replacementText:)]) {
        [self.separatedlySender inputBoxController:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)assetPickerControllerDidCancel:(WSAssetPickerController *)sender{
    [sender dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)filefolder {
    return [[LCSandboxManager sharedInstance] buildFolderpathInDirWithType:LCSandboxDir_TransferTmp foldername:@"image"];
}

- (void)assetPickerController:(WSAssetPickerController *)sender didFinishPickingMediaWithAssets:(NSArray *)assets{
    if (assets.count  >0) {
    }
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:[assets count]];
    NSArray *selectedAssets = sender.selectedAssets;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *begin = [NSDate date];
        int index = 0;
        NSOperationQueue *operationqueue = [[NSOperationQueue alloc] init];
        [operationqueue setMaxConcurrentOperationCount:4];
        NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
        [myFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *strTime = [myFormatter stringFromDate:[NSDate date]];
        NSString *cachePath = [self filefolder];
        
        for (ALAsset *asset in selectedAssets) {
            @autoreleasepool{
                NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
                AssetWrapper *aw = [[AssetWrapper alloc] init];
                aw.asset = asset;
                //在此为文件 创建 名字
                NSString *fileName = [strTime stringByAppendingFormat:@"_%d", index];
                NSString *filePath =[cachePath stringByAppendingPathComponent:fileName];
                aw.originImagePath = filePath;
                aw.thumbnailPath = [filePath stringByAppendingString:@"_thumbnail"];
                [mArr addObject:aw];
                
                NSBlockOperation *blockoperation =[NSBlockOperation blockOperationWithBlock:^{
                    aw.fileSize = [weakSelf saveImageFromAsset:asset toPath:aw.originImagePath thumbnailPath:aw.thumbnailPath];
                }];
                [operationqueue addOperation:blockoperation];
                index ++;
            }
        }
        [operationqueue waitUntilAllOperationsAreFinished];
    });
    
    [sender dismissViewControllerAnimated:YES completion:NULL];

}

- (void)assetPickerControllerDidLimitSelection:(WSAssetPickerController *)sender{
    
}

- (void)copyRepr:(ALAssetRepresentation *)repr toURL:(NSURL *)destURL{
    NSOutputStream *output = [[NSOutputStream alloc] initWithURL:destURL append:NO];
    const NSUInteger bufferSize = 100*1024;
    uint8_t buffer[bufferSize];
    NSUInteger offset = 0;
    NSError *error = nil;
    NSUInteger readSize = 0;
    [output open];
    while ((readSize = [repr getBytes:buffer fromOffset:offset length:bufferSize error:&error]) > 0) {
        NSUInteger writtenSize = [output write:buffer maxLength:readSize];
        offset += writtenSize;
    }
    if (error){
    }
    [output close];
}

- (NSUInteger)saveImageFromAsset:(ALAsset *)asset toPath:(NSString *)destPath thumbnailPath:(NSString *)thumbnailPath{
    ALAssetRepresentation *repr = [asset defaultRepresentation];
    ALAssetOrientation orie = [repr orientation];
    NSUInteger fileSize = 0;
    if (orie == ALAssetOrientationUp) {
        [self copyRepr:repr toURL:[NSURL fileURLWithPath:destPath]];
        fileSize = [repr size];
    }
    else {
        CGImageRef image = [repr fullResolutionImage];
        UIImage *tempImg = [[UIImage alloc] initWithCGImage:image scale:[repr scale] orientation:(UIImageOrientation)orie];
        tempImg = [UIImage fixOrientation:tempImg];
        NSData *data = UIImageJPEGRepresentation(tempImg, 1);
        [data writeToFile:destPath atomically:YES];
        fileSize = [data length];
    }
    CGImageRef thumbnail = [asset aspectRatioThumbnail];
    UIImage *tempImg = [[UIImage alloc] initWithCGImage:thumbnail];
    NSData *data = UIImageJPEGRepresentation(tempImg,1);
    [data writeToFile:thumbnailPath atomically:YES];
    //发送文件
    ContentInfo *imageContent = [[ContentInfo alloc] init];
    imageContent.filepath = destPath;
    imageContent.thumpPath = thumbnailPath;
    imageContent.fileType  =NSContentType_Pic;
    imageContent.fileExtra = @"png";
    [self.separatedlySender inputBoxController:self sendAttachment:imageContent];
    return fileSize;
}

#pragma mark - EmojiViewDelegate
- (void)emojiView:(EmojiView*)emojiView didSelecte:(DMEmo*)emo{
    [_inputBox appendEmoji:emo.src strValue:emo.name];
//   c self.separatedlySender inputBoxController:self shouldChangeTextInRange:(NSRange) replacementText:<#(NSString *)#>
}
@end
