//
//  ContractController.m
//  EmomeyIM
//
//  Created by yourongrong on 2016/10/25.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "ContractController.h"
#import "ContractSecondCell.h"
#import "EMCommData.h"
#import "UserInfo.h"
#import <EMSpeed/MSUIKitCore.h>
@interface ContractController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) CMassGroup *massGroupdata;
@property (nonatomic, strong) NSMutableArray *memberlist;
@property (nonatomic, strong) UITableView *messagetableView;
@end
@implementation ContractController

- (id)initWithMassGroup:(CMassGroup *)massGroup{
    self  =[super init];
    if (self) {
        self.title = @"群成员";
        self.massGroupdata = massGroup;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messagetableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50)];
    self.memberlist = [NSMutableArray array];
    self.messagetableView.delegate = self;
    self.messagetableView.dataSource = self;
    [self.view addSubview:self.messagetableView];
    for (NSNumber *temgGroupid in self.massGroupdata.m_aGroupID) {
        CGroupMember *tempGroup = [[EMCommData sharedEMCommData] getMemberByGroupId:temgGroupid.longLongValue];
        [self.memberlist addObject:tempGroup];
    }
    UILabel *bottomLb  = [[UILabel alloc ] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    [self.view addSubview:bottomLb];
    bottomLb.text = [NSString stringWithFormat:@"共%lu名群成员",(unsigned long)self.memberlist.count];
    bottomLb.backgroundColor = RGB(225, 230, 237);
    bottomLb.font = [UIFont systemFontOfSize:15];
    bottomLb.textColor =RGB(61, 114, 197);
    bottomLb.textAlignment  = NSTextAlignmentCenter;
    [self.messagetableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContractSecondCell *tempcell = [tableView dequeueReusableCellWithIdentifier:@"CONTLISTCELLINDEN"];
    if (!tempcell) {
        tempcell =[[ContractSecondCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CONTLISTCELLINDEN"];
    }
    CGroupMember *tempMember = [self.memberlist objectAtIndex:indexPath.row];
    [tempcell upadteMemberInfo:tempMember];
    return tempcell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.massGroupdata.m_aGroupID.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  [ContractSecondCell ContractSecondCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
