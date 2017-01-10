//
//  MSStatusBarModel.h
//  UI
//
//  Created by Samuel on 15/4/9.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSStatusBarUpdating;
@protocol MSStatusBarModel <NSObject>

@property (nonatomic, strong) NSString *title;   // 标题
@property (nonatomic, strong) Class viewClass;  // view的class

@required
- (UIView<MSStatusBarUpdating> *)statusBarWithData:(id<MSStatusBarModel>)data;

@end

