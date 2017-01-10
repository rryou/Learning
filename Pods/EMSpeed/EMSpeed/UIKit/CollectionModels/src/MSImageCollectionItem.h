//
//  MSImageCollectionItem.h
//  Coll
//
//  Created by Samuel on 15/4/16.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSCollectionCellModel.h"

@interface MSImageCollectionItem : NSObject <MSCollectionCellModel> 

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *title;

@end
