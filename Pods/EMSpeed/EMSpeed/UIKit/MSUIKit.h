//
//  MSHTTP.h
//  EMStock
//
//  Created by flora on 14-9-12.
//  Copyright (c) 2014年 flora. All rights reserved.
//
//

#ifndef MSUIKIT_H
#define MSUIKIT_H

#ifdef __has_include

#if __has_include(<EMSpeed/MSUIKitCore.h>)
#import <EMSpeed/MSUIKitCore.h>
#endif

#if __has_include(<EMSpeed/MSAnimations.h>)
#import <EMSpeed/MSAnimations.h>
#endif

#if __has_include(<EMSpeed/CollectionModels.h>)
#import <EMSpeed/CollectionModels.h>
#endif

#if __has_include(<EMSpeed/FontAwesome.h>)
#import <EMSpeed/FontAwesome.h>
#endif

#if __has_include(<EMSpeed/GuideView.h>)
#import <EMSpeed/GuideView.h>
#endif

#if __has_include(<EMSpeed/MultiPaging.h>)
#import <EMSpeed/MultiPaging.h>
#endif


#if __has_include(<EMSpeed/PopupView.h>)
#import <EMSpeed/PopupView.h>
#endif

#if __has_include(<EMSpeed/StatusBar.h>)
#import <EMSpeed/StatusBar.h>
#endif

#if __has_include(<EMSpeed/TableModels.h>)
#import <EMSpeed/TableModels.h>
#endif


#if __has_include(<EMSpeed/UIColors.h>)
#import <EMSpeed/UIColors.h>
#endif

#if __has_include(<EMSpeed/UIImages.h>)
#import <EMSpeed/UIImages.h>
#endif


#if __has_include(<EMSpeed/UIKitCollections.h>)
#import <EMSpeed/UIKitCollections.h>
#endif

#if __has_include(<EMSpeed/WebImage.h>)
#import <EMSpeed/WebImage.h>
#endif


#endif /* MSUIKIT_H */

#else

#warning "Xcode7以下没有__has_include 请直接使用EMSpeed/UIKit的子模块"

#endif /* __has_include */