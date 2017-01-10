//
//  EMImageCollectionViewCell.h
//  Coll
//
//  Created by Samuel on 15/4/16.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSCollectionCellUpdating.h"

@interface MSImageCollectionViewCell : UICollectionViewCell <MSCollectionCellUpdating>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
