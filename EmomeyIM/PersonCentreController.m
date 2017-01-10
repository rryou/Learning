//
//  PersonCentreController.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/6.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "PersonCentreController.h"
#import <EMSpeed/MSUIKitCore.h>
#import <UIImage+Utility.h>
#import "PersonTabMangerController.h"
#import "EMCommData.h"
#import "InputHelper.h"
#import "UIButton+SocketImageCache.h"
#import "WSAssetPickerController.h"
#import "LCSandboxManager.h"
#import "CommDataModel.h"
#import "AssetWrapper.h"
#import "UIImage+Extras.h"
#import <MBProgressHUD.h>
#import <EMSpeed/BDKNotifyHUD.h>
#import "InputHelper.h"
#import "EMLocalSocketManaget.h"
#import "UIAlert+Custom.h"
#define  KMargeX 10
#define  KMargeY 5

@interface PersonCentreController ()<UIActionSheetDelegate,WSAssetPickerControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UIView *headview;
@property (nonatomic, strong) UITextField *nickNametexField;
@property (nonatomic, strong) UITextField *signedField;
@property (nonatomic, strong) UILabel *titlManglb;
@property (nonatomic, strong) UICollectionView *titleManView;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) CGroup *groupInfo;
@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) UILabel *namelb;
@property (nonatomic, strong) UILabel *singnelb;
@property (nonatomic, strong) UIButton *iconView;
@property (nonatomic, strong) UIScrollView *tabScroll;
@property (nonatomic, strong) UIButton *addTabBtn;
@property (nonatomic, strong) MBProgressHUD *hudProgress;
@property (nonatomic, strong) UIButton *logoutBtn;
@property (nonatomic, assign) short wmodeType;
@end

@implementation PersonCentreController

- (id)initWithUserInfo:(UserInfo *)userInfro{
    self = [super init];
    if (self) {
        self.userInfo = userInfro;
        self.title = @"个人中心";//[self.userInfo.m_strNickName stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.groupInfo = [[EMCommData sharedEMCommData] getGroupbyid:self.userInfo.m_nGroupId];
        self.view.backgroundColor = RGB(234, 234, 234);
    }
    return self;
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.userInfo) {
        self.headview = [[UIView alloc] initWithFrame: CGRectMake(0, 64, self.view.frame.size.width, 160)];
    }
    self.headview.backgroundColor= [UIColor colorWithRed:54/255.0 green:104/255.0 blue:193/255.0 alpha:1.0];
    [self.view addSubview:self.headview];
    
    self.iconView = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width - 60)/2, 25, 60, 60)];
    self.iconView.layer.cornerRadius = 30;
    self.iconView.layer.borderWidth = 3;
    self.iconView.layer.borderColor = RGB(91, 132, 205).CGColor;
    [self.headview addSubview:self.iconView];
    NSString  *tempStrName = [NSNumber numberWithLongLong:self.userInfo.m_n64PortraitID].stringValue;
    [self.iconView addTarget:self action:@selector(updateUserIcon:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.iconView sk_setimageWith:tempStrName forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"normalcon"]];
    self.iconView.layer.contents =  (id)[UIImage imageNamed:tempStrName].CGImage ;
    self.iconView.layer.masksToBounds = YES;
    
    self.namelb = [[UILabel alloc] initWithFrame:CGRectMake(0, self.iconView.bottom + 10, self.view.width,  25)];
    self.namelb.textColor = [UIColor whiteColor];
    self.namelb.textAlignment = NSTextAlignmentCenter;
    self.namelb.font = [UIFont systemFontOfSize:15];
    self.namelb.text = self.userInfo.m_strNickName;
    [self.headview addSubview:self.namelb];
    
    self.singnelb = [[UILabel alloc] initWithFrame:CGRectMake(0,  self.namelb.bottom  + 10, self.view.width, 20)];
    self.singnelb.textAlignment = NSTextAlignmentCenter;
    self.singnelb.font = [UIFont systemFontOfSize:14];
    self.singnelb.textColor = [UIColor whiteColor];
    [self.headview addSubview:self.singnelb];
    if (self.userInfo.m_strSignature.length >0) {
        self.singnelb.text = self.userInfo.m_strSignature;
    }else{
        self.singnelb.text =  @"暂无个性签名";
    }
    
    self.nickNametexField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.headview.bottom , self.view.frame.size.width, 45)];
    UILabel *leftNicklb = [[UILabel alloc] initWithFrame:CGRectMake(00,  self.headview.bottom, 70, 45)];
    leftNicklb.text = @"  昵称";
    leftNicklb.textColor =RGB(128, 128, 128);
    leftNicklb.font = [UIFont systemFontOfSize:16];
    leftNicklb.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:leftNicklb];
    self.nickNametexField.leftView = leftNicklb;
    self.nickNametexField.delegate = self;
    
    self.nickNametexField.leftViewMode = UITextFieldViewModeAlways;
    [self.nickNametexField addSubview:leftNicklb];
    self.nickNametexField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.nickNametexField];
    
    self.signedField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.nickNametexField.bottom + 10, self.view.frame.size.width, 45)];
    UILabel *leftsignlb = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 70, 50)];
    leftsignlb.textAlignment  =NSTextAlignmentLeft;
    self.signedField.delegate = self;
    leftsignlb.text = @"  签名";
    
    leftsignlb.textColor =RGB(128, 128, 128);
    self.signedField.backgroundColor = [UIColor whiteColor];
    leftsignlb.textAlignment = NSTextAlignmentLeft;
    self.signedField.leftViewMode = UITextFieldViewModeAlways;
    leftsignlb.font = [UIFont systemFontOfSize:16];
    self.signedField.leftView = leftsignlb;

    self.nickNametexField.text = self.userInfo.m_strNickName;
    self.nickNametexField.enabled = NO;
    self.signedField.enabled = NO;
    if (self.userInfo.m_strSignature.length > 0) {
        self.signedField.text = self.userInfo.m_strSignature;
    }else{
        self.signedField.text = @"-";
    }
    self.nickNametexField.enabled = YES;
    self.signedField.enabled = YES;

    [self.view addSubview:self.signedField];
    

    self.logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.height - 70, self.view.width, 50)];
    [self.logoutBtn setTitle:@"退出当前账号" forState:UIControlStateNormal];
    [self.logoutBtn addTarget:self action:@selector(logoutBtnevent:) forControlEvents:UIControlEventTouchUpInside];
    [self.logoutBtn setTitleColor:RGB(61, 114, 197) forState:UIControlStateNormal];
    self.logoutBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.logoutBtn];

    self.hudProgress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hudProgress];
    self.hudProgress.mode = MBProgressHUDModeIndeterminate;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePersonInfo:) name:UpdateSelfNoticeMessage object:nil];
}

- (void)updatePersonInfo:(NSNotification *)notice{
    self.userInfo = [EMCommData sharedEMCommData].selfUserInfo;
    self.nickNametexField.text = self.userInfo.m_strNickName;
    self.namelb.text = self.userInfo.m_strNickName;
    if (self.userInfo.m_strSignature.length > 0) {
        self.signedField.text = self.userInfo.m_strSignature;
    }else{
        self.signedField.text = @"-";
    }
    if (self.userInfo.m_strSignature.length >0) {
        self.singnelb.text = self.userInfo.m_strSignature;
    }else{
        self.singnelb.text =  @"暂无个性签名";
    }
    NSString  *tempStrName = [NSNumber numberWithLongLong:self.userInfo.m_n64PortraitID].stringValue;
    [self.iconView sk_setimageWith:tempStrName forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"normalcon"]];
    self.iconView.layer.contents =  (id)[UIImage imageNamed:tempStrName].CGImage ;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==100) {
        if (buttonIndex==1) {
            [[EMCommData sharedEMCommData] clearAlldata];
            [[EMLocalSocketManaget sharedSocketManaget] resetAllSocket];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)logoutBtnevent: (UIButton *)sender{
     __block __typeof(self)weakSelf = self;
    showAlert4(@"温馨提示", @"确认退出账号？",  weakSelf,  100,  @"取消", @"确定", nil);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self actionPickPhoto];
    }else if (buttonIndex ==1){
        [self  openPhotoCamara];
    }
}

- (void)updateUserIcon:(UIButton *)sender{
    UIActionSheet *myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册", @"拍照", nil];
    myActionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [myActionSheet showInView:self.view];
}

+ (UIImage*)imageWithSize:(CGSize)size borderColor:(UIColor *)color borderWidth:(CGFloat)borderWidth{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [[UIColor clearColor] set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGFloat lengths[] = { 3, 1 };
    CGContextSetLineDash(context, 0, lengths, 1);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, size.width, 0.0);
    CGContextAddLineToPoint(context, size.width, size.height);
    CGContextAddLineToPoint(context, 0, size.height);
    CGContextAddLineToPoint(context, 0.0, 0.0);
    CGContextStrokePath(context);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeTapGusture doneBlock:^(id res){
    }];
}


- (void)actionPickPhoto {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    WSAssetPickerController *controller = [[WSAssetPickerController alloc] initWithAssetsLibrary:library];
    controller.delegate = self;
    controller.selectionLimit  =1;
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
        NSData *data = UIImageJPEGRepresentation(editImage, 1);
        NSInteger fileSize = [data length];
        NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
        [myFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *strTime = [myFormatter stringFromDate:[NSDate date]];
        NSString *cachePath = [self filefolder];
        NSString *filePath =[cachePath stringByAppendingPathComponent:strTime];
        NSString *thumbnailPath = [filePath stringByAppendingString:@"_thumbnail"];
        [data writeToFile:thumbnailPath atomically:YES];
        
        CIM_UploadData *tempFile = [[CIM_UploadData alloc] init];
        EMFileData *tempimage = [[EMFileData alloc] init];
        [tempimage readFile:thumbnailPath];
        tempFile.m_Data = tempimage;
        tempFile.m_cFileType = 0;
        tempFile.m_strFileName = @"png";
        tempFile.m_n64UserID  = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        tempFile.m_n64GroupID = [EMCommData sharedEMCommData].selfUserInfo.m_nGroupId;
        self.hudProgress.label.text = @"上传图像中";
        [self.hudProgress showAnimated:YES];
        __weak typeof(self) wealself = self;
        [tempFile  setUploadCompletion: ^(CIM_UploadData *responseData, BOOL success){
            if (success) {
                wealself.hudProgress.label.text =@"修改资料中";
                CIM_ModNickName *tempNickPost = [[CIM_ModNickName alloc] init];
                tempNickPost.m_n64UserID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
                tempNickPost.m_wType = 2;
                tempNickPost.m_n64NewPortraitID =responseData.m_n64FileID;
                [tempNickPost setCompletionBlock:^(NSData *response, BOOL suc){
                    [wealself.hudProgress hideAnimated:YES];
                    if (suc) {
                        [EMCommData sharedEMCommData].selfUserInfo.m_n64PortraitID = responseData.m_n64FileID;
                        [wealself.iconView sk_setimageWith:[NSNumber numberWithLongLong:responseData.m_n64FileID].stringValue forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"normalcon"]];
                    }
                }];
                [tempNickPost sendSockPost];
            }else{
                [wealself.hudProgress hideAnimated:YES];
                [BDKNotifyHUD showNotifHUDWithText: @"上传失败"];
            }
        }];
        [tempFile startUploadFile];
        
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)assetPickerControllerDidCancel:(WSAssetPickerController *)sender{
    [sender dismissViewControllerAnimated:YES completion:NULL];
}

- (void)assetPickerController:(WSAssetPickerController *)sender didFinishPickingMediaWithAssets:(NSArray *)assets{
    if (assets.count  >0) {
    }
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithCapacity:[assets count]];
    NSArray *selectedAssets = sender.selectedAssets;
    ALAsset *asset = [selectedAssets objectAtIndex:0];
    ALAssetRepresentation *repr = [asset defaultRepresentation];
    ALAssetOrientation orie = [repr orientation];
    NSUInteger fileSize = 0;
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *strTime = [myFormatter stringFromDate:[NSDate date]];
    NSString *cachePath = [self filefolder];
    NSString *filePath =[cachePath stringByAppendingPathComponent:strTime];
    NSString *thumbnailPath = [filePath stringByAppendingString:@"_thumbnail"];
    if (orie == ALAssetOrientationUp) {
        [self copyRepr:repr toURL:[NSURL fileURLWithPath:filePath]];
        fileSize = [repr size];
    }
    else {
        CGImageRef image = [repr fullResolutionImage];
        UIImage *tempImg = [[UIImage alloc] initWithCGImage:image scale:[repr scale] orientation:(UIImageOrientation)orie];
        tempImg = [UIImage fixOrientation:tempImg];
        NSData *data = UIImageJPEGRepresentation(tempImg, 1);
        [data writeToFile:filePath atomically:YES];
        fileSize = [data length];
    }
    CGImageRef thumbnail = [asset aspectRatioThumbnail];
    UIImage *tempImg = [[UIImage alloc] initWithCGImage:thumbnail];
    NSData *data = UIImageJPEGRepresentation(tempImg,1);
    [data writeToFile:thumbnailPath atomically:YES];
    
    CIM_UploadData *tempFile = [[CIM_UploadData alloc] init];
    EMFileData *tempimage = [[EMFileData alloc] init];
    [tempimage readFile:thumbnailPath];
    tempFile.m_Data = tempimage;
    tempFile.m_cFileType = 0;
    tempFile.m_strFileName = @"png";
    tempFile.m_n64UserID  = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
    tempFile.m_n64GroupID = [EMCommData sharedEMCommData].selfUserInfo.m_nGroupId;
    self.hudProgress.label.text = @"上传图像中";
    [self.hudProgress showAnimated:YES];
    __weak typeof(self) wealself = self;
    [tempFile  setUploadCompletion: ^(CIM_UploadData *responseData, BOOL success){
        if (success) {
            wealself.hudProgress.label.text =@"修改资料中";
            CIM_ModNickName *tempNickPost = [[CIM_ModNickName alloc] init];
            tempNickPost.m_n64UserID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
            tempNickPost.m_wType = 2;
            tempNickPost.m_n64NewPortraitID = responseData.m_n64FileID;
            [tempNickPost setCompletionBlock:^(NSData *response, BOOL succ){
                [wealself.hudProgress hideAnimated:YES];
                if (succ) {
                    [EMCommData sharedEMCommData].selfUserInfo.m_n64PortraitID = responseData.m_n64FileID;
                    [wealself.iconView sk_setimageWith:[NSNumber numberWithLongLong:responseData.m_n64FileID].stringValue forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"normalcon"]];
                }
            }];
            [tempNickPost sendSockPost];
        }else{
            [wealself.hudProgress hideAnimated:YES];
            [BDKNotifyHUD showNotifHUDWithText: @"上传失败"];
        }
    }];
    [tempFile startUploadFile];
    
    [sender dismissViewControllerAnimated:YES completion:NULL];
}

- (void)assetPickerControllerDidLimitSelection:(WSAssetPickerController *)sender{
    
}

- (NSString *)filefolder {
    return [[LCSandboxManager sharedInstance] buildFolderpathInDirWithType:LCSandboxDir_TransferTmp foldername:@"image"];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField== self.nickNametexField) {
        self.wmodeType = 1;
         [self showActionSheet:@"昵称"];
    }else if ( textField == self.signedField){
          self.wmodeType = 3;
        [self showActionSheet:@"签名"];
    }
    return NO;
}

- (void)showActionSheet:(NSString *)titleStr{
    if([[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"修改%@",titleStr] message:@"\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
        
        UITextField * text = [[UITextField alloc] initWithFrame:CGRectMake(12, 64, 240, 35)];//wight = 270;
        text.placeholder = [NSString stringWithFormat:@"请输入你要修改的%@",titleStr];
        text.borderStyle = UITextBorderStyleRoundedRect;//设置边框的样式
        [alert.view addSubview:text];
        
        UIAlertAction *submietaction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *sendMessage = text.text;
            CIM_ModNickName *tempGrou = [[CIM_ModNickName alloc] init];
            //@property (nonatomic, assign) short m_wType;  // 1==ModNickName; 2==ModPortrait 3 ==签名
            tempGrou.m_n64UserID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
            tempGrou.m_wType = self.wmodeType;
            tempGrou.m_strNickName = sendMessage;
            self.hudProgress.label.text = @"修改中，请稍等";
            [self.hudProgress showAnimated:YES];
            [tempGrou setCompletionBlock:^(NSData *responseData, BOOL success){
                [self.hudProgress hideAnimated:YES];
                if(success){
                    if (self.wmodeType ==1) {
                        [EMCommData sharedEMCommData].selfUserInfo.m_strNickName = sendMessage;
                        self.nickNametexField.text = sendMessage;
                        self.namelb.text = sendMessage;
                    }else if (self.wmodeType ==3){
                        [EMCommData sharedEMCommData].selfUserInfo.m_strSignature = sendMessage;
                        self.singnelb.text = sendMessage;
                        self.signedField.text = sendMessage;
                    }
                }else{
                    
                }
            }];
            [tempGrou sendSockPost];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        
        [alert addAction:cancel];
        [alert addAction:submietaction];
        [self presentViewController:alert animated:YES completion:^{ }];
        
    }else{
        UIAlertView  *customAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"修改%@",titleStr] message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [customAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *nameField = [customAlertView textFieldAtIndex:0];
        nameField.placeholder = @"请输入一个名称";
        [customAlertView show];
    }

}

@end
