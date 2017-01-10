//
//  EmojiView.m
//  LoochaCampusMain
//
//  Created by ding xiuwei on 15/6/23.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//


/**
 *  实现方案
 *  所有的数据处理好。组成一个两层的数组。
 外层是反映有多少个section。内层数组反映的是每个section所包含的cell。一个section对应一页，所以，不同页（section）对应的cell个数可能不同。
 */


#import "EmojiView.h"

#import "EmojiLayout.h"
#import "EmojiLayoutAttribute.h"
#import "NSArray+Extends.h"
#import "EmojiCell.h"
#import "DMEmo.h"
#import "EmojiTabType.h"
#import "EmojiPreview.h"
#import <EMSpeed/MSUIKitCore.h>
#define kPhizCount (119)

@interface EmojiView () <UICollectionViewDelegate,UICollectionViewDataSource>
{
    UICollectionView *_contetnPan;
    NSMutableArray *_typeArr;           //元素是某一个类型表情的数组
    NSMutableArray *_sectionCellArr;   // 存放section（页）
    UIPageControl *_pageControl;
    EmojiPreview *_preView;
    
//    EmojiTabarBar *_bar;
    NSMutableArray *_tabBarArr;
    
    BOOL isHasLastEmoji;
    BOOL downEmojisChanged;
}
@property (nonatomic, strong) NSMutableArray *staticEmojiList;
@property (nonatomic, strong) NSDictionary *pickstaticListDic;
@property (nonatomic, assign) CGRect selecRect;
@property (nonatomic, strong) EmojiCell *selectCell;
@end

@implementation EmojiView
#define EmoCellIdentifier     @"EmoCellIdentifier"
#define ContentPanHeight      (216)
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgView.image = [[UIImage imageNamed:@"inputbox_bar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 3, 0, 3)];
        [self addSubview:bgView];
        
        self.backgroundColor = [UIColor whiteColor];
        _typeArr = [[NSMutableArray alloc] init];
        _sectionCellArr = [[NSMutableArray alloc] init];
        _tabBarArr  = [[NSMutableArray alloc] init];
        
        self.staticEmojiList = [[NSMutableArray alloc] init];
        self.pickstaticListDic = [NSMutableDictionary dictionary];
        [self createBaseDatalist];
        
        EmojiLayout *layout = [[EmojiLayout alloc] init];
        
        _contetnPan = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, ContentPanHeight) collectionViewLayout:layout];
        _contetnPan.backgroundColor = [UIColor whiteColor];
        _contetnPan.delegate = self;
        _contetnPan.dataSource = self;
        _contetnPan.showsHorizontalScrollIndicator = NO;
        _contetnPan.showsVerticalScrollIndicator = NO;
        [self addSubview:_contetnPan];
        _contetnPan.pagingEnabled = YES;
        [_contetnPan registerClass:[EmojiCell class] forCellWithReuseIdentifier:EmoCellIdentifier];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_contetnPan.frame) - 25, self.frame.size.width, 20)];
        [self addSubview:_pageControl];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.currentPageIndicatorTintColor =  RGB(64, 115, 200);
        _pageControl.pageIndicatorTintColor =  RGB(230, 230, 230);
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPage = 1;
        
        if (isHasLastEmoji)
        {
            _pageControl.numberOfPages = 1;
        }else
        {
            _pageControl.numberOfPages = 7;
        }
        
        _preView = [[EmojiPreview alloc] init];
        _preView.alpha = 0;
        [self addSubview:_preView];
    
        layout.dataArr = _sectionCellArr;
        [self reloadData];
    }
    return self;
}

- (void)disabledByDynamicEmojis{
//    [_bar setAddDynamicbtnDisable];
    [self reloadData];
}

- (void)resetSortNum:(NSInteger)sortNumber setSortlist :(NSArray *)arrlist {
    
    for (DMEmo *tempemo in arrlist) {
        EmojiLayoutAttribute *emoAtrri = tempemo.layoutAttribute;
        emoAtrri.typeSortNum = sortNumber;
    }
}

- (void)reloadDownEmjis{
    downEmojisChanged =YES;
    [self reloadData];
}

-(void)reloadData{
    int sortNum = 0;
    [_typeArr removeAllObjects];           //元素是某一个类型表情的数组
    [_sectionCellArr removeAllObjects];   // 存放section（页）
    [_tabBarArr removeAllObjects];
    EmojiTabType *statictab = [[EmojiTabType alloc]initWithType:EmoTabType_static withName:@"" withSrc:nil];
    [_tabBarArr addObject:statictab];
    [self resetSortNum:sortNum setSortlist:self.staticEmojiList];
    [_typeArr addObject:self.staticEmojiList];
    sortNum ++;
    [self generateSectionData];
    [_contetnPan reloadData];
}

- (void)getStaticEmojis{

    int actionCount = 0;
    for(NSInteger i = 1; i < (kPhizCount +1) ;i ++)
    {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setPositiveFormat:@"000"];
            NSString *key = [NSString stringWithFormat:@"emo%@", [numberFormatter stringFromNumber:[NSNumber numberWithInteger:i]]];
            NSString *name = [self.pickstaticListDic objectForKey:key];
            DMEmo *emo = [[DMEmo alloc] initWithName:name src:key];
            emo.type = LocalEmoTypeNormal;
            EmojiLayoutAttribute *emoAtrri = [[EmojiLayoutAttribute alloc] init];
            emoAtrri.type = ItemShowTypeFlow;
            emoAtrri.itemH = 40;
            emoAtrri.itemW = 40;
            emoAtrri.sectionInsets = UIEdgeInsetsMake(25, 25, 35, 25);
            emoAtrri.minimumInteritemSpacing = 5;
            emoAtrri.minimumLineSpacing = 3;
            emoAtrri.pageCount = [emoAtrri calcluatePageCountWithMaxSize:CGSizeMake(self.frame.size.width, ContentPanHeight)];
            emoAtrri.pageNum = ((i -1) + actionCount)/emoAtrri.pageCount;
            emoAtrri.pageSunNum = (kPhizCount +actionCount-1)/emoAtrri.pageCount + 1;
            emo.layoutAttribute = emoAtrri;
            [self.staticEmojiList addObject:emo];
        }
}

- (void)createBaseDatalist{
    NSString *pickListPath = [[NSBundle mainBundle] pathForResource:@"PhizPickList" ofType:@"plist"];
    self.pickstaticListDic = [NSDictionary dictionaryWithContentsOfFile:pickListPath];
    [self getStaticEmojis];
}

//根据表情的类型和个数 及当前界面的size 确定
-(void)generateSectionData
{
    for (NSArray *arr in _typeArr)
    {
        DMEmo *demo = [arr firstObject];
        [_sectionCellArr addObjectsFromArray:[arr divideGroupWithPreCount:demo.layoutAttribute.pageCount]];
    }
}

#pragma mark-  UICollectionViewDataSource <NSObject>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *tempArr = [_sectionCellArr objectAtIndex:section];
    NSInteger x = [tempArr count];
    return x;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _sectionCellArr.count;
}

- (void)longPressCallBack:(UILongPressGestureRecognizer *)g cell:(EmojiCell *)weakCell indexPath:(NSIndexPath *)indexPath
{
    //显示 or 隐藏 _preView
    if(UIGestureRecognizerStateEnded == g.state ||
       UIGestureRecognizerStateFailed == g.state)
    {
        _preView.alpha = 0;
        [self.selectCell setSelected:NO];
    }
    else
    {
        _preView.alpha = 1;
        //选中的cell 变色
        CGPoint gesturePoint = [g locationInView:self];
        
        for (EmojiCell *tempCell in [_contetnPan visibleCells])
        {
            CGRect rec = [self convertRect:tempCell.frame toView:self];
            CGRect currentPageRect = CGRectMake(rec.origin.x - indexPath.section * self.frame.size.width, rec.origin.y, rec.size.width, rec.size.height);
            if (CGRectContainsPoint(currentPageRect, gesturePoint)){
                [self.selectCell setSelected:NO];
                [tempCell setSelected:YES];
                self.selectCell = tempCell;
                self.selecRect = currentPageRect;
            }
            else{
                
            }
        }
        //       设置_preView Frame
        if (!CGRectIsEmpty(self.selecRect))
        {
            //if (emo.type == -1)
            {
                CGFloat ajustX = 0.0;
                //UI 给的宽和高
                int cap = 5;
                int preViewWidth = 106;
                int preViewHight = 83;
                
                CGFloat dx = self.selecRect.origin.x -(preViewWidth- weakCell.frame.size.width)/2 ;
                if (dx < 0){
                    ajustX = cap;
                    _preView.arowOffsetX =  -(preViewWidth/2) + CGRectGetMidX(self.selecRect) - cap;
                }
                else if(dx+ preViewWidth > self.frame.size.width){
                    ajustX = self.frame.size.width - preViewWidth- cap;
                    _preView.arowOffsetX =  (preViewWidth/2) -(self.frame.size.width - CGRectGetMidX(self.selecRect)) + cap ;
                }
                else{
                    ajustX = dx;
                    _preView.arowOffsetX = 0;
                    
                }
                NSIndexPath *selectIndex = [_contetnPan indexPathForCell:self.selectCell];
                DMEmo *selectedEmo = [[_sectionCellArr objectAtIndex:selectIndex.section] objectAtIndex:selectIndex.row];
                _preView.frame = CGRectMake(ajustX, self.selecRect.origin.y - preViewHight, preViewWidth, preViewHight);
                [_preView loadData:selectedEmo];
            }
        }
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EmojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EmoCellIdentifier forIndexPath:indexPath];
    DMEmo *emo = [[_sectionCellArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell loadData:emo];
    
    __weak EmojiCell *weakCell = cell;
    __weak typeof(self) weakSelf = self;
    
    cell.longPressCallBack  = ^(UILongPressGestureRecognizer *g)
    {
        [weakSelf longPressCallBack:g cell:weakCell indexPath:indexPath];
    };
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger page =  (scrollView.contentOffset.x)/(_contetnPan.frame.size.width);
    if ( scrollView.contentOffset.x == 0) {
       [self reloadData];
    }
    [self freshPageControl:page];
}

- (void)freshPageControl:(NSInteger)page{
    NSArray *arr = [_sectionCellArr objectAtIndex:page];
    DMEmo *emo = [arr firstObject];
    _pageControl.currentPage = emo.layoutAttribute.pageNum;
    _pageControl.numberOfPages = emo.layoutAttribute.pageSunNum;

}

//根据当前第几页 获取当前是在哪个type ，在当前type第几页
-(NSInteger)calculateTypePage:(NSInteger)num{
    NSInteger page = 0;
    for (int i = 0; i < _typeArr.count; i ++)
    {
        if (i == num) {
            break;
        }
        DMEmo *emo = [[_typeArr objectAtIndex:i] firstObject];
        page += emo.layoutAttribute.pageSunNum;
    }
    return page;
}
//根据是第几个type 滚动到这个type的第一页
-(void)scrollToTypePage:(NSInteger)num animated:(BOOL)animated
{
    NSInteger page = [self calculateTypePage:num];
    [_contetnPan scrollRectToVisible:CGRectMake(page*_contetnPan.frame.size.width, 0, _contetnPan.frame.size.width, _contetnPan.frame.size.height) animated:animated];
}

-(void)scrollToTypePage:(NSInteger)num
{
    [self scrollToTypePage:num animated:YES];
}

#pragma mark ---  EmojiTabarBarDelegate
- (void)tapType:(NSInteger)num withType:(EmojiTabType *)type{
    [self scrollToTypePage:num animated:NO];
}

#pragma  UICollectionViewDelegate <UIScrollViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    DMEmo *emo = [[_sectionCellArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.delegate emojiView:self didSelecte:emo];
//    EmojiDao *tempDao = [[EmojiDao alloc]init];
    NSString *emoijId = nil;
    if (emo.type == LocalEmoTypeNormal) {
        emoijId = emo.name;
    }
}

+ (CGFloat)viewHeight
{
    return 216;
}

@end
