//
//  EMLoginViewController.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/2.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "EMLoginViewController.h"
#import <PureLayout.h>
#import "UIImage+Utility.h"
#import <EMSpeed/MSUIKitCore.h>
#import "ChattingViewController.h"
#import "CommDataModel.h"
#import "EMCommData.h"
#import "ServiceContainController.h"
#import <MBProgressHUD.h>
#import "InputHelper.h"
#import "EMLocalSocketManaget.h"
#import <EMSpeed/BDKNotifyHUD.h>
@interface EMLoginViewController ()
@property (nonatomic, strong) UIView *iconView;
@property (nonatomic, strong) UITextField *userNameInput;
@property (nonatomic, strong) UITextField *passwordInput;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, assign) bool haspushed;
@property (nonatomic, strong) MBProgressHUD *showHud;
@property (nonatomic, strong) UIButton *isServicebtn;
@end

@implementation EMLoginViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeTapGusture doneBlock:^(id res){
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    self.iconView = [[UIView alloc] init];
    [self.view addSubview:self.iconView];
    
    self.userNameInput = [[UITextField alloc] init];
    self.userNameInput.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    self.passwordInput = [[UITextField alloc] init];
    self.passwordInput.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    self.loginBtn = [[UIButton alloc] init];
    self.loginBtn.backgroundColor = [UIColor colorWithRed:56/255.0 green:104/255.0 blue:192/255.0 alpha:1];
    [self.view addSubview:self.iconView];
    [self.view addSubview:self.userNameInput];
    [self.view addSubview:self.passwordInput];
    [self.view addSubview:self.loginBtn];
    
    [self.iconView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:125];
    [self.iconView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    self.iconView.backgroundColor = [UIColor whiteColor];
    [self.iconView autoSetDimensionsToSize:CGSizeMake(75, 75)];
    self.iconView.layer.cornerRadius = 75/2.0;
    [self.iconView.layer setContents:(id)[UIImage imageNamed:@"Icon"].CGImage];
    
    [self.userNameInput autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.iconView withOffset:25];
    [self.userNameInput autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.userNameInput autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.userNameInput autoSetDimension:ALDimensionHeight toSize:50];
     self.userNameInput.keyboardType = UIKeyboardTypeASCIICapable;

    UILabel *leftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
    leftView.backgroundColor = [UIColor clearColor];
    leftView.text = @"  用户名";
    leftView.textAlignment = NSTextAlignmentLeft;
    leftView.textColor =  RGB(150,150,150);
    self.userNameInput.leftView = leftView;
    self.userNameInput.leftViewMode = UITextFieldViewModeAlways;
    leftView.font = [UIFont systemFontOfSize:15];
    
    [self.passwordInput autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.userNameInput withOffset:1];
    [self.passwordInput autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.passwordInput autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.passwordInput autoSetDimension:ALDimensionHeight toSize:50];
    self.passwordInput.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordInput.secureTextEntry =YES;
    
    UILabel *rightView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
    rightView.backgroundColor = [UIColor clearColor];
    rightView.text = @"  密码";
    rightView.textAlignment = NSTextAlignmentLeft;
    rightView.textColor = RGB(150,150,150);
    self.passwordInput.leftView = rightView;
    self.passwordInput.leftViewMode = UITextFieldViewModeAlways;
    rightView.font = [UIFont systemFontOfSize:15];
    
    
    self.isServicebtn = [[UIButton alloc] init];
    [self.view addSubview:self.isServicebtn];
    UILabel *templb = [[UILabel alloc] init];
    [self.view addSubview:templb];
    
    self.loginBtn =  [[UIButton alloc] init];
    [self.view addSubview:self.loginBtn];
    
    [self.isServicebtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.passwordInput withOffset:8];
    [self.isServicebtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:25];
    [self.isServicebtn autoSetDimension:ALDimensionWidth toSize:20];
    [self.isServicebtn autoSetDimension:ALDimensionHeight toSize:20];
    [self.isServicebtn setBackgroundImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
    [self.isServicebtn setBackgroundImage:[UIImage imageNamed:@"checkselected"] forState:UIControlStateSelected];
    [self.isServicebtn addTarget:self action:@selector(isServeicebtnevent:) forControlEvents:UIControlEventTouchUpInside];
    [self.isServicebtn setTitleColor:[UIColor whiteColor ] forState:UIControlStateNormal];
    self.isServicebtn.selected = YES;
    
    [templb autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.passwordInput withOffset:8];
    [templb autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.isServicebtn withOffset:10];
    [templb autoSetDimension:ALDimensionWidth toSize:150];
    [templb autoSetDimension:ALDimensionHeight toSize:20];
    templb.text = @"客服端";
    templb.font = [UIFont systemFontOfSize:13];
    templb.textColor = [UIColor blackColor];
//    [[NSUserDefaults standardUserDefaults] setObject:_m_strName forKey:@"UserName"];
//    [[NSUserDefaults standardUserDefaults] setObject:_m_strPassword forKey:@"Password"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_m_nPlatformID] forKey:@"PlatformID"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    if (userName) {
        self.userNameInput.text = userName;
    }
    [self.loginBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.passwordInput withOffset:55];
    [self.loginBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15];
    [self.loginBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15];
    [self.loginBtn autoSetDimension:ALDimensionHeight toSize:50];
    [self.loginBtn setBackgroundImage:[UIImage ms_imageWithColor: RGB(56,104,193)] forState:UIControlStateNormal];
    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:[UIColor whiteColor ] forState:UIControlStateNormal];
    self.loginBtn.layer.cornerRadius = 3;
    self.loginBtn.layer.masksToBounds = YES;
    [self.loginBtn addTarget:self action:@selector(loginEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationController.navigationBarHidden = YES;
    
//    self.userNameInput.text = @"limengmeng";
//    self.passwordInput.text = @"111111";
    self.showHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.showHud];
    self.showHud.mode = MBProgressHUDModeIndeterminate;
}

- (void)isServeicebtnevent:(UIButton *)sender{
    self.isServicebtn.selected = !self.isServicebtn.selected;
}

- (void)loginEvent:(id)sender{
    if(sender){
        [[EMLocalSocketManaget sharedSocketManaget] resetAllSocket];
        [[EMCommData sharedEMCommData] clearAlldata];
        CIM_LoginData *tempLogin = [[CIM_LoginData alloc] init];
        if(self.userNameInput.text.length ==0){
            [BDKNotifyHUD showNotifHUDWithText:@"用户名不能为空"];
            return;
        }
        if(self.passwordInput.text.length ==0){
            [BDKNotifyHUD showNotifHUDWithText:@"密码不能为空"];
            return;
        }
        tempLogin.m_strName = self.userNameInput.text;
        tempLogin.m_strPassword = self.passwordInput.text;
        if (self.isServicebtn.selected) {
           tempLogin.m_nPlatformID = 2;
        }else{
           tempLogin.m_nPlatformID = 1;
        }
        self.haspushed = NO;
        self.showHud.label.text  =@"登陆中,请稍等";
        [self.showHud showAnimated:YES];
        ChattingViewController *tempChatting = [[ChattingViewController alloc] initWithInputBox:YES];
        [tempLogin setCompletionBlock:^(NSData *responseData, BOOL success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.showHud hideAnimated: YES];
                if(success&&self){
                    NSArray *tempArray = [[EMCommData sharedEMCommData] getGroupList];
                    if (tempArray.count >0 &&tempLogin.m_nPlatformID == 1&&!self.haspushed) {
                        CRecvGroupMember *tempgroup = [tempArray objectAtIndex:0];
                        tempChatting.chattinggoup = [[CGroupBase alloc ]init];
                        tempChatting.chattinggoup.m_n64GroupID = tempgroup.m_n64GroupID;
                        self.haspushed = YES;
                        [self.navigationController pushViewController:tempChatting animated:YES];
                    }else if (tempLogin.m_nPlatformID ==2&&!self.haspushed){
                        ServiceContainController *tempController = [[ServiceContainController alloc] init];
                        self.haspushed = YES;
                        [self.navigationController pushViewController:tempController animated:YES];
                    }
                }
            });
        }];
        [tempLogin sendSockPost];
    }
}

- (void)reLongInUserName:(NSString *)usrName passWord:(NSString *)password{
    self.userNameInput.text = usrName;
    self.passwordInput.text = password;
}
@end
