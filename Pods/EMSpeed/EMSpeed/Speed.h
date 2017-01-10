//
//  EMSpeed.h
//  EMSpeed
//
//  Created by flora on 14-9-12.
//  Copyright (c) 2014年 flora. All rights reserved.
//
//

#ifndef SPEED_H_
#define SPEED_H_

#ifdef __has_include

#if __has_include(<EMSpeed/MSCore.h>)
#import <EMSpeed/MSCore.h>
#endif

#if __has_include(<EMSpeed/MSContext.h>)
#import <EMSpeed/MSContext.h>
#endif

#if __has_include(<EMSpeed/MSUIKit.h>)
#import <EMSpeed/MSUIKit.h>
#endif

#if __has_include(<EMSpeed/Network.h>)
#import <EMSpeed/Network.h>
#endif

#endif /* SPEED_H_ */

#else

#warning "Xcode7以下没有__has_include 请直接使用EMSpeed的子模块"

#endif /* __has_include */