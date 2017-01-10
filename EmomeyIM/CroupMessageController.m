//
//  CroupMessageController.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/28.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "CroupMessageController.h"
#import "InputBoxOptionView.h"
#import "EMCommData.h"
#import "InputHelper.h"
#import "CommDataModel.h"
#import "ContractController.h"
#import <EMSpeed/BDKNotifyHUD.h>
#import <MBProgressHUD.h>
#import "TTLoochaStyledTextLabel.h"
#import "TTLoochaStyledText.h"
#import <EMSpeed/MSUIKitCore.h>
@interface CroupMessageController ()<FreshInputBoxControllerDelegate,FreshInputBoxSeparatedlySender,GroupIconViewDelegate>
@property (nonatomic, strong) GroupIconView *headView;
@property (nonatomic, strong) UILabel *namelb;
@property (nonatomic, strong) CustomResponderTextView *inputView;
@property (nonatomic, strong) ChattingInputBoxController *inputBoxController;
@property (nonatomic, strong) CMassGroup *massGroupdata;
@property (nonatomic, strong) NSMutableArray *memberlist;
@property (nonatomic, strong) UITableView *messagetableView;
@property (nonatomic, strong) MBProgressHUD *progressHud;
@end

@implementation CroupMessageController
- (id)initWithMassGroup:(CMassGroup *)massGroup{
    self = [super init];
    if (self) {
        self.massGroupdata = massGroup;
        self.memberlist = [NSMutableArray array];
        self.title  =@"群发";
        _inputBoxController = [[ChattingInputBoxController alloc] initWithParent:self options:kInputBoxOption_Default];
        _inputBoxController.delegate = self;
        self.inputBoxController.separatedlySender = self;
        for (int i = 0; i < self.massGroupdata.m_aGroupID.count; i++) {
            NSNumber *tempGroupid = [self.massGroupdata.m_aGroupID objectAtIndex:i];
            CGroupMember *tempMember = [[EMCommData sharedEMCommData] getMemberByGroupId:tempGroupid.longLongValue];
            if (tempMember) {
                [self.memberlist addObject:tempMember];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat barHeight = self.navigationController.navigationBar.frame.size.height  + 20;
    self.view.backgroundColor = [UIColor  whiteColor];
    self.namelb = [[UILabel alloc] initWithFrame:CGRectMake(15, barHeight + 10 , self.view.frame.size.width - 30, 25)];
    self.headView = [[GroupIconView alloc] initWithFrame:CGRectMake(5, barHeight + 45, self.view.frame.size.width, 60)];
    self.headView.delegate = self;
    self.namelb.text = self.massGroupdata.m_strName;
    self.namelb.textColor = [UIColor blackColor];
    self.namelb.font = [UIFont systemFontOfSize:18];
    [self.headView setShowTpy:GroupType_More];
    [self.headView setGroupMemberList:self.memberlist];
    self.inputView = [[CustomResponderTextView alloc] initWithFrame:CGRectMake(15, barHeight + 115, self.view.frame.size.width - 30, 100)];
    self.inputView.textColor = [UIColor blackColor];
    self.inputView.editable =NO;
//    self.inputView.num
    [self.view addSubview:self.namelb];
    [self.view addSubview:self.headView];
    [self.view addSubview:self.inputView];
    if (_inputBoxController) {
        self.view.backgroundColor = [UIColor whiteColor];
        [_inputBoxController showInContextView:self.view options:InputBoxOption( kInputBoxOption_PickPhoto | kInputBoxOption_TakePhoto)];
        [_inputBoxController observeTapInView:self.inputView];
    }
    self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progressHud];
    self.progressHud.mode = MBProgressHUDModeIndeterminate;
}

#pragma mark - GroupIconViewMoreEvent
- (void) GroupIconViewMoreEvent:(UIButton *)sender{
    ContractController *tempController = [[ContractController alloc] initWithMassGroup:self.massGroupdata ];
    [self.navigationController pushViewController:tempController animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (NSString*)getDraft {
    return @"";
}

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController didChangeFrame:(CGRect)inputBoxFrame {
    CGRect r = self.view.bounds;
}

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    self.inputView.text= [self.inputView.text stringByReplacingCharactersInRange:range withString:text];
}

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController sendText:(NSString *)text{
    [inputBoxController.inputBox.textView resignFirstResponder];
    if (text) {
        self.inputView.textColor =[UIColor blackColor];
        CNewMsg *tempMsg  = [[CNewMsg alloc] init];
        tempMsg.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        NSDate *nowDate = [NSDate date];
        NSTimeInterval timeInterval = [nowDate timeIntervalSince1970];
        tempMsg.m_dwExprSeconds  =  timeInterval;
        tempMsg.m_strMsgText = [NSString stringWithFormat:@"%@ ",text];
        tempMsg.m_sMsgType  = 1;
        CMsgItem *tempMsgitem = [[CMsgItem alloc] init];
        [tempMsgitem createMsgItem:MSG_ITEM_TEXT int64:0 strItem:text];
        [tempMsg.m_aItem addObject:tempMsgitem];
        CIM_MsgData *tempMsgData = [[CIM_MsgData alloc] init];
        tempMsgData.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        tempMsgData.m_dwExprSeconds  =  timeInterval;
        tempMsgData.m_msg = tempMsg;
        if (self.massGroupdata.m_n64BatGroupID >0) {
            tempMsgData.m_n64BatGroupID = self.massGroupdata.m_n64BatGroupID;
            tempMsgData.m_cType = 2;
        }else{
            tempMsgData.m_cType = 1;
            tempMsgData.m_aGroupID = [NSMutableArray arrayWithArray:self.massGroupdata.m_aGroupID];
        }
        self.progressHud.label.text = @"消息发送中";
        [self.progressHud showAnimated:YES];
        [tempMsgData setCompletionBlock:^(NSData *responseData, BOOL success){
            [self.progressHud hideAnimated:YES];
            if (success) {
                [BDKNotifyHUD showNotifHUDWithText:@"发送成功"];
            }
//            else{
//                [BDKNotifyHUD showNotifHUDWithText:@"发送失败"];
//            }
        }];
        [tempMsgData sendSockPost];
    }
}

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController sendAttachment:(ContentInfo *)attachment{
    [inputBoxController.inputBox.textView resignFirstResponder];
    CIM_UploadData *tempFile = [[CIM_UploadData alloc] init];
    EMFileData *tempimage = [[EMFileData alloc] init];
    [tempimage readFile:attachment.thumpPath];
    tempFile.m_Data = tempimage;
    tempFile.m_cFileType = attachment.fileType;
    tempFile.m_strFileName = attachment.fileExtra;
    tempFile.m_n64UserID  = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
    [tempFile  setUploadCompletion: ^(CIM_UploadData *responseData, BOOL success){
        CNewMsg *tempMsg  = [[CNewMsg alloc] init];
        tempMsg.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        NSDate *nowDate = [NSDate date];
        NSTimeInterval timeInterval = [nowDate timeIntervalSince1970];
        tempMsg.m_dwExprSeconds  =  timeInterval;
        tempMsg.m_strMsgText = [NSString stringWithFormat:@"[2,%lld.png]",responseData.m_n64FileID];
        tempMsg.m_sMsgType  = 1;
        CMsgItem *tempMsgitem = [[CMsgItem alloc] init];
        [tempMsgitem createMsgItem:MSG_ITEM_TEXT int64:0 strItem:[NSString stringWithFormat:@"[2,%lld.png]",responseData.m_n64FileID]];
        [tempMsg.m_aItem addObject:tempMsgitem];
        CIM_MsgData *tempMsgData = [[CIM_MsgData alloc] init];
        tempMsgData.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        tempMsgData.m_dwExprSeconds  =  timeInterval;
        tempMsgData.m_msg = tempMsg;
        if (self.massGroupdata.m_n64BatGroupID >0) {
            tempMsgData.m_n64BatGroupID = self.massGroupdata.m_n64BatGroupID;
            tempMsgData.m_cType = 2;
        }else{
            tempMsgData.m_cType = 1;
            tempMsgData.m_aGroupID = [NSMutableArray arrayWithArray:self.massGroupdata.m_aGroupID];
        }
        self.inputView.textColor =[UIColor blackColor];
        [tempMsgData setCompletionBlock:^(NSData *responseData, BOOL success){
            if (success) {
                [BDKNotifyHUD showNotifHUDWithText:@"发送成功"];
            }
//            else{
//                [BDKNotifyHUD showNotifHUDWithText:@"发送失败"];
//            }
        }];
        [tempMsgData sendSockPost];
        tempMsg.msg_Status = MSG_STATUS_Sending;
    }];
    [tempFile startUploadFile];
}
@end
