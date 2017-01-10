//
//  HandleDataModel.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




@interface UIImage(Extras)

//crop 
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
//2.保持原来的长宽比，生成一个缩略图
- (UIImage *)thumbnailWithImageScale:(CGSize)asize;
//.自动缩放到指定大小
- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize;
//3.
+(UIImage *)addImage:(UIImage *)imageIner toImage:(UIImage *)imageBg withEdgeInsets:(UIEdgeInsets)e;

+ (UIImage *)resizableImageWithName:(NSString *)imageName capInsets:(UIEdgeInsets)capInsets fixedSize:(CGSize)fixedSize;

-(UIImage *)convertImgOrientation;
- (UIImage *)clipImageby:(CGSize)asize;


//方法说明：根据提供的位置和范围，将屏幕图像生成为UIImage并放回
//参数1 aView : 待剪切的原始UIView
//参数2 rect  : 剪切范围
+ (UIImage *) cropImageFrom:(UIView *)view inRect:(CGRect)rect;

// 把图片按相框比例 缩放后 放在相框中的frame
+(CGRect)getCropFrame:(CGRect)f withImgSize:(CGSize)imgSize;

//
//+ (UIImage *)blurryImage2:(UIImage *)image
//            withBlurLevel:(CGFloat)blur;

+ (UIImage *)fixOrientation:(UIImage *)aImage;
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;


/**
 *  反锯齿后的uiimage ：原理：加一个透明的边
 *
 *  @return <#return value description#>
 */
- (UIImage*)antialiasedImage;
/**
 *  反锯齿后的uiimage
 *
 *  @param size 最大size 按照size的长宽比例 clip 图片
 *
 *  @return <#return value description#>
 */
- (UIImage*)antialiasedImageClipWithSize:(CGSize)size;

- (UIImage *) addWaterMark:(UIImage *)markImage inRect:(CGRect)rect;


@end
