//
//  CreateGroupController.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/27.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "CreateGroupController.h"
#import "EMCommData.h"
#import "ContractCell.h"
#import "UIImage+Utility.h"
#import <EMSpeed/MSUIKitCore.h>
#import "CommDataModel.h"
#import <EMSpeed/BDKNotifyHUD.h>
#import "UIAlert+Custom.h"
#import <MBProgressHUD.h>
#import "InputHelper.h"
#import "NIDropDown.h"
#import "ServiceContainController.h"
#define MEMBERLISTCELLINDENT @"memberindentifier"

@interface CreateGroupController ()<UITableViewDelegate,UITableViewDataSource,ContractCellDelegate,NIDropDownDelegate>
@property (nonatomic, strong)  UITextField *inputText;
@property (nonatomic, strong)  UITableView *selectTable;
@property (nonatomic, strong) NSMutableArray <CGroup *>*memberlist;
@property (nonatomic, strong) UIButton *deleBtn;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) CMassGroup *massGroup;
@property (nonatomic, strong) MBProgressHUD *showhud;
@property (nonatomic, strong) UIButton *selectTypeBtn;
@property (nonatomic, strong) NIDropDown *dropDownView;
@property (nonatomic, assign) NSInteger currentType;
@property (nonatomic, assign) BOOL isModify;
@end

@implementation CreateGroupController

- (id)initWithMassGroup:(CMassGroup *)massGroup{
    self = [super init];
    if (self) {
        self.massGroup = massGroup;
        if (massGroup.m_n64BatGroupID >0) {
            self.isModify = YES;
            self.title  =@"编辑群";
        }else{
            self.isModify = NO;
            self.title  =@"建群";
        }
        self.currentType = 0;
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        self.massGroup = [[CMassGroup alloc] init];
        self.isModify = NO;
        self.title  =@"建群";
        self.currentType = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *tempView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    
    self.selectTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 59)];
    [self.selectTypeBtn setTitle:@"全部专员" forState:UIControlStateNormal];
    self.selectTypeBtn.titleLabel.font  =[UIFont systemFontOfSize:15];
    [self.selectTypeBtn setImage:[UIImage imageNamed:@"dropIcon"] forState:UIControlStateNormal];
    self.selectTypeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.selectTypeBtn.frame.size.width - self.selectTypeBtn.imageView.frame.origin.x - self.selectTypeBtn.imageView.frame.size.width, 0, 0);
    self.selectTypeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -(self.selectTypeBtn.frame.size.width - self.selectTypeBtn.imageView.frame.size.width )/2 + 10, 0, 0);
    self.selectTypeBtn.backgroundColor = RGB(248, 248, 248);
    [self.selectTypeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.selectTypeBtn addTarget:self action:@selector(selectTypeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [tempView addSubview:self.selectTypeBtn];
    
    self.inputText = [[UITextField alloc] initWithFrame:CGRectMake(self.selectTypeBtn.right +10, 0, self.view.frame.size.width - self.dropDownView.right,59)];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 59, self.view.size.width, 1)];
    lineView.backgroundColor = RGB(248, 248, 248);
    [tempView addSubview:lineView];
    UIBarButtonItem *ringhtBar = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllPerson:)];
    self.navigationItem.rightBarButtonItem  = ringhtBar;
    self.inputText.placeholder = @"填写群名称";
    self.inputText.font = [UIFont systemFontOfSize:14];
    [tempView addSubview:self.inputText];

    self.selectTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height - 60)];
    [self.view addSubview:self.selectTable];
    self.selectTable.tableHeaderView = tempView;

    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    if(self.isModify){
        self.deleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 60)];
        [self.deleBtn setTitle:@"删除当前群组" forState: UIControlStateNormal];
        [self.deleBtn setBackgroundImage:[UIImage ms_imageWithColor:RGB(238, 244, 255)] forState:UIControlStateNormal];
        [self.deleBtn addTarget:self action:@selector(deleEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleBtn setTitleColor:RGB(55, 102, 180) forState:UIControlStateNormal];
            [bottomView addSubview:self.deleBtn];
        self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, 60)];
         self.inputText.enabled =NO;
    }else{
        self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, 60)];
    }
    [self.saveBtn setBackgroundImage:[UIImage ms_imageWithColor:RGB(55, 102, 180)] forState:UIControlStateNormal];
    [self.saveBtn setTitle:@"保存" forState: UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(savedEvent:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.saveBtn];
    
    [self.view addSubview:bottomView];
    self.selectTable.dataSource =self;
    self.selectTable.delegate = self;
    if (self.massGroup.m_aGroupID.count > 0) {
        self.inputText.text = self.massGroup.m_strName;
    }
    self.memberlist =[NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getGroupList]];
    [self.selectTable reloadData];
    
    self.showhud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.showhud];
    self.showhud.mode = MBProgressHUDModeIndeterminate;
}

- (void)selectTypeEvent:(id)sender{
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"全部专员", @"客服专员", @"产品专员",nil];
    if(self.dropDownView == nil) {
        self.dropDownView = [[NIDropDown alloc] showDropDown:sender showview:self.view :arr :nil :@"down"];
        self.dropDownView.backgroundColor = RGB(248, 248, 248);
        self.dropDownView.delegate = self;
    }
    else {
        [self.dropDownView hideDropDown:sender];
        self.dropDownView = nil;
    }
}

- (void)niDropDownDelegateMethod: (NIDropDown *) sender selectedInde:(NSInteger)indexValue {
    self.dropDownView = nil;
    if (indexValue == self.currentType) {
        return;
    }
    self.currentType = indexValue;
    
    if (self.currentType == 0) {
       self.memberlist = [NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getGroupList]];
    }else {
        NSArray *newArray = [NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getGroupList]];
        self.memberlist = [NSMutableArray array];
        for (CGroup *tempGroup in newArray) {
            if(self.currentType ==1){
                if (!tempGroup.m_MutilpGroup) {
                    [self.memberlist addObject:tempGroup];
                }
            }else{
                if (tempGroup.m_MutilpGroup) {
                    [self.memberlist addObject:tempGroup];
                }
            }
        }
    }
    self.currentType = indexValue;
    [self.selectTable reloadData];
}

- (void)selectAllPerson:(UIButton *)sender{
    [self.massGroup.m_aGroupID removeAllObjects];
    for ( CGroupMember *tempMember in self.memberlist) {
        NSNumber *temNumber = [NSNumber numberWithLongLong:tempMember.m_n64GroupID];
        [self.massGroup.m_aGroupID addObject:temNumber];
    }
    UIBarButtonItem *ringhtBar = [[UIBarButtonItem alloc] initWithTitle:@"全不选" style:UIBarButtonItemStylePlain target:self action:@selector(selectNoPerson:)];
    self.navigationItem.rightBarButtonItem  = ringhtBar;
    
    [self.selectTable reloadData];
}

- (void)selectNoPerson:(UIButton *)sender{
    [self.massGroup.m_aGroupID removeAllObjects];
    UIBarButtonItem *ringhtBar = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllPerson:)];
    self.navigationItem.rightBarButtonItem  = ringhtBar;
    [self.selectTable reloadData];
}

- (void)deleEvent:(id)sender{
    __block __typeof(self)weakSelf = self;
    showAlert4(@"删除", @"是否删除本群组！",  weakSelf,  100,  @"取消", @"确认", nil);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==100) {
        if (buttonIndex==1) {
            CIM_DelBatGroup *tempModift = [[CIM_DelBatGroup alloc] init];
            tempModift.m_n64UserID = [[EMCommData sharedEMCommData] getUserId];
            self.massGroup.m_strName = self.inputText.text;
            tempModift.m_n64BatGroupID = self.massGroup.m_n64BatGroupID;
            self.showhud.label.text = @"删除信息中";
            [self.showhud showAnimated:YES];
            __weak typeof(self) weakself = self;
            [tempModift setCompletionBlock:^(NSData *responseData, BOOL success){
                if (success){
                    [weakself.showhud hideAnimated:YES];
                    [weakself.navigationController popViewControllerAnimated:YES];
                }
            }];
            [tempModift sendSockPost];
        }
    }
}

- (void)savedEvent:(id)sender{
    if (self.inputText.text.length <=0) {
       [BDKNotifyHUD showNotifHUDWithText:@"请输入群组名称"];
        return;
    }
    
    if (self.massGroup.m_aGroupID &&self.massGroup.m_aGroupID.count >0) {
        if (self.isModify) {
            CIM_ModBatGroup *tempModift = [[CIM_ModBatGroup alloc] init];
            tempModift.m_n64UserID = [[EMCommData sharedEMCommData] getUserId];
            self.massGroup.m_strName = self.inputText.text;
            tempModift.m_MassGroup = self.massGroup;
            self.showhud.label.text = @"修改信息中";
            [self.showhud showAnimated:YES];
            __weak typeof(self) weakself = self;
            [tempModift setCompletionBlock:^(NSData *responseData, BOOL success){
                    [weakself.showhud hideAnimated:YES];
                if (success){
                    [weakself.navigationController popViewControllerAnimated:YES];
                }
            }];
            [tempModift sendSockPost];
        }else{
            CIM_CreateBatGroup *tempCreate = [[CIM_CreateBatGroup alloc] init];
            tempCreate.m_n64UserID = [[EMCommData sharedEMCommData] getUserId];
            self.massGroup.m_strName = self.inputText.text;
            tempCreate.m_MassGroup = self.massGroup;
            self.showhud.label.text = @"修改信息中";
            [self.showhud showAnimated:YES];
            __weak typeof(self) weakself = self;
            [tempCreate setCompletionBlock:^(NSData *responseData, BOOL success){
                [weakself.showhud hideAnimated:YES];
                if (success){
                    NSArray *tempViewArray = [weakself.navigationController viewControllers];
                    for (UIViewController *tempViewController in tempViewArray) {
                        if ([tempViewController isKindOfClass:[ServiceContainController class]]) {
                            [weakself.navigationController popToViewController:tempViewController animated:YES];
                            return ;
                        }
                    }
                }
            }];
            [tempCreate sendSockPost];
        }
    }else{
        [BDKNotifyHUD showNotifHUDWithText:@"至少选择一名成员"];
        return;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.memberlist count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContractCell *tempcell = [tableView dequeueReusableCellWithIdentifier:MEMBERLISTCELLINDENT];
    if (!tempcell) {
        tempcell =[[ContractCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MEMBERLISTCELLINDENT];
    }
    CGroup *tempGroup = [self.memberlist objectAtIndex:indexPath.row];
    CGroupMember *tempMember = [tempGroup getCustomerInfo];
    tempcell.delegate = self;
    [tempcell upadteMemberInfo:tempMember];
    [tempcell setShowSelectedView:YES];
    if ([self.massGroup.m_aGroupID containsObject:[NSNumber numberWithLong:tempMember.m_n64GroupID]]) {
        [tempcell setselectedActive:YES];
    }else{
        [tempcell setselectedActive:NO];
    }
    return tempcell;
}

- (void)contractCellupdata:(bool)selected userInfo:(CGroupMember *)userInfo{
    NSNumber *temNumber = [NSNumber numberWithLongLong:userInfo.m_n64GroupID];
    if (selected) {
        [self.massGroup.m_aGroupID addObject:temNumber];
    }else{
        [self.massGroup.m_aGroupID removeObject:temNumber];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ContractCell ContractCellHeight];
}

- (bool)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeTapGusture doneBlock:^(id res){
    }];

}
@end
