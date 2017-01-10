//
//  HandleDataModel.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.

#import "UIImage+Extras.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
//#import <Accelerate/Accelerate.h>
static inline CGRect ScaleRect(CGRect rect, float n) {return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);}


@implementation UIImage(Extras)


- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize{
    
    UIImage *sourceImage = self;  
    UIImage *newImage = nil;          
    CGSize imageSize = sourceImage.size;  
    CGFloat width = imageSize.width;  
    CGFloat height = imageSize.height;  
    CGFloat targetWidth = targetSize.width;  
    CGFloat targetHeight = targetSize.height;  
    CGFloat scaleFactor = 0.0;  
    CGFloat scaledWidth = targetWidth;  
    CGFloat scaledHeight = targetHeight;  
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);  
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)   
    {  
        CGFloat widthFactor = targetWidth / width;  
        CGFloat heightFactor = targetHeight / height;  
        if (widthFactor > heightFactor)   
            scaleFactor = widthFactor; // scale to fit height  
        else  
            scaleFactor = heightFactor; // scale to fit width  
        scaledWidth  = width * scaleFactor;  
        scaledHeight = height * scaleFactor;  
        // center the image  
        if (widthFactor > heightFactor)  
        {  
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;   
        }  
        else   
            if (widthFactor < heightFactor)  
            {  
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;  
            }  
    }         
    UIGraphicsBeginImageContext(targetSize); // this will crop  
    CGRect thumbnailRect = CGRectZero;  
    thumbnailRect.origin = thumbnailPoint;  
    thumbnailRect.size.width  = scaledWidth;  
    thumbnailRect.size.height = scaledHeight;  
    [sourceImage drawInRect:thumbnailRect];  
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newImage;  
}  

//.自动缩放到指定大小
- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    UIGraphicsBeginImageContext(asize);
    [self drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
    newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
    
}
//2.保持原来的长宽比，生成一个缩略图
- (UIImage *)thumbnailWithImageScale:(CGSize)asize

{
    
    UIImage *newimage;
    CGSize oldsize = self.size;
    CGRect rect;
    
    if (asize.width/asize.height > oldsize.width/oldsize.height) 
    {
        
        rect.size.width = asize.height*oldsize.width/oldsize.height;
        rect.size.height = asize.height;
        rect.origin.x = 0;
        rect.origin.y = 0;
        
    }
    
    else
    {
        
        rect.size.width = asize.width;
        rect.size.height = asize.width*oldsize.height/oldsize.width;
        rect.origin.x = 0;
        rect.origin.y = 0;
        
    }
    
    newimage = [UIImage imageWithCGImage:self.CGImage scale:self.size.width/rect.size.width orientation:self.imageOrientation];

    return newimage;
    
}

- (UIImage *)clipImageby:(CGSize)asize

{
    
    CGRect rect = CGRectZero;
    rect.size.width = self.size.width;
    rect.size.height = asize.height * self.size.width / asize.width;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
    
}

+ (UIImage *)resizableImageWithName:(NSString *)imageName capInsets:(UIEdgeInsets)capInsets fixedSize:(CGSize)fixedSize
{
    UIImage *image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
    UIGraphicsBeginImageContext(fixedSize);
    [image drawInRect:CGRectMake(0, 0, fixedSize.width, fixedSize.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+(UIImage *)addImage:(UIImage *)imageIner toImage:(UIImage *)imageBg withEdgeInsets:(UIEdgeInsets)e
{
    UIGraphicsBeginImageContext(imageBg.size);
    [imageBg drawInRect:CGRectMake(0, 0, imageBg.size.width, imageBg.size.height)];
    //[imageIner drawInRect:CGRectMake(imageBg.size.width/2 - imageIner.size.width/2 , imageBg.size.height/2 - imageIner.size.height/2, imageIner.size.width, imageIner.size.height)];
    [imageIner drawInRect:CGRectMake(e.left , e.top, imageIner.size.width, imageIner.size.height)];

    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}




-(UIImage *)convertImgOrientation
{
    CGSize maxSize = [UIScreen mainScreen].currentMode.size;
    CGSize imageSize = self.size;
    if (imageSize.width == 0 || imageSize.height == 0) {
        return nil;
    }
    CGSize targetSize = imageSize;
    if (imageSize.width/imageSize.height > maxSize.width/maxSize.height) {
        if (targetSize.width > maxSize.width) {
            targetSize.width = maxSize.width;
        }
        targetSize.height = imageSize.height*targetSize.width/imageSize.width;
    }
    else {
        if (targetSize.height > maxSize.height) {
            targetSize.height = maxSize.height;
        }
        targetSize.width = imageSize.width*targetSize.height/imageSize.height;
    }
    
    if(UIImageOrientationLeft == self.imageOrientation)
    {
        UIImageView *v = [[UIImageView alloc] initWithImage:self];
        v.frame = CGRectMake(0, 0, targetSize.width, targetSize.height);
        v.transform = CGAffineTransformMakeRotation(M_1_PI/2);
        
        CGSize  r = CGSizeMake(targetSize.width, targetSize.height);
        CGRect rect = CGRectMake(0, 0, r.width, r.height);
        UIGraphicsBeginImageContext(r);
        [self drawInRect:rect];
        UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newimage;
    }

    else if(UIImageOrientationRight == self.imageOrientation)
    {
  
        UIImageView *v = [[UIImageView alloc] initWithImage:self];
        v.frame = CGRectMake(0, 0, targetSize.width, targetSize.height);
        v.transform = CGAffineTransformMakeRotation(-M_1_PI/2);
        
        CGSize  r = CGSizeMake(targetSize.width, targetSize.height);
        CGRect rect = CGRectMake(0, 0, r.width, r.height);
        UIGraphicsBeginImageContext(r);
        [self drawInRect:rect];
        UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newimage;
    }
    else if(UIImageOrientationDown == self.imageOrientation)
    {
        
        CGRect rect = CGRectMake(0, 0, targetSize.width, targetSize.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, rect, self.CGImage);
        UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newimage;
    }
    else if (UIImageOrientationUp == self.imageOrientation)
    {
        UIImageView *v = [[UIImageView alloc] initWithImage:self];
        v.frame = CGRectMake(0, 0, targetSize.width, targetSize.height);
        v.transform = CGAffineTransformMakeRotation(M_1_PI);
        
        CGSize  r = CGSizeMake(targetSize.width, targetSize.height);
        CGRect rect = CGRectMake(0, 0, r.width, r.height);
        UIGraphicsBeginImageContext(r);
        [self drawInRect:rect];
        UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newimage;
    }
  return nil;
}




//方法说明：根据提供的位置和范围，将屏幕图像生成为UIImage并放回
//参数1 aView : 待剪切的原始UIView
//参数2 rect  : 剪切范围
+ (UIImage *) cropImageFrom:(UIView *)view inRect:(CGRect)rect {
    CGPoint pt = rect.origin;
    UIImage *resutImg;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context,
                       CGAffineTransformMakeTranslation(-(int)pt.x, -(int)pt.y));
    [view.layer renderInContext:context];
    resutImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resutImg;
}

// 把图片按相框比例 缩放后 放在相框中的frame
+(CGRect)getCropFrame:(CGRect)f withImgSize:(CGSize)imgSize
{
    // image h/w
    CGFloat ki = imgSize.height/imgSize.width;
    // screen h/w
    CGFloat ks = f.size.height/f.size.width;
    CGRect resultRect;
    
    if (ki > ks)
    {
        resultRect.size.height = f.size.height;
        resultRect.size.width = f.size.height/ki;
        resultRect.origin.x = (f.size.width - resultRect.size.width)/2;
        resultRect.origin.y = 0;
    }
    else
    {
        resultRect.size.height = f.size.width*ki;
        resultRect.size.width = f.size.width;
        resultRect.origin.x = 0;
        resultRect.origin.y = (f.size.height - resultRect.size.height)/2;
    }
    
    return resultRect;
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


+ (UIImage *)blurryImage:(UIImage *)image
           withBlurLevel:(CGFloat)blur {
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur),
                        nil];
    
    CIImage *outputImage = filter.outputImage;
    return [UIImage imageWithCIImage:outputImage];
}

- (UIImage*)antialiasedImage
{
    CGSize size = CGSizeMake(self.size.width + 2, self.size.height + 2);
    CGFloat scale = self.scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [self drawInRect:CGRectMake(1, 1, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)antialiasedImageClipWithSize:(CGSize)size
{
     float imageWidth = self.size.width;
     float imageHeight = self.size.height;
     float widthScale = imageWidth /size.width;
     float heightScale = imageHeight /size.height;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    if (widthScale > heightScale)
    {
        [self drawInRect:CGRectMake(1, 1, imageWidth/heightScale-2, size.height-2)];
    }
    else
    {
        [self drawInRect:CGRectMake(1, 1, size.width -2, imageHeight /widthScale -2)];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *) addWaterMark:(UIImage *)markImage inRect:(CGRect)rect {
    // do some check
    if (rect.origin.x + rect.size.width > self.size.width || rect.origin.y + rect.size.height > self.size.height) {
        return nil;
    }    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [markImage drawInRect:rect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}


@end
