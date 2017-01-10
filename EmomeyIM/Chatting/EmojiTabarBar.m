//
//  EmojiTabarBar.m
//  EmojProj
//
//  Created by ding xiuwei on 15/6/18.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import "EmojiTabarBar.h"
#import "EmojiTabBarCell.h"
#import <EMSpeed/MSUIKitCore.h>
#import "UIImage+Utility.h"
//#import "Emojis_constants.h"
@interface EmojiTabarBar () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSArray *_dataArr;
//    EmojiTabBarCell *_selectedCell;
    UICollectionView *_collection;
    UIButton *_addEmojibtn;
    UIView *_newEmojiview;
}
@property (nonatomic, assign) BOOL needAddBtn;
@end

@implementation EmojiTabarBar

#define CellIdentifier          @"CellIdentifier"
#define CellWidth      (50)
- (instancetype)initWithFrame:(CGRect)frame withData:(NSArray*)arr
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
//        _selectedCell = nil;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(CellWidth, 30);
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        CGFloat collectWidth = self.bounds.size.width - 50;
        _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, collectWidth, self.bounds.size.height) collectionViewLayout:layout];
        _collection.delegate = self;
        _collection.dataSource = self;
        _collection.showsHorizontalScrollIndicator = NO;
        [self addSubview:_collection];
//        [_collection registerClass:[EmojiTabBarCell class] forCellWithReuseIdentifier:CellIdentifier];
        _collection.backgroundColor = [UIColor clearColor];
        _dataArr = arr;
        
        UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        [self addSubview:line1];
        line1.backgroundColor = RGB(234, 234, 234);
        //(0xccd2dc);
        
        UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(13, 3, 24, 24)];
        tempView.layer.contents = (id)[UIImage imageNamed:@"addEmojis"].CGImage;
    }
    return self;
}


- (void)setAddDynamicbtnDisable{
    _addEmojibtn.hidden = YES;
    [self reloadData];
}

#pragma mark- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArr.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EmojiTabBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell loadData:_dataArr[indexPath.row]];
    return cell;
}

//-(void)freshCellBackgroudColor:(EmojiTabBarCell *)cell
//{
//    _selectedCell.backgroundColor = [UIColor clearColor];
//    _selectedCell = cell;
//    _selectedCell.backgroundColor = RCColorWithValue(0xccd2dc);
//}

- (void)selectItemAtIndex:(NSInteger)index
{
    [_collection selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                              animated:YES
                        scrollPosition:UICollectionViewScrollPositionNone];
//    [self displayBigPhotoAtIndex:index];
}

#pragma mark- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

        EmojiTabType *type = [_dataArr objectAtIndex:indexPath.row];

            [self selectItemAtIndex:indexPath.row];

        [self.delegate tapType:indexPath.row withType:type];
}

- (void)scrollViewToNumber:(NSInteger)n
{
    NSIndexPath *path = [NSIndexPath indexPathForItem:n inSection:0];
//    EmojiTabBarCell *cell = (EmojiTabBarCell*)[_collection cellForItemAtIndexPath:path];
//    [self freshCellBackgroudColor:cell];
    [self selectItemAtIndex:n];
    [_collection scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}
#pragma mark- UICollectionViewDelegateFlowLayout


-(void)reloadData
{
    [_collection reloadData];
    
    [self performSelector:@selector(didTabLoaded) withObject:nil afterDelay:0];
}

- (void)didTabLoaded{
    
    if ([_collection numberOfItemsInSection:0] > 0) {
        [self scrollViewToNumber:0];
        EmojiTabType *type = [_dataArr objectAtIndex:0];
        [self.delegate tapType:0 withType:type];
    }
}

@end
