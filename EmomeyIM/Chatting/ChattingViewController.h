//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingCollectionView.h"
#import "ChattingCellContext.h"
#import "ChattingCollectionViewCell.h"
#import "ChattingContentViewBuilder.h"
#import "ChattingOutgoingCell.h"
#import "ChattingInputBoxController.h"
#import "BaseViewController.h"
#import "UserInfo.h"
extern NSString * const kReuseIdentifier_ChattingIncomingCell;
extern NSString * const kReuseIdentifier_ChattingOutgoingCell;
extern NSString * const kReuseIdentifier_ChattingTipCell;

typedef NS_ENUM(NSUInteger, LoadDataFromDBType)
{
    LoadDataFromDBType_First,       //第一次 加载 即最新数据
    LoadDataFromDBType_Older,       //获取更早的数据
    LoadDataFromDBType_Newer,       //获取更新数据
};

@interface ChattingViewController : BaseViewController <
    ChattingCollectionViewDelegate,
    ChattingCellContextDelegate,
    ChattingCollectionViewDataSource,
    FreshInputBoxControllerDelegate,
    FreshInputBoxSeparatedlySender
>
@property (nonatomic, strong)  CGroupBase *chattinggoup;
@property (nonatomic, readonly) ChattingCollectionView *chattingCollectionView;
@property (nonatomic, readonly) ChattingCellContext *chattingCellContext;
@property (nonatomic, readonly) ChattingInputBoxController *inputBoxController;
@property (nonatomic, strong) NSMutableDictionary *attriDict;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, assign) BOOL isServerDataAll;
@property (nonatomic, strong) ChattingContentViewBuilder *chattingContentViewBuilder;
// 默认YES
- (instancetype)initWithInputBox:(BOOL)withInputBox;

- (void)setBackItemEnable:(bool)showBack;
- (Class)chattingInputBoxControllerClass;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (ChattingContentSource)sourceOfChattingContent:(ChattingContent *)content;

- (ChattingOutgoingStatus)outgoingStatusOfChattingContent:(ChattingContent *)content;

- (UIView<ReusableViewProtocol> *)contentViewOfChattingContent:(ChattingContent *)content;

- (UIView<ReusableViewProtocol> *)contentViewOfChattingContent:(ChattingContent *)content index:(NSInteger)index;

- (UIView<ReusableViewProtocol> *)bottomContentViewOfChattingContent:(ChattingContent *)content;

- (ChattingCellDisplayAttribute *)displayAttributeOfChattingContent:(ChattingContent *)content;

- (void)didSelectAvatarOnChattingContent:(ChattingContent *)chattingContent;

- (void)willLoadCell:(ChattingCollectionViewCell *)cell forContent:(ChattingContent *)chattingContent atIndexPath:(NSIndexPath *)indexPath;

- (NSString *)dateStringOfChattingContent:(ChattingContent *)content;

- (BOOL)showIncomingUserName;

//FreshControll
-(void)addRefreshControl;
-(void)removeRefreshControl;
-(void)endRefreshControl;
-(void)hidenRefreshControl;
-(void)showRefreshControl;
//以下加载数据的方法  子类一般需要实现各自具体的内容
-(void)clearPMlistCount;
-(void)setEnterState;
- (void)saveDraft;
- (NSString*)getDraft;
- (UserInfo *)getUserInfo;
/**
 *  第一次从db 获取数据
 */
/**
 *  从db获取更早的数据，如果没有数据，可能需要想服务器获取
 */
-(void)loadOlderDataFromDB;
/**
 *  从db加载刷新的数据 比如  收到一条信息; 从服务器获取了信息
 */
-(void)loadreFreshDataFromDB;
/**
 *  此方法必须同步  调用 不然数据有可能 出错
 *
 *  @param success  <#success description#>
 *  @param time     <#time description#>
 *  @param mssageId <#mssageId description#>
 *  @param fakeId   <#fakeId description#>
 */
-(void)syncHandleFakeMessageWithIsSuccess:(BOOL)success withTime:(NSString*)time withMessageId:(NSString*)mssageId withFakeId:(NSString*)fakeId withIsReSend:(BOOL)resend withIsDelete:(BOOL)dele;
-(void)syncHandleFakeMessageWithIsSuccess:(BOOL)success withServerData:(ChattingContent*)chat withFakeId:(NSString*)fakeId withIsReSend:(BOOL)resend withIsDelete:(BOOL)dele;
/**
 *  从数据库dic 转换到 ChattingContent  不同的子类 可能是不同的db dic
 *
 *  @param dic <#dic description#>
 *
 *  @return <#return value description#>
 */
-(ChattingContent*)composeChattingContentFromDic:(NSDictionary*)dic;

-(ChattingContent*)convertToChattingContentFromObj:(id)data;
/**
 *   可以放到后台线程中执行
 *
 *  @param arr  <#arr description#>
 *  @param type <#type description#>
 */
- (void)loadMessages:(NSArray *)arr withLoadDataFromDBType:(LoadDataFromDBType)type;
/**
 *  去重复数据，，收到对方消息也可能会有重复的  比如：对方连续发两条数据，取数据库读取两次，但由于加载解析数据慢，messages数组中数据并不是最新的。
 */
//删除某一条 内存中的数据，并更新界面    如：对方删除了刚发的一条消息。
- (void)deleteOneMessageInMemoryAndUIByMessageId:(NSString*)msgId;
- (ChattingContent*)lastRightTimeChattingContent;
- (ChattingContent*)firstRightTimerChattingContent;

@end
