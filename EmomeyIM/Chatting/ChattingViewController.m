//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingViewController.h"
#import "ChattingCellContext.h"
#import "NSDate+Extends.h"
#import "ChattingIncomingCell.h"
#import "ChattingOutgoingCell.h"
#import "ChattingTipCell.h"
#import "ChattingCollectionViewFlowLayout.h"
#import <EMSpeed/MSUIKitCore.h>
#import "ChatContentView.h"
#import "ChattingInputBoxController.h"
#import "CommDataModel.h"
#import "EMCommData.h"
#import "NSString+BASE64.h"
#import "RoundAvatarView.h"
#import "PersonEditController.h"
#import "PersonEditController.h"
#import "ChattingImageView.h"
#import "InviteFriendViewController.h"
#import "MSSBrowseLocalViewController.h"
#import "MSSBrowseModel.h"
#define Observe_ChattingCollection_contentSize       @"chattingCollectionView.contentSize"
#define Observe_ChattingCollection_contentOffset       @"chattingCollectionView.contentOffset"

NSString * const kReuseIdentifier_ChattingIncomingCell = @"ChattingIncomingCell";
NSString * const kReuseIdentifier_ChattingOutgoingCell = @"ChattingOutgoingCell";
NSString * const kReuseIdentifier_ChattingTipCell = @"ChattingTipCell";

typedef NS_ENUM(NSUInteger, LoadDataType)
{
    LoadDataType_First,       //第一次 加载 即最新数据
    LoadDataType_Normal,
    LoadDataType_Older,       //获取更早的数据
    LoadDataType_Newer,       //获取更新数据
};


@interface ChattingViewController ()<InviteFriendDelegate>
{
    UIRefreshControl *_refreshControl;
    UIActivityIndicatorView *_waitView;
    CGFloat _downpullY;
    BOOL _isDownPull;
    BOOL _isHaveData;  //数据  包括server  db
}
@property (nonatomic, assign) bool showBackItem;
@property (nonatomic, strong) CGroupMember *chatMember;
@property (nonatomic, assign) int64_t currentMinmsgID;
@property (nonatomic, assign) int64_t currentMaxMsgID;
@property (nonatomic, assign) LoadDataType loadDataType;
@property (nonatomic, strong) NSMutableArray *sendingMsgList;
@property (nonatomic, assign) int64_t sendingIndex;
@property (nonatomic, assign) BOOL isloadMoreData;
@property (nonatomic, strong) ChattingContent *selectedContent;
@property (nonatomic,strong) UIView *snapshotView;
@end

@implementation ChattingViewController
- (InputBoxOption)inputBoxOptions{
    return InputBoxOption( kInputBoxOption_PickPhoto | kInputBoxOption_TakePhoto);
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:Observe_ChattingCollection_contentSize];
    [self removeObserver:self forKeyPath:Observe_ChattingCollection_contentOffset];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _chattingCollectionView.delegate = nil;
    _chattingCollectionView.dataSource = nil;
}

- (BOOL)shouldFilterStatusBarAlertWhenAppearing{
    return YES;
}

- (BOOL)checkMessageContainMedi:(CNewMsg *)msg{
    if (msg.m_aItem) {
        for (CMsgItem *tempItem in  msg.m_aItem){
            if (tempItem.m_cType == MSG_PIC ||tempItem.m_cType == MSG_FILE){
                return YES;
            }
        }
        return NO;
    }else{
        return NO;
    }
}

-(NSArray *)checkRepeatMessage:(NSArray *)msgArray{
    NSMutableArray *temMsgArray = [[NSMutableArray alloc] initWithArray:msgArray];
    return temMsgArray;
}

- (void)reloadPartCells:(ChattingContent *)updaContent{
    NSInteger rowValue = [self.messages indexOfObject:updaContent];
    if (rowValue ==NSNotFound) {
        return;
    }
    NSIndexPath *index= [NSIndexPath indexPathForRow:rowValue inSection:0];
    NSMutableArray *temparray = [NSMutableArray array];
    ChattingCellDisplayAttribute *attri = [_chattingContentViewBuilder displayAttributeOfChattingContent:updaContent prevContent:nil];
   if(attri && updaContent.id) {
       [self.attriDict setObject:attri forKey:updaContent.id];
    }
    UICollectionViewCell *currentcell = [self collectionView:self.chattingCollectionView cellForItemAtIndexPath:index];
    [self.chattingCollectionView  reloadItemsAtIndexPaths:@[index]];
}

- (void)addnewMsgdata:(NSArray *)msgarray{
   NSArray *tempNewArray = [self checkRepeatMessage:msgarray];
    if (tempNewArray.count > 0 && LoadDataType_Older == self.loadDataType){
        [self showRefreshControl];
    }
    ChattingContent *prevContent = [self.messages lastObject];
    NSMutableArray *tempSortArray = [NSMutableArray array];
    if (tempNewArray.count >0) {
        for (int  i = 0; i <tempNewArray.count; i ++) {
            CNewMsg *pNewMsg =  [tempNewArray objectAtIndex:i];
            ChattingContent *tempChatCotent  =[[ChattingContent alloc] init];
            tempChatCotent.id = [NSNumber numberWithLong:pNewMsg.m_n64GrpMsgID].stringValue;
            tempChatCotent.text =   pNewMsg.m_strMsgText;
            if (pNewMsg.m_aItem) {
                tempChatCotent.data =  [[NSMutableArray alloc] initWithArray:pNewMsg.m_aItem];
            }
            if ((self.currentMinmsgID > pNewMsg.m_n64GrpMsgID||self.currentMinmsgID == 0)&& pNewMsg.m_n64GrpMsgID < INT64_MAX -2000) {
                self.currentMinmsgID = pNewMsg.m_n64GrpMsgID;
            }
            if ((self.currentMaxMsgID< pNewMsg.m_n64GrpMsgID||self.currentMinmsgID == 0)&& pNewMsg.m_n64GrpMsgID < INT64_MAX -2000){
                self.currentMaxMsgID = pNewMsg.m_n64GrpMsgID;
            }
            
            if (pNewMsg.msg_Status == MSG_STATUS_Sending) {
                [self.sendingMsgList addObject:tempChatCotent];
            }
            
            tempChatCotent.createTime = pNewMsg.m_dwMsgSeconds*1000.00;
            UserInfo *tempUser = [[UserInfo alloc] init];
            tempUser.m_strUserName =[_chatMember m_strEM_UserName];
            tempUser.m_strNickName = [_chatMember m_strNickName];
            tempUser.m_nPlatformID = pNewMsg.m_n64SenderID;
            tempUser.m_n64PortraitID = self.chatMember.m_n64PortraitID;
            tempChatCotent.sender =   tempUser;
            tempChatCotent.m_n64GroupID = self.chattinggoup.m_n64GroupID;
            pNewMsg.m_n64GroupID = self.chattinggoup.m_n64GroupID;
            tempUser.m_nGroupId = self.chattinggoup.m_n64GroupID;
            if ([self checkMessageContainMedi:pNewMsg]) {
                tempChatCotent.contentType = ChattingContent_Image;
            }else{
                tempChatCotent.contentType = ChattingContent_Text;
            }
            ChattingCellDisplayAttribute *attri = [_chattingContentViewBuilder displayAttributeOfChattingContent:tempChatCotent prevContent:prevContent];
            attri.bubbleStyle = ChattingBubbleStyle_WhiteBubble;
            
            if(attri && tempChatCotent.id) {
                [self.attriDict setObject:attri forKey:tempChatCotent.id];
            }
            prevContent  =tempChatCotent;
            [tempSortArray addObject:tempChatCotent];
        }
        if(self.loadDataType == LoadDataType_First || self.loadDataType == LoadDataType_Older){
           [self.messages insertObjects:tempSortArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempSortArray.count)]];
        }else{
            [self.messages addObjectsFromArray:tempSortArray];
        }
    }
    [self.chattingCollectionView reloadData];
    [self endRefreshControl];
}

-(void)setEnterState {
    self.loadDataType = LoadDataType_First;
    [self.messages removeAllObjects];
    NSArray *tempmesslist = [NSArray arrayWithArray:[[EMCommData sharedEMCommData] getLimitMessagsByGroupId:self.chattinggoup.m_n64GroupID maxCount:20]] ;
   _chatMember = [[EMCommData sharedEMCommData] getMemberByGroupId:self.chattinggoup.m_n64GroupID];
    self.title = [_chatMember getNickName];
    [self addnewMsgdata:tempmesslist];
}

- (void)stateWhenDidDisAppear{
        
}

- (void)stateWhenDidAppear{
    
}

- (NSString *)getDraft{
    return @"";
}

- (Class)chattingInputBoxControllerClass {
    return [ChattingInputBoxController class];
}

- (instancetype)initWithInputBox:(BOOL)withInputBox {
    self = [super init];
    if (self) {
        if (withInputBox){
            Class clazz = [self chattingInputBoxControllerClass];
            _inputBoxController = [[clazz alloc] initWithParent:self options:kInputBoxOption_Default];
            _inputBoxController.delegate = self;
            self.inputBoxController.separatedlySender = self;
        }
        _attriDict = [[NSMutableDictionary alloc] init];
        _messages = [[NSMutableArray alloc] init];
        self.chattingCollectionView.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (instancetype)init {
    return [self initWithInputBox:YES];
}

- (UIView<ReusableViewProtocol> *)contentViewOfChattingContent:(ChattingContent *)content {
    return nil;
}

- (UIView<ReusableViewProtocol> *)contentViewOfChattingContent:(ChattingContent *)content index:(NSInteger)index {
    return [_chattingContentViewBuilder chattingContentViewOfChattingContent:content];
}

- (UIView<ReusableViewProtocol> *)bottomContentViewOfChattingContent:(ChattingContent *)content {
    return nil;
}

- (ChattingCellDisplayAttribute *)displayAttributeOfChattingContent:(ChattingContent *)content {
     return [self.attriDict objectForKey:content.id];
}

- (BOOL)showIncomingUserName {
    return NO;
}

- (ChattingOutgoingStatus)outgoingStatusOfChattingContent:(ChattingContent *)content {
    return ChattingOutgoingStatus_Normal;
}

-(void)setBackItemEnable:(bool)showBack{
    self.showBackItem  =showBack;
    self.navigationItem.hidesBackButton = !showBack;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[EMCommData sharedEMCommData] reSetGroupUnReadCount:self.chatMember.m_n64GroupID];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.sendingIndex = INT64_MAX - 1000;
    self.navigationController.navigationBarHidden = NO;
    self.sendingMsgList =[NSMutableArray array];
    self.currentMinmsgID = 0;
    self.isloadMoreData = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:54/255.0 green:104/255.0 blue:193/255.0 alpha:1.0]];
    self.navigationItem.hidesBackButton = !self.showBackItem;
    
    ChattingCollectionViewFlowLayout *layout = [[ChattingCollectionViewFlowLayout alloc] init];
    _chattingCollectionView = [[ChattingCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    _chattingCollectionView.delegate = self;
    _chattingCollectionView.dataSource = self;
    _chattingCollectionView.clipsToBounds = YES;
    [_chattingCollectionView registerClass:[ChattingIncomingCell class] forCellWithReuseIdentifier:kReuseIdentifier_ChattingIncomingCell];
    [_chattingCollectionView registerClass:[ChattingOutgoingCell class] forCellWithReuseIdentifier:kReuseIdentifier_ChattingOutgoingCell];
    [_chattingCollectionView registerClass:[ChattingTipCell class] forCellWithReuseIdentifier:kReuseIdentifier_ChattingTipCell];
    _chattingCollectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_chattingCollectionView];
    [self addRefreshControl];
    
    _chattingCellContext = [[ChattingCellContext alloc] init];
    _chattingCellContext.delegate = self;
    _chattingCellContext.maxWidth = self.view.frame.size.width;
    _chattingCellContext.chattingCollectionView = self.chattingCollectionView;
    _chattingCellContext.showIncomingUserName = [self showIncomingUserName];
    
    self.chattingContentViewBuilder  =[[ChattingContentViewBuilder alloc] initWithCellContext:self.chattingCellContext];
    if (_inputBoxController) {
        self.view.backgroundColor = [UIColor whiteColor];
        [_inputBoxController showInContextView:self.view options:[self inputBoxOptions]];
        [_inputBoxController observeTapInView:_chattingCollectionView];
        _inputBoxController.textContent = [self getDraft];
    }
    
    [self addObserver:self forKeyPath:Observe_ChattingCollection_contentSize options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self addObserver:self forKeyPath:Observe_ChattingCollection_contentOffset options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    _isDownPull = YES;
    _downpullY = 0;
    _chattingCellContext.customResponderTextView = self.inputBoxController.inputBox.textView;
    _chattingCollectionView.backgroundColor =  [UIColor whiteColor];
    [self setEnterState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessge:) name:NOTIFIMESSAGEUPDATEMESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellImage:) name:NOTIFIMESSAGCellLOADIMAGESUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateGroupInfo:) name:UpdateGroupNotice object:nil];
}

- (void)upDateGroupInfo:(NSNotification *)notice{
    if (notice.object) {
        NSNumber *tempNumber = notice.object;
        if (tempNumber.longLongValue == self.chatMember.m_n64GroupID) {
            CGroup *newGroup = [[EMCommData sharedEMCommData] getGroupbyid:self.chatMember.m_n64GroupID];
            if (newGroup) {
                self.chatMember.Gm_strPeerRemark = newGroup.m_strPeerRemark;
                self.title = [_chatMember getNickName];
            }
        }
    }
}

- (void)updateMessge:(NSNotification *)notice{
    if (notice.object) {
        NSNumber *tempNumber = notice.object;
        if (tempNumber.longLongValue == self.chatMember.m_n64GroupID) {
            self.loadDataType = LoadDataType_Newer;
            NSArray *tempArray = [[EMCommData sharedEMCommData] getNewMessageListByGroupId:_chatMember.m_n64GroupID  afterMsgid:self.currentMaxMsgID];
            [self addnewMsgdata:tempArray];
        }
    }
}

- (void)updateCellImage:(NSNotification *)notice{
    ChattingContent *imageContent = notice.object;
    [self reloadPartCells:imageContent];
}

- (ChattingContentSource)sourceOfChattingContent:(ChattingContent *)content {
    if (content.sender) {
        if (content.sender.m_nPlatformID == [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID) {
            return ChattingContentSource_Outgoing;
        }
        else {
            return ChattingContentSource_Incoming;
        }
    }
    return ChattingContentSource_System;
}

- (NSIndexPath *)lastIndexPath {
    NSInteger sectionCount = [_chattingCollectionView numberOfSections];
    while (sectionCount > 0) {
        NSInteger itemCount = [_chattingCollectionView numberOfItemsInSection:sectionCount - 1];
        if (itemCount > 0) {
            return [NSIndexPath indexPathForRow:itemCount - 1 inSection:sectionCount - 1];
        }
        sectionCount--;
    }
    return nil;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSIndexPath *lastIndexPath = [self lastIndexPath];
    if (lastIndexPath) {
        [_chattingCollectionView scrollToItemAtIndexPath:lastIndexPath
                                        atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                animated:animated];
    }
}

- (void)didSelectAvatarOnChattingContent:(ChattingContent *)chattingContent {
    UserInfo *user = chattingContent.sender;
    CGroupMember *tempMember = [[EMCommData sharedEMCommData] getMemberByGroupId:user.m_nGroupId];
    PersonEditController *tempPerson = [[PersonEditController alloc] initWithMember:tempMember];
    [self.navigationController pushViewController:tempPerson animated:YES];
}
#pragma mark - UICollectionViewDataSource

- (void)willLoadCell:(ChattingCollectionViewCell *)cell forContent:(ChattingContent *)chattingContent atIndexPath:(NSIndexPath *)indexPath {
    // do nothing
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}

- (void)actionCellAvatarButton:(UIButton *)btn {
    NSIndexPath *indexPath = [_chattingCollectionView indexPathForDescendantOfView:btn];
    ChattingContent *chattingContent = [self collectionView:_chattingCollectionView chattingContentAtIndexPath:indexPath];
    [self.view endEditing:YES];
    [self didSelectAvatarOnChattingContent:chattingContent];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChattingContent *chattingContent = [self collectionView:(ChattingCollectionView *)collectionView chattingContentAtIndexPath:indexPath];
    ChattingCellDisplayAttribute *displayAttribute = [self displayAttributeOfChattingContent:chattingContent];
    switch ([self sourceOfChattingContent:chattingContent]) {
        case ChattingContentSource_Incoming:{
            ChattingIncomingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier_ChattingIncomingCell forIndexPath:indexPath];
            [cell.avatarView setTarget:self selector:@selector(actionCellAvatarButton:)];
            cell.cellContext = _chattingCellContext;
            if (displayAttribute.showCellTopView) {
                cell.dateLabel.text = [self dateStringOfChattingContent:chattingContent];
            }
            cell.displayAttribute = displayAttribute;
            cell.nameLabel.text = chattingContent.sender.m_strUserName ;
            
            UIView<ReusableViewProtocol> *chatContentView = [self contentViewOfChattingContent:chattingContent index:[indexPath row]];
            chatContentView.frame = CGRectMake(0, 0, displayAttribute.msgContentSize.width, displayAttribute.msgContentSize.height);
            cell.chattingContentView = chatContentView;
            
            if (displayAttribute.bottomViewHeight > 0) {
                UIView<ReusableViewProtocol> *chatBottomContentView = [self bottomContentViewOfChattingContent:chattingContent];
                chatBottomContentView.frame = CGRectMake(0, 0, _chattingCellContext.maxWidth, displayAttribute.bottomViewHeight);
                cell.chattingBottomContentView = chatBottomContentView;
            }
            cell.avatarView.user = chattingContent.sender;
            [self willLoadCell:cell forContent:chattingContent atIndexPath:indexPath];
            return cell;
        }
            break;
        case ChattingContentSource_Outgoing:{
            ChattingOutgoingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier_ChattingOutgoingCell forIndexPath:indexPath];
            [cell.avatarView setTarget:self selector:@selector(actionCellAvatarButton:)];
            cell.cellContext = _chattingCellContext;
            
            if (displayAttribute.showCellTopView) {
                cell.dateLabel.text = [self dateStringOfChattingContent:chattingContent];
            }
            cell.outgoingStatus = [self outgoingStatusOfChattingContent:chattingContent];
            cell.displayAttribute = displayAttribute;
            
            UIView<ReusableViewProtocol> *chatContentView = [self contentViewOfChattingContent:chattingContent index:[indexPath row]];
            chatContentView.frame = CGRectMake(0, 0, displayAttribute.msgContentSize.width, displayAttribute.msgContentSize.height);
            cell.chattingContentView = chatContentView;
            
            if (displayAttribute.bottomViewHeight > 0) {
                UIView<ReusableViewProtocol> *chatBottomContentView = [self bottomContentViewOfChattingContent:chattingContent];
                chatBottomContentView.frame = CGRectMake(0, 0, _chattingCellContext.maxWidth, displayAttribute.bottomViewHeight);
                cell.chattingBottomContentView = chatBottomContentView;
            }
            cell.avatarView.user = chattingContent.sender;
            [self willLoadCell:cell forContent:chattingContent atIndexPath:indexPath];
            return cell;
        }
            break;
        default: // tips
        {
            ChattingTipCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier_ChattingTipCell forIndexPath:indexPath];
            cell.cellContext = _chattingCellContext;
            if (displayAttribute.showCellTopView) {
                cell.dateLabel.text = [self dateStringOfChattingContent:chattingContent];
            }
            cell.displayAttribute = displayAttribute;
            UIView<ReusableViewProtocol> *tipCntentView = [self contentViewOfChattingContent:chattingContent index:[indexPath row]];
            cell.tipCntentView = tipCntentView;
            [self willLoadCell:cell forContent:chattingContent atIndexPath:indexPath];
            return cell;
        }
            break;
    }
}
//[formatter dateFromString:@"2009-04-26 20:53:28 +0800"];

- (NSString *)dateStringOfChattingContent:(ChattingContent *)content{
   return [[NSDate dateWithTimeInterval:content.createTime/1000 sinceDate:[[EMCommData sharedEMCommData] commonSinceDate]] prettyDateWithReference:[NSDate date]];
    return [[NSDate dateWithTimeIntervalSince1970:content.createTime/1000] prettyDateWithReference:[NSDate date]];
}
#pragma mark - ChattingCollectionViewDataSource

- (ChattingContent *)collectionView:(ChattingCollectionView *)collectionView chattingContentAtIndexPath:(NSIndexPath *)indexPath {
   return [self.messages objectAtIndex:indexPath.row];
}

-(NSDictionary*)selectAttacthemt:(ChattingContent*)defaultData{
    NSMutableArray *contentArr = [NSMutableArray array];
    ContentInfo *defaultContent = nil;
    for (ChattingContent *ci in self.messages){
    }
    if(defaultContent) {
        NSDictionary *dic = @{@"resources":contentArr,@"default":defaultContent};
        return dic;
    }
    else {
        return nil;
    }
}

-(void)browserDataSourece:(ChattingContent*)defaultData{
    ContentInfo *ci = [defaultData.data lastObject];
}

#pragma mark - UICollectionViewDelegate
#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChattingContent *chattingContent = [self collectionView:(ChattingCollectionView *)collectionView chattingContentAtIndexPath:indexPath];
    ChattingCellDisplayAttribute *displayAttribute = [self displayAttributeOfChattingContent:chattingContent];
    
    switch ([self sourceOfChattingContent:chattingContent]) {
        case ChattingContentSource_Incoming:
            return CGSizeMake(_chattingCellContext.maxWidth, [ChattingIncomingCell cellHeightWithDisplayAttribute:displayAttribute
                                                                                                      cellContext:_chattingCellContext]);
            
        case ChattingContentSource_Outgoing:
            return CGSizeMake(_chattingCellContext.maxWidth, [ChattingOutgoingCell cellHeightWithDisplayAttribute:displayAttribute
                                                                                                      cellContext:_chattingCellContext]);
            
        default: // tips
            return CGSizeMake(_chattingCellContext.maxWidth, [ChattingTipCell cellHeightWithDisplayAttribute:displayAttribute
                                                                                                 cellContext:_chattingCellContext]);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ChattingContent *content = [self.messages objectAtIndex:indexPath.row];
}

#pragma mark - ChattingCellContextDelegate

- (CGSize)chattingCellContext:(ChattingCellContext *)context defaultSizeForViewWithIdentifier:(NSString *)identifier {
    return CGSizeMake(context.maxWidth, 60);
}

- (BOOL)chattingCellisAbleSupportChangeResponder{
    return YES;
}

#pragma mark --  Load  Data
-(void)freshControlEventValueChanged:(UIRefreshControl*)fresh{
    [self loadmoreMessageData];
}

- (void)loadmoreMessageData{
    if (self.currentMinmsgID == 0 && self.loadDataType !=LoadDataType_First) {
        return;
    }
    
    NSArray *tempArray =[[EMCommData sharedEMCommData] getMoreLimitMessageListByGroupId:_chatMember.m_n64GroupID beforeMsgid:self.currentMinmsgID limitedNumber:8];
    if (tempArray.count >0) {
        [self addnewMsgdata:tempArray];
    }else{
        self.loadDataType = LoadDataType_Older;
        CIM_QueryMsgData *moreData = [[CIM_QueryMsgData alloc] init];
        moreData.m_n64UserID = _chatMember.m_n64UserID;
        moreData.m_n64GroupID = _chatMember.m_n64GroupID;
        moreData.m_n64GrpMsgIDTo = self.currentMinmsgID - 1;
        moreData.m_n64GrpMsgIDFrom = self.currentMinmsgID - 5;
        __weak typeof(self) wealself = self;
        [self showRefreshControl];
        [moreData setCompletionBlock:^(NSData *responseData, BOOL success){
            if(success){
                [self hidenRefreshControl];
                self.isloadMoreData = NO;
                NSMutableArray *newMsgArray = [NSMutableArray arrayWithArray:[[EMCommData sharedEMCommData] getMoreLimitMessageListByGroupId:_chatMember.m_n64GroupID beforeMsgid:wealself.currentMinmsgID limitedNumber:8]];
                [wealself addnewMsgdata:newMsgArray];
            }else{
                [wealself hidenRefreshControl];
            }
        }];
        [moreData sendSockPost];
    }
}

-(ChattingContent*)lastRightTimeChattingContent{
    ChattingContent *last = nil;
    for (int i = (int)_messages.count -1; i > 0;i--){
        last = [_messages objectAtIndex:i];
    }
    return last;
}

- (ChattingContent*)firstRightTimerChattingContent{
    ChattingContent *first = nil;
    for (int i = 0; i<(int)_messages.count-1; i++){
        first = [_messages objectAtIndex:i];
    }
    return first;
}

- (void)deleteOneMessageInMemoryAndUIByMessageId:(NSString*)msgId{
    __block ChattingContent *deletedObject = nil;
    __block NSIndexPath *indexPath = nil;;
    [self.messages enumerateObjectsUsingBlock:^(ChattingContent *obj, NSUInteger idx, BOOL *stop){
        if ([obj.id isEqualToString:msgId]){
            deletedObject = obj;
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    if (deletedObject){
        [self.messages removeObjectAtIndex:indexPath.row];
        [self.chattingCollectionView performBatchUpdates:^{
            [self.chattingCollectionView deleteItemsAtIndexPaths:@[indexPath]];
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(ChattingContent*)convertToChattingContentFromObj:(id)data{
    return nil;
}
/**
 *  此方法必须同步  调用 不然数据有可能 出错
 *
 *  @param success  <#success description#>
 *  @param time     <#time description#>
 *  @param mssageId <#mssageId description#>
 *  @param fakeId   <#fakeId description#>
 */
//发送成功 要重新排序  因为先发送的消息有可能 后成功
- (BOOL)updateDisplayAttributeAtIndex:(NSInteger)index{
    return NO;
}
/**
 *  此方法必须同步  调用 不然数据有可能 出错
 *
 *  @param success
 *  @param chat    <#chat description#>
 *  @param fakeId  <#fakeId description#>
 *  @param resend  <#resend description#>
 *  @param dele    <#dele description#>
 */
-(void)addRefreshControl{
    _waitView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _waitView.center = CGPointMake(_chattingCollectionView.center.x, -10);
    [_chattingCollectionView addSubview:_waitView];
    _isHaveData = YES;
}

-(void)removeRefreshControl{
    [_waitView removeFromSuperview];
}

-(void)hidenRefreshControl{
    _isHaveData = NO;
}

-(void)showRefreshControl{
    _isHaveData = YES;
}

-(void)endRefreshControl{
    [_waitView stopAnimating];
    _isDownPull = NO;
}

#define OffSetY  40
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y < 0 && !_isDownPull && scrollView.contentOffset.y > -OffSetY ){
        if (_isHaveData){
            [_waitView startAnimating];
        }
    }else if(scrollView.contentOffset.y < -OffSetY && !_isDownPull&&!self.isloadMoreData){
        if(self.loadDataType != LoadDataType_First){
           [self loadOlderData];
            self.isloadMoreData = YES;
           _isDownPull = YES;
        }
    }
}

- (void)loadOlderData{
    [self loadmoreMessageData];
}

#pragma mark - FreshInputBoxControllerDelegate
- (void)inputBoxController:(FreshInputBoxController *)inputBoxController didChangeFrame:(CGRect)inputBoxFrame {
    CGRect r = self.view.bounds;
    _chattingCollectionView.frame = CGRectMake(0, 0, r.size.width, inputBoxFrame.origin.y);
    if (inputBoxController.inputBoxState != kInputBoxState_Normal) {
        [self scrollToBottomAnimated:YES];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:Observe_ChattingCollection_contentSize]){
        CGSize old = [[change objectForKey:@"old"] CGSizeValue];
        CGSize newsize = [[change objectForKey:@"new"] CGSizeValue];
        CGFloat dex = newsize.height - old.height;
        if (dex > 2){
            if (self.loadDataType == LoadDataType_Older){
               [self.chattingCollectionView setContentOffset:CGPointMake(0, dex + _downpullY) animated:NO];
            }else if (LoadDataType_Newer == self.loadDataType ){
                [self scrollToBottomAnimated:YES];
            }else if (LoadDataType_First == self.loadDataType){
                [self scrollToBottomAnimated:NO];
                self.loadDataType = LoadDataType_Normal;
            }else if (LoadDataType_Older == self.loadDataType){
                
            }
        }
    }
    else if ([keyPath isEqualToString:Observe_ChattingCollection_contentOffset]){
        CGSize old = [[change objectForKey:@"old"] CGSizeValue];
        CGSize newsize = [[change objectForKey:@"new"] CGSizeValue];
        if (newsize.height == 0.0){
            _downpullY = old.height;
        }
    }
}

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController sendText:(NSString *)text{
    if (text){
        CNewMsg *tempMsg  = [[CNewMsg alloc] init];
        tempMsg.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        NSDate *nowDate = [NSDate date];
        NSTimeInterval timeInterval = [nowDate timeIntervalSince1970];
        tempMsg.m_dwExprSeconds  =  timeInterval;
        tempMsg.m_strMsgText = [NSString stringWithFormat:@"%@",text];
        tempMsg.m_n64GroupID = self.chattinggoup.m_n64GroupID;
        tempMsg.m_sMsgType  = 1;
        CMsgItem *tempMsgitem = [[CMsgItem alloc] init];
        [tempMsgitem createMsgItem:MSG_ITEM_TEXT int64:0 strItem:text];
        [tempMsg.m_aItem addObject:tempMsgitem];
        CIM_MsgData *tempMsgData = [[CIM_MsgData alloc] init];
        tempMsgData.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        tempMsgData.m_dwExprSeconds  =  timeInterval;
        tempMsgData.m_msg = tempMsg;
        tempMsgData.m_n64GroupID = self.chattinggoup.m_n64GroupID;
        tempMsgData.m_cType = 0;
        [tempMsgData.m_aGroupID addObject:[NSNumber numberWithLongLong:self.chattinggoup.m_n64GroupID]];
        [tempMsgData sendSockPost];
        tempMsg.msg_Status = MSG_STATUS_Sending;
    }
}

- (void)inputBoxController:(FreshInputBoxController *)inputBoxController sendAttachment:(ContentInfo *)attachment{
    CIM_UploadData *tempFile = [[CIM_UploadData alloc] init];
    EMFileData *tempimage = [[EMFileData alloc] init];
    [tempimage readFile:attachment.thumpPath];
    tempFile.m_Data = tempimage;
    tempFile.m_cFileType = attachment.fileType;
    tempFile.m_strFileName = attachment.fileExtra;
    tempFile.m_n64UserID  = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
    tempFile.m_n64GroupID = self.chattinggoup.m_n64GroupID;
    [tempFile  setUploadCompletion: ^(CIM_UploadData *responseData, BOOL success){
        CNewMsg *tempMsg  = [[CNewMsg alloc] init];
        tempMsg.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        NSDate *nowDate = [NSDate date];
        NSTimeInterval timeInterval = [nowDate timeIntervalSince1970];
        tempMsg.m_dwExprSeconds  =  timeInterval;
        tempMsg.m_strMsgText = nil;
        tempMsg.m_n64GroupID = self.chattinggoup.m_n64GroupID;
        tempMsg.m_sMsgType  = 1;
        CMsgItem *tempMsgitem = [[CMsgItem alloc] init];
        [tempMsgitem createMsgItem:MSG_ITEM_TEXT int64:0 strItem:[NSString stringWithFormat:@"[2,%lld.png]",responseData.m_n64FileID]];
        [tempMsg.m_aItem addObject:tempMsgitem];
        CIM_MsgData *tempMsgData = [[CIM_MsgData alloc] init];
        tempMsgData.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        tempMsgData.m_dwExprSeconds  =  timeInterval;
        tempMsgData.m_msg = tempMsg;
        tempMsgData.m_n64GroupID = self.chattinggoup.m_n64GroupID;
        tempMsgData.m_cType = 0;
        [tempMsgData.m_aGroupID addObject:[NSNumber numberWithLongLong:self.chattinggoup.m_n64GroupID]];
        [tempMsgData sendSockPost];
        tempMsg.msg_Status = MSG_STATUS_Sending;
    }];
    [tempFile startUploadFile];
}

- (NSArray *)collectionView:(ChattingCollectionView *)collectionView menuItemsOnLongPressingBubbleViewInCell:(ChattingMessageCell *)cell {
    NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
    ChattingContent *content = [self.messages objectAtIndex:indexPath.row];
    NSMutableArray *items = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    if ([content supportCopyText]) {
        [items addObject:[ChattingCellAction actionWithTitle:@"复制" handler:^{
            [UIPasteboard generalPasteboard].string = [content text];
        }]];
    }
    
    if ([content supportForward]) {
        [items addObject:[ChattingCellAction actionWithTitle:@"转发" handler:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf->_selectedContent = content;
                NSMutableArray *tempArray = [NSMutableArray array];
                [tempArray addObject: [NSNumber numberWithLongLong:self.chattinggoup.m_n64GroupID]];
                InviteFriendViewController *controller = [[InviteFriendViewController alloc] initWithExceptGroupid:tempArray];
                controller.delegate = strongSelf;
                [strongSelf.navigationController pushViewController:controller animated:YES];
            }
        }]];
    }
//    if ([content supportDelete]) {
//        [items addObject:[ChattingCellAction actionWithTitle:@"删除" handler:^{
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            if (strongSelf){
//            }
//        }]];
//    }
//    if (content.status == RESOURCE_STATUS_UPLOADFAILED) {
//        [items addObject:[ChattingCellAction actionWithTitle:@"重发" handler:^{
//            [weakSelf resendMessageWithID:content.id];
//        }]];
//    }
    return items;
}

- (void)confirmInviteFriend:(CGroupMember *)selectedMember{
    if (selectedMember &&self.selectedContent) {
        if (self.selectedContent.contentType == ChattingContent_Text ||self.selectedContent.contentType == ChattingContent_SpecialEmo ) {
            CNewMsg *tempMsg  = [[CNewMsg alloc] init];
            tempMsg.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
            NSDate *nowDate = [NSDate date];
            NSTimeInterval timeInterval = [nowDate timeIntervalSince1970];
            tempMsg.m_dwExprSeconds  =  timeInterval;
            tempMsg.m_strMsgText = [NSString stringWithFormat:@"%@",self.selectedContent.text];
            tempMsg.m_n64GroupID = selectedMember.m_n64GroupID;
            tempMsg.m_sMsgType  = 1;
            CMsgItem *tempMsgitem = [[CMsgItem alloc] init];
            [tempMsgitem createMsgItem:MSG_ITEM_TEXT int64:0 strItem:self.selectedContent.text];
            [tempMsg.m_aItem addObject:tempMsgitem];
            CIM_MsgData *tempMsgData = [[CIM_MsgData alloc] init];
            tempMsgData.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
            tempMsgData.m_dwExprSeconds  =  timeInterval;
            tempMsgData.m_msg = tempMsg;
            tempMsgData.m_n64GroupID = selectedMember.m_n64GroupID;
            tempMsgData.m_cType = 0;
            [tempMsgData.m_aGroupID addObject:[NSNumber numberWithLongLong:self.chattinggoup.m_n64GroupID]];
            [tempMsgData sendSockPost];
        }else if (self.selectedContent.contentType ==ChattingContent_Image){
            CNewMsg *tempMsg  = [[CNewMsg alloc] init];
            tempMsg.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
            NSDate *nowDate = [NSDate date];
            NSTimeInterval timeInterval = [nowDate timeIntervalSince1970];
            tempMsg.m_dwExprSeconds  =  timeInterval;
            tempMsg.m_strMsgText = nil;
            tempMsg.m_n64GroupID = selectedMember.m_n64GroupID;
            tempMsg.m_sMsgType  = 1;
            CMsgItem *tempMsgitem = [[CMsgItem alloc] init];
            if (self.selectedContent.text&&self.selectedContent.text.length >0) {
                [tempMsgitem createMsgItem:MSG_ITEM_TEXT int64:0 strItem:self.selectedContent.text];
            }else{
                return;
            }
            [tempMsg.m_aItem addObject:tempMsgitem];
            CIM_MsgData *tempMsgData = [[CIM_MsgData alloc] init];
            tempMsgData.m_n64SenderID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
            tempMsgData.m_dwExprSeconds  =  timeInterval;
            tempMsgData.m_msg = tempMsg;
            tempMsgData.m_n64GroupID =selectedMember.m_n64GroupID;
            tempMsgData.m_cType = 0;
            [tempMsgData.m_aGroupID addObject:[NSNumber numberWithLongLong:self.chattinggoup.m_n64GroupID]];
            [tempMsgData sendSockPost];
            tempMsg.msg_Status = MSG_STATUS_Sending;
            
        }
    }
    
}

#pragma mark - ChattingCellContextDelegate

- (void)chattingCellContext:(ChattingCellContext *)context didSelectChattingContentView:(UIView *)chattingContentView forContentType:(ChattingContentType)contentType
{
    NSIndexPath *indexPath = [self.chattingCollectionView indexPathForDescendantOfView:chattingContentView];
    ChattingContent *content = [self.messages objectAtIndex:indexPath.row];
    switch (contentType) {
        case ChattingContent_Image:{
            if (content.contentType == ChattingContent_Image) {
                [self scanImageView:content origateView:chattingContentView];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)scanImageView:(ChattingContent *)content origateView:(UIView *)orgiView{
    NSMutableArray *browseItemArray = [[NSMutableArray alloc]init];
    MSSBrowseModel *browseItem = [[MSSBrowseModel alloc]init];
    CMsgItem *tempItem = [content.data objectAtIndex:0];
    UIImage *tempimage = [[EMCommData sharedEMCommData] getlocalFile:tempItem];
    browseItem.bigImage =tempimage;// 大图赋值
    browseItem.smallImageView = orgiView;// 小图
    [browseItemArray addObject:browseItem];
    
    MSSBrowseLocalViewController *bvc = [[MSSBrowseLocalViewController alloc]initWithBrowseItemArray:browseItemArray currentIndex:0];
    [bvc showBrowseViewController];
}

- (void)showBrowseViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0)
    {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    else
    {
        _snapshotView = [rootViewController.view snapshotViewAfterScreenUpdates:NO];
    }
    [rootViewController presentViewController:self animated:NO completion:^{
        
    }];
}


@end
