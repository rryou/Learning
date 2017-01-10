//
//  ServiceContainController.m
//  
//
//  Created by 尤荣荣 on 16/9/26.
//
//
#import "ServiceContainController.h"
#import "EMCommData.h"
#import "NYSegmentedControl.h"
#import <EMSpeed/MSUIKitCore.h>
#import "ChatGroupCell.h"
#import "ContractCell.h"
#import "ChattingViewController.h"
#import "CreateGroupController.h"
#import "CroupMessageController.h"
#import "InputHelper.h"
#import "CommDataModel.h"
#import <MBProgressHUD.h>
#import "PersonEditController.h"
#import "YCXMenu.h"
#import "TabTempGroupController.h"
#import "PersonCentreController.h"
#import "ContractController.h"
@interface ServiceContainController ()<UITableViewDelegate,UITableViewDataSource,ChatGroupCellDelegate,UISearchBarDelegate>
@property (nonatomic, strong) NYSegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *contactlisttable;
@property (nonatomic, strong) UITableView *chatGrouplisttable;
@property (nonatomic, strong) UISearchBar *searchbar;
@property (nonatomic, assign) UITableView *currentView;
@property (nonatomic, strong) NSMutableArray *contractlist;
@property (nonatomic, strong) NSMutableArray *chatGroupList;
@property (nonatomic, strong) MBProgressHUD *progresshud;
@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, strong) NSArray *searchData;
@property (nonatomic , strong) NSArray *items;
@property (nonatomic, assign) BOOL hsaloadGroups;
@end

#define KCONTACTCELLINDENTIFIER  @"ContactIndentifier"
#define kCHATGROUPCELLINDENTIFIER @"CHATGROUPInDentifier"

@implementation ServiceContainController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton =YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:54/255.0 green:104/255.0 blue:193/255.0 alpha:1.0]];
    
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarevent:)];
    self.navigationItem.rightBarButtonItem = addBtn;
    
    UIBarButtonItem *tempBar =   [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"EditSelfInfo"] style:UIBarButtonItemStylePlain target:self action:@selector(goEditSelfInfo:)];
    self.navigationItem.leftBarButtonItem = tempBar;
    
    self.segmentedControl = [[NYSegmentedControl alloc] initWithItems:@[@"联系人", @"群组"]];
    [self.segmentedControl addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.titleFont = [UIFont systemFontOfSize:16];
    self.segmentedControl.titleTextColor = RGB(197, 226, 246);
    self.segmentedControl.selectedTitleFont = [UIFont systemFontOfSize:16];
    self.segmentedControl.selectedTitleTextColor = RGB(115, 136, 173);
    self.segmentedControl.borderWidth = 15.0f;
    self.segmentedControl.borderColor =  RGB(54, 104, 193);
    self.segmentedControl.drawsGradientBackground = YES;
    self.segmentedControl.segmentIndicatorInset = 0.0f;
    self.segmentedControl.segmentIndicatorGradientTopColor =[UIColor whiteColor];
    self.segmentedControl.segmentIndicatorGradientBottomColor = [UIColor whiteColor];
    self.segmentedControl.drawsSegmentIndicatorGradientBackground = YES;
    self.segmentedControl.segmentIndicatorBorderWidth = 0.0f;
    self.segmentedControl.backgroundColor = [UIColor redColor];
    [self.segmentedControl sizeToFit];
    self.navigationItem.titleView = self.segmentedControl;
    self.contactlisttable  = [[UITableView alloc] init];
    self.contactlisttable.delegate = self;
    self.contactlisttable.dataSource  =self;
    
    self.contactlisttable.backgroundColor = [UIColor whiteColor];
    self.chatGrouplisttable = [[UITableView alloc] init];
    self.chatGrouplisttable.delegate  = self;
    self.chatGrouplisttable.dataSource =self;
    self.chatGrouplisttable.backgroundColor = [UIColor whiteColor];
    [self.contactlisttable setFrame:CGRectMake(0, 44 + 20, self.view.frame.size.width, self.view.frame.size.height - 20 - 44)];
    [self.chatGrouplisttable setFrame:self.view.frame];
    self.chatGrouplisttable.layer.borderWidth = 0;
    self.chatGrouplisttable.layer.borderColor = [UIColor clearColor].CGColor;
    [self.view addSubview:self.chatGrouplisttable];
    [self.view addSubview:self.contactlisttable];
    
    self.searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    self.searchbar.delegate =self;
    self.searchbar.barTintColor = RGB(225, 236, 255);
    self.searchbar.tintColor = RGB(197, 197, 197);
    self.searchbar.layer.borderWidth = 0;
    self.searchbar.layer.borderColor = [UIColor clearColor].CGColor;
    self.searchbar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchbar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.contactlisttable.tableHeaderView = self.searchbar;
    self.searchbar.searchBarStyle = UISearchBarStyleDefault;
    
    self.isSearch = NO;
    self.progresshud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progresshud];
    self.progresshud.mode = MBProgressHUDModeIndeterminate;
    
    self.segmentedControl.selectedSegmentIndex = 0;
    self.hsaloadGroups = NO;
    [self segmentSelected:self.segmentedControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessge:) name:NOTIFIMESSAGEUPDATEMESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateGroupInfo:) name:UpdateGroupNotice object:nil];
}

- (void)upDateGroupInfo:(NSNotification *)message{
    if (message.object) {
        NSNumber *tempNumber = message.object;
        NSMutableArray *tempArray =[NSMutableArray array];
        if (self.isSearch) {
            tempArray = [NSMutableArray arrayWithArray:self.searchData];
        }else{
            tempArray = [NSMutableArray arrayWithArray:self.contractlist];
        }
        for (int i = 0; i< tempArray.count; i ++) {
            CGroup *tempGroup = [tempArray objectAtIndex:i];
            if (tempGroup.m_n64GroupID == tempNumber.longLongValue) {
                CGroup *newGroup = [[EMCommData sharedEMCommData] getGroupbyid:tempGroup.m_n64GroupID];
                tempGroup.m_strPeerRemark = newGroup.m_strPeerRemark;
                 tempGroup.m_strCustomerTag = newGroup.m_strCustomerTag;
                 tempGroup.m_n64ReadGrpMsgID = newGroup.m_n64ReadGrpMsgID;
                 CGroupMember *m_aMember= [tempGroup getCustomerInfo];
                  m_aMember.Gm_strPeerRemark = tempGroup.m_strPeerRemark;
                 tempGroup.searchName = [m_aMember getNickName];
                [self.contactlisttable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)updateMessge:(NSNotification *)newMessage{
    if (newMessage.object) {
        NSNumber *tempNumber = newMessage.object;
        for (int i = 0; i< self.contractlist.count; i ++) {
            CGroup *tempGroup = [self.contractlist objectAtIndex:i];
            if (tempGroup.m_n64GroupID == tempNumber.longLongValue&& i <self.contractlist.count) {
                [self.contactlisttable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)goEditSelfInfo:(id)sender{
    PersonCentreController *tempPerson = [[PersonCentreController alloc] initWithUserInfo:[[EMCommData sharedEMCommData] selfUserInfo]];
    [self.navigationController pushViewController:tempPerson animated:YES];
    //进入个人信息页面
}

- (void)rightBarevent:(UIBarButtonItem *)sender{
    [YCXMenu setHasShadow:YES];
    [YCXMenu setTintColor:[UIColor whiteColor]];
    [YCXMenu showMenuInView:self.view fromRect:CGRectMake(self.view.frame.size.width - 80, 64, 70, 0) menuItems:self.items selected:^(NSInteger index, YCXMenuItem *item) {
        NSLog(@"%@",item);
    }];
}

- (NSArray *)items {
    if (!_items) {
        YCXMenuItem *menuGroupTitle = [YCXMenuItem menuItem:@"建群" image:[UIImage imageNamed:@"menGroup"] target:self action:@selector(Creategroup:)];
        menuGroupTitle.foreColor = RGB(143, 151, 185);
        menuGroupTitle.titleFont = [UIFont boldSystemFontOfSize:14.0];
        menuGroupTitle.alignment = NSTextAlignmentCenter;
        
        YCXMenuItem *menuTabTitle = [YCXMenuItem menuItem:@"标签" image:[UIImage imageNamed:@"menuTag"] target:self action: @selector(groupTap:)];
        menuTabTitle.foreColor = RGB(143, 151, 185);
        menuTabTitle.titleFont = [UIFont boldSystemFontOfSize:13.0f];
        menuTabTitle.alignment = NSTextAlignmentCenter;
        _items = @[menuGroupTitle,menuTabTitle];
    }
    return _items;
}

- (void)Creategroup:(YCXMenuItem *)item{
    CreateGroupController *tempGroup = [[CreateGroupController alloc] init];
    [self.navigationController pushViewController:tempGroup animated:YES];
}

- (void)groupTap:(YCXMenuItem *)item{
   TabTempGroupController *tempMessage = [[TabTempGroupController alloc] init];
  [self.navigationController pushViewController:tempMessage animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeTapGusture doneBlock:^(id res){
    }];
    [self segmentSelected:self.segmentedControl];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (void)segmentSelected:(NYSegmentedControl *)sender{
    if(self.segmentedControl.selectedSegmentIndex == 0){
        self.contractlist =[NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getSortGroup]];
        [self.contractlist sortUsingComparator:^NSComparisonResult(CGroup *obj1, CGroup *obj2) {
            CGroupMember *m_aMember1= [obj1  getCustomerInfo];
            CGroupMember *m_aMember2= [obj2 getCustomerInfo];
            NSArray *tempMessage1 = [[EMCommData sharedEMCommData] getLimitMessagsByGroupId:m_aMember1.m_n64GroupID maxCount:1];
            NSArray *tempMessage2 = [[EMCommData sharedEMCommData] getLimitMessagsByGroupId:m_aMember2.m_n64GroupID maxCount:1];
            if (tempMessage2.count ==0||!tempMessage2) {
                return NSOrderedAscending;
            }
            if(tempMessage1.count ==0||!tempMessage1){
                return NSOrderedAscending;
            }
            CNewMsg *lastMessage1 = [tempMessage1 objectAtIndex:0];
            CNewMsg *lastMessage2 = [tempMessage2 objectAtIndex:0];
             return [lastMessage1 m_dwMsgSeconds]  <= [lastMessage2 m_dwMsgSeconds]? NSOrderedDescending : NSOrderedAscending;
        }];
        [self.contactlisttable reloadData];
        self.contactlisttable.hidden = NO;
        self.chatGrouplisttable.hidden =YES;
        for (CGroup *tempGroup in self.contractlist) {
            CGroupMember *m_aMember= [tempGroup getCustomerInfo];
            tempGroup.searchName = [m_aMember getNickName];
        }
        self.searchbar.placeholder = [NSString stringWithFormat:@"搜索(共%lu联系人)", (unsigned long)self.contractlist.count];
    }else{
        self.contactlisttable.hidden = YES;
        self.chatGrouplisttable.hidden =NO;
//        NSArray *tempArray =[[EMCommData sharedEMCommData] getMassGroup];
//        if ((!tempArray || tempArray.count ==0 )&&!self.hsaloadGroups) {
        self.progresshud.label.text = @"加载数据中";
        [self.progresshud showAnimated:YES];
        CIM_QueryBatGroup* pDataQuery2 =  [[CIM_QueryBatGroup alloc] init];
        if (pDataQuery2){
            pDataQuery2.m_n64UserID = [[EMCommData sharedEMCommData] selfUserInfo].m_n64AccountID;
            pDataQuery2.m_wStatus = WantSend;
            [pDataQuery2 setCompletionBlock:^(NSData *responseData, BOOL success){
                [self.progresshud hideAnimated: YES];
                if(success&&self){
                    self.hsaloadGroups =YES;
                    self.chatGroupList = [NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getMassGroup]];
                    [self.chatGrouplisttable reloadData];
                }
            }];
            [pDataQuery2 sendSockPost];
        }
//        }else{
//            [self.progresshud hideAnimated:YES];
//            self.chatGroupList =[NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getMassGroup]];
//            [self.chatGrouplisttable reloadData];
//        }
//    }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.contactlisttable) {
        if(self.isSearch){
            return self.searchData.count;
        }else{
            return self.contractlist.count;
        }
    }else{
        return self.chatGroupList.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//- (CGroupMember *)getOtherMember:(NSMutableArray *)memberlist{
//    for (CGroupMember *temMember in memberlist){
//        if (temMember.m_n64UserID != [[EMCommData sharedEMCommData] getUserId] ) {
//            return temMember;
//        }
//    }
//    return nil;
//}

- (void)actionCellAvatarButton:(UIButton *)btn {
   CGPoint pt = [self.contactlisttable convertPoint: btn.center fromView:btn];
   NSIndexPath *index = [self.contactlisttable indexPathForRowAtPoint:pt];
   CGroup  *tempGroup;
   if (self.isSearch) {
       tempGroup =[self.searchData objectAtIndex:index.row];
   }else{
       tempGroup =[self.contractlist objectAtIndex:index.row];
   }
    CGroupMember *temMember = [tempGroup getCustomerInfo];
    PersonEditController *tempPerson = [[PersonEditController alloc] initWithMember:temMember];
    [self.navigationController pushViewController:tempPerson animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.contactlisttable) {
        static NSString *contractident = @"ContactIndentifier";
        ContractCell *tempCell = [tableView  dequeueReusableCellWithIdentifier:contractident];
        if (tempCell == nil) {
            tempCell = [[ContractCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contractident];
        }
        CGroup  *tempGroup;
        if (self.isSearch) {
            tempGroup =[self.searchData objectAtIndex:indexPath.row];
        }else{
             tempGroup =[self.contractlist objectAtIndex:indexPath.row];
        }
        [tempCell.iconView setTarget:self selector:@selector(actionCellAvatarButton:)];
        [tempCell updateCGropInfo:tempGroup];
        return tempCell;
    }else if (self.chatGrouplisttable == tableView){
        ChatGroupCell *tempCell = [tableView  dequeueReusableCellWithIdentifier:kCHATGROUPCELLINDENTIFIER];
        if (!tempCell) {
            tempCell = [[ChatGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCHATGROUPCELLINDENTIFIER];
        }
        tempCell.delegate  = self;
        CMassGroup *tempGroup = [self.chatGroupList objectAtIndex:indexPath.row];
        [tempCell updateGroupCellMessage:tempGroup];
        return tempCell;
    }
    return nil;
}

- (void)ChatGroupCelevent:(ChatCellBtnType)btnType userInfo:(CMassGroup *)userInfo{
    if (btnType == ChatCellBtnType_Edit) {
        CreateGroupController *tempGroup = [[CreateGroupController alloc] initWithMassGroup:userInfo];
        [self.navigationController pushViewController:tempGroup animated:YES];
    }else if (btnType == ChatCellBtnType_Send){
        CroupMessageController *tempMessage = [[CroupMessageController alloc] initWithMassGroup:userInfo];
        [self.navigationController pushViewController:tempMessage animated:YES];
    }else if (btnType ==ChatCellBtnType_More){
        ContractController *tempController = [[ContractController alloc] initWithMassGroup:userInfo ];
        [self.navigationController pushViewController:tempController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.contactlisttable) {
        return [ContractCell ContractCellHeight];
    }else if (self.chatGrouplisttable == tableView){
        return [ChatGroupCell  ChatCroupHeight];
    }
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.contactlisttable) {
        CGroup *tempGroup;
        CGroupMember *tempMember =nil;
        if (self.isSearch) {
            tempGroup =[self.searchData objectAtIndex:indexPath.row];
        }else{
            tempGroup =[self.contractlist objectAtIndex:indexPath.row];
        }
        tempMember = [tempGroup getCustomerInfo];
        ChattingViewController *tempChatting = [[ChattingViewController alloc] initWithInputBox:YES];
        tempChatting.chattinggoup = [[EMCommData sharedEMCommData] getGroupbyid:tempMember.m_n64GroupID];
        tempChatting.chattinggoup.m_n64GroupID = tempMember.m_n64GroupID;
        [tempChatting setBackItemEnable:YES];
        [self.navigationController pushViewController:tempChatting animated:YES];
    }else if (self.chatGrouplisttable == tableView){
    }
}

- (bool)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
   if (tableView == self.contactlisttable) {
       return YES;
   }else{
       return YES;
   }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.isSearch = NO;
}

- (void)filterBySubstring:(NSString *)filterBySubstring{
    if (filterBySubstring.length == 0||!filterBySubstring) {
        _isSearch = NO;
    }else{
        NSLog(@"----filterBySubstring------");
        // 设置为搜索状态
        _isSearch = YES;
        // 定义搜索谓词 = [tempMember getNickName];
        NSPredicate* pred = [NSPredicate predicateWithFormat:
                             @"searchName CONTAINS[c] %@",filterBySubstring];
        // 使用谓词过滤NSArray
        _searchData =  [self.contractlist filteredArrayUsingPredicate:pred];
    }
    // 让表格控件重新加载数据
    [self.contactlisttable reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText{
    [self filterBySubstring:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"----searchBarSearchButtonClicked------");
    // 调用filterBySubstring:方法执行搜索
    [self filterBySubstring:searchBar.text];
    // 放弃作为第一个响应者，关闭键盘
    [searchBar resignFirstResponder];
}

@end
