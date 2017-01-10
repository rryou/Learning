
#import "PersonTabMangerController.h"
#import "TabPageView.h"
#import <EMSpeed/MSUIKitCore.h>
#import "CommDataModel.h"
#import "EMCommData.h"
#import <MBProgressHUD.h>
#import "InputHelper.h"
#import "UIImage+Utility.h"
@interface PersonTabMangerController ()<NSXMLParserDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIPageControl *pageManger;
@property (nonatomic, strong) UIScrollView  *tabViews;
@property (nonatomic, strong) UICollectionView *tabViewsmanager;
@property (nonatomic, strong) NSMutableArray *tablistarray;
@property (nonatomic, strong) NSMutableArray *tabPageviewArray;
@property (nonatomic, strong) CGroupMember  *userInfo;
@property (nonatomic, strong) NSString *customertabStr;
@property (nonatomic, strong) MBProgressHUD *showHud;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation PersonTabMangerController
- (id) initWithMemberInfo:(CGroupMember *)memberInfro customerTag:(NSString *)tabStrs{
    self = [super init];
    if (self) {
        self.userInfo =memberInfro;
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
    [self.pageManger setFrame:CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30)];
    self.pageManger.backgroundColor = RGB(235, 235, 235);
    self.pageManger.pageIndicatorTintColor = RGB(195, 195, 195);
    self.pageManger.currentPageIndicatorTintColor = RGB(56, 105, 192);
    self.pageManger.numberOfPages = 6;
    self.pageManger.currentPage = 0;
    [self.view addSubview:self.pageManger];
    self.title = @"标签";
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarevent:)];
    [rightBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBar;
    NSString*path = [[NSBundle mainBundle] pathForResource:@"labelCfg" ofType:@ "xml" ];
    NSFileHandle*file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData*data = [file readDataToEndOfFile];
    NSXMLParser* xmlRead = [[NSXMLParser alloc] initWithData:data];
    xmlRead.delegate = self;
    if([xmlRead parse]){ //调用代理解析NSXMLParser对象，看解析是否成功
        self.tabViews = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30)];
        self.tabViews.backgroundColor = [UIColor whiteColor];
        self.tabViews.contentSize  =CGSizeMake(self.view.frame.size.width * self.tablistarray.count, self.view.frame.size.height- 30);
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
    
    self.showHud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.showHud];
    self.showHud.mode = MBProgressHUDModeIndeterminate;
}

- (void)sendGroupMessage:(UIButton *)sender{
    
}

- (void)addGroupEvent:(UIButton *)sender{
    
    
}

- (void)rightBarevent:(UIButton *)sender{
    NSMutableString *selectedTabstr = [NSMutableString string];
    for (TabPageView *tempView  in  self.tabPageviewArray) {
        NSString *selectedStr = [tempView getSelectedvalue];
        if (selectedStr) {
           [selectedTabstr appendString:[tempView getSelectedvalue]];
        }
    }
    CIM_ModGrpInfo *tempMod= [[CIM_ModGrpInfo alloc] init];
    tempMod.m_n64UserID = [[EMCommData sharedEMCommData] getUserId];
    tempMod.m_n64GroupID = self.userInfo.m_n64GroupID;
    tempMod.m_wModType = 2;
    tempMod.m_strNewText = [selectedTabstr substringToIndex:selectedTabstr.length -1];
    self.showHud.label.text = @"修改中，请稍等";
    [self.showHud showAnimated:YES];
    [tempMod setCompletionBlock:^(NSData *responseData, BOOL success){
        [self.showHud hideAnimated:YES];
        if(success){
             CGroup *groupInfo = [[EMCommData sharedEMCommData] getGroupbyid:self.userInfo.m_n64GroupID];
             groupInfo.m_strCustomerTag = [selectedTabstr substringToIndex:selectedTabstr.length -1];
                NSLog(@"修改成功");
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                NSLog(@"保存失败");
            }
    }];
    [tempMod sendSockPost];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger page = floor((scrollView.contentOffset.x - self.view.width / 2) / self.view.width) + 1;
    self.pageManger.currentPage = page;
}

- (TabPageView *)createViewPage:(PersonTabMessage *)pageMessage pageIndex:(NSInteger )pageIndex{
    TabPageView *pageview =[[TabPageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * pageIndex, 64, self.view.frame.size.width, self.view.frame.size.height - 80)];
    pageview.pageMessage = pageMessage;
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
@end


