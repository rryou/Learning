//
//  EMImageCollectionViewCell.m
//  Coll
//
//  Created by Samuel on 15/4/16.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import "MSImageCollectionViewCell.h"
#import "MSImageCollectionItem.h"
#import "UIImageView+DownloadIcon.h"


@implementation MSImageCollectionViewCell

- (void)update:(id<MSCollectionCellModel>)cellModel
{
    if ([cellModel isKindOfClass:[MSImageCollectionItem class]]) {
        
    }
}
- (void)update:(id<MSCollectionCellModel>)cellModel indexPath:(NSIndexPath *)indexPath
{
    if ([cellModel isKindOfClass:[MSImageCollectionItem class]]) {
        MSImageCollectionItem *item = cellModel;
        
        UIImage *image = [UIImage imageNamed:item.imageURL];
        if (!image) {
            [self.imageView ms_setImageWithURL:[NSURL URLWithString:item.imageURL] localCache:YES];
        }
        else{
            self.imageView.image = image;
        }
        self.titleLabel.text = item.title;
    }
}

+ (UIImage *)placeholderImage
{
    return nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
