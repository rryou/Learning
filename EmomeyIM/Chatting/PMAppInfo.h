//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMAppInfo : NSObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *package_name;
@property (nonatomic, retain) NSString *open_class_name;
@property (nonatomic, retain) NSString *ios_package_name;
@property (nonatomic, retain) NSString *open_id;

@property (nonatomic, retain) NSArray *extra_data;
@property (nonatomic, retain) NSString *object_data;

@end
