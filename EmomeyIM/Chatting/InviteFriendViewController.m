//
//  InviteFriendViewController.m
//  EmomeyIM
//
//  Created by yourongrong on 2016/10/26.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "InviteFriendViewController.h"
#import "EMCommData.h"
#import <EMSpeed/MSUIKitCore.h>
#import "ContractSecondCell.h"
#import "InputHelper.h"
#import "UIAlert+Custom.h"
@interface InviteFriendViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, strong) NSArray *searchData;
@property (nonatomic, strong) UITableView *contactlisttable;
@property (nonatomic, strong) UISearchBar *searchbar;
@property (nonatomic, strong) CGroupMember *selectedMember;
@property (nonatomic, strong) NSMutableArray *contractlist;
@property (nonatomic, strong) NSMutableArray *exceptedArray;
@end

@implementation InviteFriendViewController

- (id)initWithExceptGroupid:(NSArray *)exceptGroups{
    self = [super init];
    if (self) {
        self.title = @"联系人";
        self.exceptedArray = [NSMutableArray arrayWithArray:exceptGroups];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contactlisttable  = [[UITableView alloc] init];
    self.contactlisttable.delegate = self;
    self.contactlisttable.dataSource  =self;
    
    self.contactlisttable.backgroundColor = [UIColor whiteColor];
    [self.contactlisttable setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
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
    self.contractlist =[NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getMembersEecept:self.exceptedArray]];
    [self.contactlisttable reloadData];
    self.searchbar.placeholder = [NSString stringWithFormat:@"搜索(共%lu联系人)", (unsigned long)self.contractlist.count] ;
    self.isSearch = NO;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isSearch){
        return self.searchData.count;
    }else{
        return self.contractlist.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGroupMember *)getOtherMember:(NSMutableArray *)memberlist{
    for (CGroupMember *temMember in memberlist){
        if (temMember.m_n64UserID != [[EMCommData sharedEMCommData] getUserId] ) {
            return temMember;
        }
    }
    return nil;
}

- (void)actionCellAvatarButton:(UIButton *)btn {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *contractident = @"ContactIndentifier";
    ContractSecondCell *tempCell = [tableView  dequeueReusableCellWithIdentifier:contractident];
    if (tempCell == nil) {
        tempCell = [[ContractSecondCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contractident];
    }
    CGroupMember *tempMember;
    if (self.isSearch) {
        tempMember =[self.searchData objectAtIndex:indexPath.row];
    }else{
        tempMember =[self.contractlist objectAtIndex:indexPath.row];
    }
    [tempCell upadteMemberInfo:tempMember];
    return tempCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ContractSecondCell ContractSecondCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CGroupMember *tempMember =nil;
    if (self.isSearch) {
        tempMember =[self.searchData objectAtIndex:indexPath.row];
    }else{
        tempMember =[self.contractlist objectAtIndex:indexPath.row];
    }
    self.selectedMember = tempMember;
    __block __typeof(self)weakSelf = self;
    showAlert4(@"消息转发",[NSString stringWithFormat:@"是否转发给：%@",[tempMember getTagGroupName]],  weakSelf,  100,  @"取消", @"确定", nil);
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.contactlisttable) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - alertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==100) {
        if(buttonIndex ==1){
            [self.delegate confirmInviteFriend:self.selectedMember];
            [self.navigationController popViewControllerAnimated:YES];
        }
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
        // 定义搜索谓词
        NSPredicate* pred = [NSPredicate predicateWithFormat:
                             @"m_strNickName CONTAINS[c] %@",filterBySubstring];
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
