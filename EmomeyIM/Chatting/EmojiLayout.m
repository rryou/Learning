//
//  MyLayout.m
//  EmojProj
//
//  Created by ding xiuwei on 15/6/17.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import "EmojiLayout.h"
#import "DMEmo.h"

@interface EmojiLayout ()
{
    CGSize _contentSize;
}
@end


@implementation EmojiLayout
- (void)invalidateLayout
{
    [super invalidateLayout];
}
- (void)registerClass:(Class)viewClass forDecorationViewOfKind:(NSString *)elementKind
{
    [super registerClass:viewClass forDecorationViewOfKind:elementKind];
}
- (void)prepareLayout
{
    [super prepareLayout];
    _contentSize =  CGSizeMake(self.collectionView.frame.size.width * self.dataArr.count, self.collectionView.frame.size.height);
}

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *arr = [super layoutAttributesForElementsInRect:rect];
    if ([arr count] > 0) {
        return arr;
    }
    NSMutableArray *attributes = [NSMutableArray array];
    NSInteger section = self.dataArr.count;
    for (NSInteger i = 0; i < section ;i ++)
    {
        NSArray *temp = [self.dataArr objectAtIndex:i];
        NSInteger rows = [temp count];
        for (NSInteger j = 0;j< rows;j++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }

    return attributes;

}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    DMEmo *emo = [[self.dataArr objectAtIndex:section] objectAtIndex:row];
    
    NSInteger margin = emo.layoutAttribute.sectionInsets.left;
    NSInteger itemW = emo.layoutAttribute.itemW;
    NSInteger itemH = emo.layoutAttribute.itemH;
    NSInteger x = section*self.collectionView.frame.size.width;
    NSInteger y = 0;
    if (ItemShowTypeFixCount == emo.layoutAttribute.type)
    {
        int countColum = 5;

        int cap = (self.collectionView.frame.size.width - 2*margin - countColum*itemW)/(countColum - 1);
        x += (row%countColum)*(cap + itemW) + margin;
        y += (row/countColum) * (cap + itemH) + 11;
        attributes.frame = CGRectMake(x,y,itemW,itemH);
    }
    else 
    {
        NSInteger countColum = emo.layoutAttribute.pageCountColum;
        CGFloat capColum = (self.collectionView.frame.size.width - 2*margin - countColum*itemW)/(countColum - 1);
        x += (row%countColum)*(capColum + itemW) + emo.layoutAttribute.sectionInsets.left;
        CGFloat rowCap = (self.collectionView.frame.size.height - emo.layoutAttribute.sectionInsets.top - emo.layoutAttribute.sectionInsets.bottom - emo.layoutAttribute.pageCountRow*itemH)/(emo.layoutAttribute.pageCountRow - 1);
        y += (row/countColum) * (rowCap + itemH) + emo.layoutAttribute.sectionInsets.top;
        attributes.frame = CGRectMake(x,y,itemW,itemH);
    }
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

//根据type 计算 配置行数和每页的列数
//- (NSInteger)
@end
