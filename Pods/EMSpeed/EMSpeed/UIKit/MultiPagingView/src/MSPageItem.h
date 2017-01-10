//
//  EMPageData.h
//  UI
//
//  Created by Samuel on 15/4/9.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSPageModel.h"

@interface MSPageItem : NSObject<MSPageModel>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
