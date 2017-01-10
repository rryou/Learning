
#import "TabTempGroupController.h"
#import "TabPageView.h"
#import <EMSpeed/MSUIKitCore.h>
#import "CommDataModel.h"
#import "EMCommData.h"
#import <MBProgressHUD.h>
#import "InputHelper.h"
#import "UIImage+Utility.h"
#import "PersonTabMessage.h"
#import "CreateGroupController.h"
#import "CroupMessageController.h"
@interface TabTempGroupController ()<NSXMLParserDelegate,UIScrollViewDelegate,TabPageViewdelegate>
@property (nonatomic, strong) UIPageControl *pageManger;
@property (nonatomic, strong) UIScrollView  *tabViews;
@property (nonatomic, strong) UICollectionView *tabViewsmanager;
@property (nonatomic, strong) NSMutableArray *tablistarray;
@property (nonatomic, strong) NSMutableArray *tabPageviewArray;
@property (nonatomic, strong) UserInfo  *userInfo;
@property (nonatomic, strong) NSString *customertabStr;
@property (nonatomic, strong) MBProgressHUD *showHud;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSMutableArray *selectedTabs;
@property (nonatomic, strong) UITextView *crouplistview;
@property (nonatomic, strong) NSMutableArray *selectGroupArray;
@end

@implementation TabTempGroupController

- (id) initWithUseInfo:(UserInfo *)UserInfro customerTag:(NSString *)tabStrs{
    self = [super init];
    if (self) {
        self.userInfo =UserInfro;
        self.customertabStr =tabStrs;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeTapGusture doneBlock:^(id res){
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =RGB(235, 235, 235);
    self.tablistarray = [NSMutableArray array];
    self.tabPageviewArray = [NSMutableArray array];
    self.pageManger = [[UIPageControl alloc] init];
    [self.pageManger setFrame:CGRectMake(0, self.view.frame.size.height - 225, self.view.frame.size.width, 20)];
    self.pageManger.backgroundColor = RGB(248, 248, 248);
    self.pageManger.pageIndicatorTintColor = RGB(195, 195, 195);
    self.pageManger.currentPageIndicatorTintColor = RGB(56, 105, 192);
    self.pageManger.numberOfPages = 6;
    self.pageManger.currentPage = 0;
    [self.view addSubview:self.pageManger];
    self.title = @"标签";
    
    NSString*path = [[NSBundle mainBundle] pathForResource:@"labelCfg" ofType:@ "xml" ];
    NSFileHandle*file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData*data = [file readDataToEndOfFile];
    NSXMLParser* xmlRead = [[NSXMLParser alloc] initWithData:data];
    xmlRead.delegate = self;
    if([xmlRead parse]){ //调用代理解析NSXMLParser对象，看解析是否成功
        self.tabViews = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 225)];
        self.tabViews.backgroundColor = [UIColor whiteColor];
        self.tabViews.contentSize  =CGSizeMake(self.view.frame.size.width * self.tablistarray.count, self.view.frame.size.height - 225);
        self.tabViews.pagingEnabled = YES;
        self.tabViews.delegate = self;
        self.tabViews.showsHorizontalScrollIndicator = NO;
        self.tabViews.showsVerticalScrollIndicator = NO;
        [self.view addSubview:self.tabViews];
        for(int i = 0; i <self.tablistarray.count; i ++){
            PersonTabMessage *tempPage = [self.tablistarray objectAtIndex:i];
            TabPageView *pageView =  [self createViewPage:tempPage pageIndex:i];
            [pageView setSelectedValue:self.customertabStr];
            [self.tabViews addSubview:pageView];
            [self.tabPageviewArray addObject:pageView];
        }
    }
    
    self.bottomView =[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 195, self.view.width, 195)];
    [self.view addSubview:self.bottomView];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self createBottomView];
    
    self.showHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.showHud];
    self.showHud.mode = MBProgressHUDModeIndeterminate;
    self.selectedTabs = [NSMutableArray array];
}

- (void)createBottomView{
    UILabel *bottomTilte = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.width - 20, 40)];
    [self.bottomView addSubview:bottomTilte];
    bottomTilte.text = @"已选用户";
    bottomTilte.textColor  =  RGB(52, 94, 192);
    bottomTilte.textAlignment = NSTextAlignmentLeft;
    bottomTilte.font = [UIFont systemFontOfSize:16];
     _crouplistview = [[UITextView alloc] initWithFrame:CGRectMake(0, 40, self.view.width , 100)];
    _crouplistview.textAlignment = NSTextAlignmentLeft;
    _crouplistview.backgroundColor = [UIColor whiteColor];
    _crouplistview.textColor =[UIColor blackColor];
    _crouplistview.scrollEnabled =YES;
    _crouplistview.editable = NO;
    [self.bottomView addSubview:_crouplistview];
    _crouplistview.layer.borderColor = RGB(231, 231, 231).CGColor;
    _crouplistview.layer.borderWidth = 0.5;
    _crouplistview.font = [UIFont systemFontOfSize:15];
    
    UIButton *addGroupBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width/2.0 - 30, 160, 90, 30)];
    [addGroupBtn setTitle:@"添加到群组" forState:UIControlStateNormal];
    [addGroupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addGroupBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addGroupBtn setBackgroundImage:[UIImage ms_imageWithColor:RGB(52, 94, 192)] forState:UIControlStateNormal];
    addGroupBtn.layer.cornerRadius  = 4;
    addGroupBtn.layer.masksToBounds = YES;
    [addGroupBtn addTarget:self action:@selector(addGroupEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:addGroupBtn];
    
    UIButton *sendGroupMessagebtn = [[UIButton alloc] initWithFrame:CGRectMake(addGroupBtn.right + 10, addGroupBtn.top, 80, 30)];
    [sendGroupMessagebtn setTitle:@"去群发 >" forState:UIControlStateNormal];
    sendGroupMessagebtn.titleLabel.font = [UIFont systemFontOfSize:14];
    sendGroupMessagebtn.layer.cornerRadius = 4;
    sendGroupMessagebtn.layer.masksToBounds = YES;
    [sendGroupMessagebtn addTarget:self action:@selector(sendGroupMessage:) forControlEvents:UIControlEventTouchUpInside];
    [sendGroupMessagebtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendGroupMessagebtn setBackgroundImage:[UIImage ms_imageWithColor:RGB(52, 94, 192)] forState:UIControlStateNormal];
    [self.bottomView addSubview:sendGroupMessagebtn];
}

- (void)sendGroupMessage:(UIButton *)sender{
    if (self.selectGroupArray.count > 0) {
        CMassGroup *tempMassGroup = [[CMassGroup alloc] init];
        for (CGroup *tempGroup in self.selectGroupArray) {
            [tempMassGroup.m_aGroupID addObject:[NSNumber numberWithLongLong:tempGroup.m_n64GroupID]];
        }
        CroupMessageController *tempController = [[CroupMessageController alloc] initWithMassGroup:tempMassGroup];
        [self.navigationController pushViewController:tempController animated:YES];
    }
}

- (void)addGroupEvent:(UIButton *)sender{
    if (self.selectGroupArray.count > 0) {
        CMassGroup *tempMassGroup = [[CMassGroup alloc] init];
        for (CGroup *tempGroup in self.selectGroupArray) {
            [tempMassGroup.m_aGroupID addObject:[NSNumber numberWithLongLong:tempGroup.m_n64GroupID]];
        }
        CreateGroupController *tempGroupController = [[CreateGroupController alloc] initWithMassGroup:tempMassGroup];
        [self.navigationController pushViewController:tempGroupController animated:YES];
    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger page = floor((scrollView.contentOffset.x - self.view.width / 2) / self.view.width) + 1;
    self.pageManger.currentPage = page;
}

- (TabPageView *)createViewPage:(PersonTabMessage *)pageMessage pageIndex:(NSInteger )pageIndex{
    TabPageView *pageview =[[TabPageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * pageIndex, 64, self.view.frame.size.width, self.view.frame.size.height - 225)];
    pageview.pageMessage = pageMessage;
    pageview.tabBtndelegate = self;
    [pageview recreatetabView];
    return pageview;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    if([elementName isEqualToString:@"Page"]){
        PersonTabMessage  *tempDic = [[PersonTabMessage alloc] init];;
        tempDic.name = [attributeDict objectForKey:@"Name"];
        [self.tablistarray addObject:tempDic];
    }else if ([elementName isEqualToString:@"Class"]){
        LabelMessage *temlble = [[LabelMessage alloc] init];
        temlble.name = [attributeDict objectForKey:@"Name"];
        PersonTabMessage *tempPage = [self.tablistarray lastObject];
        [tempPage.pagelistarray addObject:temlble];
    }else if ([elementName isEqualToString:@"Item"]){
        PersonTabMessage *tempPage = [self.tablistarray lastObject];
        LabelMessage *tempLb = [tempPage.pagelistarray lastObject];
        [tempLb.itemarry addObject:[attributeDict objectForKey:@"Text"]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
}
#pragma mark tabBtnDelegate

- (void)tabPageUpdateMessage:(NSString *)tabValue isSelected:(bool) selected{
    if (selected) {
        [self.selectedTabs addObject:tabValue];
    }else{
        [self.selectedTabs removeObject:tabValue];
    }
    [self reloadMembers];
}

- (void)reloadMembers{
    self.selectGroupArray = [NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getTabGroups:self.selectedTabs]];
    NSMutableString *tempStr = [NSMutableString string];
    for (CGroup *tempGroup in self.selectGroupArray) {
        [tempStr appendString:[NSString stringWithFormat:@"%@;  ",[tempGroup getTagNickName]]];
    }
    _crouplistview.text = tempStr;
}

@end


