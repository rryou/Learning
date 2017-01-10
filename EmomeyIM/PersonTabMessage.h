//
//  PersonTabMessage.h
//  EmomeyIM
//
//  Created by yourongrong on 16/10/10.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LabelMessage;
@interface PersonTabMessage : NSObject
@property (nonatomic, strong) NSMutableArray <LabelMessage *> *pagelistarray;
@property (nonatomic, strong) NSString *name;
@end


@interface LabelMessage : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *itemarry;
@end