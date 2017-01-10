//
//  EMFunctioncGuidModel.h
//  UIDemo
//
//  Created by Samuel on 15/4/27.
//  Copyright (c) 2015年 Samuel. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MSGuideScrollModel <NSObject>
@required

/**
 *  model对应的cell类
 */
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, assign) UIViewContentMode contentMode;

@end