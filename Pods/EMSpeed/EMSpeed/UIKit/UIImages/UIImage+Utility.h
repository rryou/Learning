//
//  UIImage+capture.h
//  EMSpeed
//
//  Created by flora deng on 3/13/12.
//  Copyright (c) 2012 Emoney.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Utility)

/**
 * 截取屏幕
 * 是否需要?
 */
+ (UIImage *)ms_captureScreen:(CGFloat)resolution NS_EXTENSION_UNAVAILABLE_IOS("Use view controller based solutions where appropriate instead.");


/**
 * 剪切出一个rect
 */
- (UIImage *)ms_clipWithRect:(CGRect)rect;


/**
 * 根据颜色返回一张图片
 */
+ (UIImage *)ms_imageWithColor:(UIColor *)color;


/**
 *  width	Width given, height automagically selected to preserve aspect ratio.
 *  xheight	Height given, width automagically selected to preserve aspect ratio.
 *  widthxheight	Maximum values of height and width given, aspect ratio preserved.
 *  widthxheight^	Minimum values of width and height given, aspect ratio preserved.
 *  widthxheight!	Exact dimensions, no aspect ratio preserved.
 *  widthxheight#	Crop to this exact dimensions.
 *
 *  @param 字符串
 *
 *  @return 图片
 */
- (UIImage *)ms_resizedImageByMagick:(NSString *)spec;


/**
 *  根据宽度重新创建一个等比例的图片
 *
 *  @param width 宽度
 *
 *  @return 图片
 */
- (UIImage *)ms_resizedImageByWidth:(NSUInteger)width;


/**
 *  根据高度重新创建一个等比例的图片
 *
 *  @param width 高度
 *
 *  @return 图片
 */
- (UIImage *)ms_resizedImageByHeight:(NSUInteger)height;


/**
 *  根据size最长边, 重新创建一个等比例的图片
 *
 *  @param 高和宽尺寸
 *
 *  @return 图片
 */
- (UIImage *)ms_resizedImageWithMaximumSize:(CGSize)size;


/**
 *  根据size最短边, 重新创建一个等比例的图片
 *
 *  @param 高和宽尺寸
 *
 *  @return 图片
 */
- (UIImage *)ms_resizedImageWithMinimumSize:(CGSize)size;

@end
