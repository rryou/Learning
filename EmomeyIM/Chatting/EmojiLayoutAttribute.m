//
//  DMEmo.m
//  EmojProj
//
//  Created by ding xiuwei on 15/6/16.
//  Copyright (c) 2015年 ding xiuwei. All rights reserved.
//

#import "EmojiLayoutAttribute.h"
#define PAGECountColum 7 //固定个数
#define MIMMARGEWIDTH 5   // 固定间距
@implementation EmojiLayoutAttribute

-(NSInteger)calcluatePageCountWithMaxSize:(CGSize)maxSz
{
    if (ItemShowTypeFixCount == self.type)
    {
        self.sectionInsets = UIEdgeInsetsMake(15, 15, 21, 15);
        self.minimumInteritemSpacing = 15;
        self.itemW = 50;
        self.itemH = 70;
        self.minimumLineSpacing = 5;
        self.pageCount = 10;
        self.pageCountColum = 5;
        self.pageCountRow = 2;
        
        return 10;
    }
    else if(ItemShowTypeFlow == self.type)
    {
       // CGFloat minMargeWidth = (maxSz.width - self.sectionInsets.left - self.sectionInsets.right  - self.itemW * 6);
        self.minimumInteritemSpacing = MIMMARGEWIDTH;
        self.itemW =(maxSz.width -(PAGECountColum -1)*MIMMARGEWIDTH -self.sectionInsets.left - self.sectionInsets.right)/PAGECountColum;
        //NSInteger countColum = (maxSz.width - self.sectionInsets.left - self.sectionInsets.right)/(self.itemW + self.minimumInteritemSpacing);
        self.pageCountColum = PAGECountColum;
        NSInteger countRow = (maxSz.height - self.sectionInsets.top - self.sectionInsets.bottom)/(self.itemH + self.minimumLineSpacing);
        self.pageCountRow = countRow;
        
        return PAGECountColum *countRow;
    }
    else
    {
        return 10;
    }
}
@end
