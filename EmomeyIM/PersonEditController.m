//
//  PersonEditController.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/28.
//  Copyright © 2016年 frank. All rights reserved.
//

#define IOS8 [[[UIDevice currentDevice]systemVersion] floatValue] >= 8.0
#define wSrceem [UIScreen mainScreen].bounds.size.width
#define hSrceem [UIScreen mainScreen].bounds.size.height

#import "PersonEditController.h"
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
#define  KMargeX 10
#define  KMargeY 5
@interface PersonEditController ()<UIActionSheetDelegate,WSAssetPickerControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UIView *headview;
@property (nonatomic, strong) UITextField *nickNametexField;
@property (nonatomic, strong) UITextField *signedField;
@property (nonatomic, strong) UILabel *titlManglb;
@property (nonatomic, strong) UICollectionView *titleManView;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) CGroup *groupInfo;
@property (nonatomic, strong) CGroupMember *memberInfo;
@property (nonatomic, strong) UILabel *namelb;
@property (nonatomic, strong) UILabel *singnelb;
@property (nonatomic, strong) UIButton *iconView;
@property (nonatomic, strong) UIScrollView *tabScroll;
@property (nonatomic, strong) UIButton *addTabBtn;
@property (nonatomic, strong) MBProgressHUD *hudProgress;
@end

@implementation PersonEditController

- (id)initWithMember:(CGroupMember *)member{
    self = [super init];
    if (self) {
        self.memberInfo = member;
        self.title =@"个人资料";
         self.groupInfo = [[EMCommData sharedEMCommData] getGroupbyid:self.memberInfo.m_n64GroupID];
        self.view.backgroundColor = RGB(234, 234, 234);
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headview = [[UIView alloc] initWithFrame: CGRectMake(0, 64, self.view.frame.size.width, 130)];
    self.headview.backgroundColor= [UIColor colorWithRed:54/255.0 green:104/255.0 blue:193/255.0 alpha:1.0];
    [self.view addSubview:self.headview];
    
    self.iconView = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width - 60)/2, 25, 60, 60)];
    self.iconView.layer.cornerRadius = 30;
    self.iconView.layer.borderWidth = 3;
    self.iconView.layer.borderColor = RGB(91, 132, 205).CGColor;
    [self.headview addSubview:self.iconView];
    NSString *tempStrName = [NSNumber numberWithLongLong:self.memberInfo.m_n64PortraitID].stringValue;
    self.iconView.enabled = NO;

    [self.iconView sk_setimageWith:tempStrName forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"normalcon"]];
    self.iconView.layer.contents =  (id)[UIImage imageNamed:tempStrName].CGImage ;
    self.iconView.layer.masksToBounds = YES;
    
    self.namelb = [[UILabel alloc] initWithFrame:CGRectMake(0, self.iconView.bottom + 10, self.view.width,  25)];
    self.namelb.textColor = [UIColor whiteColor];
    self.namelb.textAlignment = NSTextAlignmentCenter;
    self.namelb.font = [UIFont systemFontOfSize:15];
    [self.headview addSubview:self.namelb];
    
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
    leftsignlb.text = @"  备注名";
    self.nickNametexField.text = [self.memberInfo getNickName];

    leftsignlb.textColor =RGB(128, 128, 128);
    self.signedField.backgroundColor = [UIColor whiteColor];
    leftsignlb.textAlignment = NSTextAlignmentLeft;
    self.signedField.leftViewMode = UITextFieldViewModeAlways;
    leftsignlb.font = [UIFont systemFontOfSize:16];
    self.signedField.leftView = leftsignlb;
    self.namelb.text = [self.memberInfo getNickName];
    self.nickNametexField.text = [self.memberInfo getSigleName];
    self.signedField.enabled = YES;
    if (self.memberInfo.Gm_strPeerRemark) {
        self.signedField.text = self.memberInfo.Gm_strPeerRemark;
    }else{
        self.signedField.text = @"-";
    }
    self.signedField.enabled = YES;
    self.nickNametexField.enabled = NO;
    [self.view addSubview:self.signedField];
    
    self.titlManglb = [[UILabel alloc] initWithFrame:CGRectMake(0, self.signedField.bottom + 10, 60, 20)];
    self.titlManglb.text = @"标签";
    self.titlManglb.backgroundColor = [UIColor clearColor];
    self.titlManglb.font = [UIFont systemFontOfSize:16];
    self.titlManglb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titlManglb];
    
    self.tabScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.titlManglb.bottom + 5, self.view.width, self.view.height - self.titlManglb.bottom - 80)];
    self.tabScroll.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tabScroll];
    
    self.addTabBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.tabScroll.bottom, self.view.width, 35)];
    [self.addTabBtn addTarget:self action:@selector(addTabClicck:) forControlEvents:UIControlEventTouchUpInside];
    [self.addTabBtn  setBackgroundImage:[UIImage ms_imageWithColor:RGB(231, 240, 255)] forState:UIControlStateNormal];
    [self.addTabBtn setTitle:@"+ 添加标签" forState:UIControlStateNormal];
    [self.addTabBtn setTitleColor:RGB(35, 85, 193) forState:UIControlStateNormal];
    self.addTabBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.addTabBtn];

    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = RGB(193, 209, 240).CGColor;
    border.fillColor = nil;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 1, 1);
    CGPathAddLineToPoint(path, nil, self.view.width, 1);
    [border setPath:path];
    CGPathRelease(path);
    border.frame =  self.addTabBtn.bounds;
    border.lineWidth =1.f;
    border.lineCap = @"butt";
    border.lineDashPattern = @[@4, @2];
    [self.addTabBtn.layer addSublayer:border];
 
    self.hudProgress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hudProgress];
    self.hudProgress.mode = MBProgressHUDModeIndeterminate;
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateGroupInfo:) name:UpdateGroupNotice object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)upDateGroupInfo:(NSNotification *)notice{
    if (notice.object) {
        NSNumber *tempNumber = notice.object;
        if (tempNumber.longLongValue == self.groupInfo.m_n64GroupID) {
            CGroup *newGroup = [[EMCommData sharedEMCommData] getGroupbyid:tempNumber.longLongValue];
            self.groupInfo = newGroup;
            [self resetTabviews];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeTapGusture doneBlock:^(id res){
    }];
    [self resetTabviews];
}

- (void)resetTabviews{
    NSArray *exitViewArray = [self.tabScroll allSubviews];
    for (UIView *tempVeiw in exitViewArray) {
        if ([tempVeiw isKindOfClass:[UIButton class]]) {
            [tempVeiw removeFromSuperview];
        }
    }
    NSArray *temarray = [self.groupInfo.m_strCustomerTag componentsSeparatedByString:@"|"];
    NSInteger  tabX = 0;
    NSInteger tabY=  0;
    NSInteger tabHeight = 40;
    
    for (int i = 0; i<temarray.count; i ++){
        NSString *tempStr = [temarray objectAtIndex:i];
        NSInteger tabLength = [self calutabWidt:tempStr];
        
        if (tabX + tabLength +  KMargeX *1.5 > self.tabScroll.width) {
            tabX = 0 ;
            tabY = tabY + 35;
            tabHeight = tabHeight + 35;
        }
        UIButton *tabButton = [self createBtn:CGRectMake(tabX + KMargeX *1.5, tabY + KMargeX, tabLength, 24) titleValue:tempStr];
        [self.tabScroll addSubview:tabButton];
        tabX = tabX + KMargeX *1.5 + tabLength;
    }
    [self.tabScroll setContentSize:CGSizeMake(self.tabScroll.width, tabHeight)];
}

- (NSInteger )calutabWidt:(NSString *)tabStr{
    if (tabStr.length > 0) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],};
        CGSize textSize = [tabStr boundingRectWithSize:CGSizeMake(200, 30) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;;
        return KMargeX * 2 + textSize.width;
    }else{
        return 0;
    }
}

- (UIButton *)createBtn:(CGRect )frame titleValue:(NSString *)titleValue{
    UIButton *tempButton = [[UIButton alloc] initWithFrame:frame];
    [tempButton setTitle:titleValue forState:UIControlStateNormal];
    [tempButton setBackgroundImage:[UIImage ms_imageWithColor:RGB(215, 230, 256)] forState:UIControlStateNormal];
    [tempButton setTitleColor:RGB(159, 180, 230) forState:UIControlStateNormal];
    [tempButton setTintColor:RGB(157, 190, 243)];
    tempButton.layer.cornerRadius  = 3;
    tempButton.layer.masksToBounds = YES;
    tempButton.enabled = NO;
    tempButton.titleLabel.font = [UIFont systemFontOfSize:14];
    tempButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [tempButton setTitle:titleValue forState:UIControlStateNormal];
    return tempButton;
}

-(void)shakeView:(UIView*)viewToShake{
    CGFloat t =2.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}

- (void)addTabClicck:(UIButton *)sender{
    PersonTabMangerController *tempController = [[PersonTabMangerController alloc] initWithMemberInfo:self.memberInfo customerTag:self.groupInfo.m_strCustomerTag];
    [self.navigationController pushViewController:tempController animated:YES];
}

#pragma mark  actionsheet
#pragma mark - DLCImagePickerDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self showActionSheet:@"备注名"];
    return NO;
}

- (void)showActionSheet:(NSString *)titleStr{
    if(IOS8){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"修改%@",titleStr] message:@"\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
        UITextField * text = [[UITextField alloc] initWithFrame:CGRectMake(12, 64, 240, 35)];//wight = 270;
        text.placeholder = [NSString stringWithFormat:@"请输入你要修改的%@",titleStr];
        text.borderStyle = UITextBorderStyleRoundedRect;//设置边框的样式
        [alert.view addSubview:text];
        
        UIAlertAction *submietaction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *sendMessage = text.text;
            CIM_ModGrpInfo *tempGrou = [[CIM_ModGrpInfo alloc] init];
            tempGrou.m_n64UserID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
            tempGrou.m_n64GroupID = self.groupInfo.m_n64GroupID;
            tempGrou.m_wModType = 1;
            tempGrou.m_strNewText = sendMessage;
            self.hudProgress.label.text = @"修改中，请稍等";
            [self.hudProgress showAnimated:YES];
            [tempGrou setCompletionBlock:^(NSData *responseData, BOOL success){
                [self.hudProgress hideAnimated:YES];
                if(success){
                    self.groupInfo.m_strPeerRemark = sendMessage;
                    [[EMCommData sharedEMCommData] updateGroup: self.groupInfo];
                    self.memberInfo.Gm_strPeerRemark = sendMessage;
                    [[EMCommData sharedEMCommData] updateMemberInfo:self.memberInfo];
                    self.signedField.text = sendMessage;
                    self.namelb.text = [self.memberInfo getNickName];
                }else{
                    NSLog(@"保存失败");
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
