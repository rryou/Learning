//
//  UIImage+capture.m
//  EMSpeed
//
//  Created by flora deng on 3/13/12.
//  Copyright (c) 2012 Emoney.cn. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage(Utility)

- (UIImage *)ms_clipWithRect:(CGRect)rect
{
    rect.size.height = rect.size.height * [self scale];
    rect.size.width = rect.size.width * [self scale];
    rect.origin.x = rect.origin.x * [self scale];
    rect.origin.y = rect.origin.y * [self scale];

    CGImageRef imageRef = self.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(subImageRef);
    
    return smallImage;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees 
{   
    CGSize rotatedSize = [UIScreen mainScreen].bounds.size;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

//CGImageRef UIGetScreenImage();
/**横屏的时候直接截screen；竖屏由于更多中有一个分享，所以取thedelegate视图
 */
+(UIImage *)ms_captureScreen:(CGFloat)resolution
{
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    UIView *view = window;
    
    // 真机上分享到腾讯微博图片变小(新浪好的)，写2.0或0.0都不行。估计是腾讯api问题。先改成1.0吧
    CGSize size = CGSizeMake(window.screen.bounds.size.width, window.screen.bounds.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, resolution);
    CGContextRef c =  UIGraphicsGetCurrentContext();
    [view.layer renderInContext:c];
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [aImage ms_clipWithRect:CGRectMake(0, 20, aImage.size.width, aImage.size.height-20)];
}


+ (UIImage *)ms_imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}




- (UIImage *)ms_resizedImageByMagick:(NSString *)spec
{
    
    if([spec hasSuffix:@"!"]) {
        NSString *specWithoutSuffix = [spec substringToIndex: [spec length] - 1];
        NSArray *widthAndHeight = [specWithoutSuffix componentsSeparatedByString: @"x"];
        NSUInteger width = [[widthAndHeight objectAtIndex: 0] integerValue];
        NSUInteger height = [[widthAndHeight objectAtIndex: 1] integerValue];
        UIImage *newImage = [self ms_resizedImageWithMinimumSize: CGSizeMake (width, height)];
        return [newImage ms_drawImageInBounds: CGRectMake (0, 0, width, height)];
    }
    
    if([spec hasSuffix:@"#"]) {
        NSString *specWithoutSuffix = [spec substringToIndex: [spec length] - 1];
        NSArray *widthAndHeight = [specWithoutSuffix componentsSeparatedByString: @"x"];
        NSUInteger width = [[widthAndHeight objectAtIndex: 0] integerValue];
        NSUInteger height = [[widthAndHeight objectAtIndex: 1] integerValue];
        UIImage *newImage = [self ms_resizedImageWithMinimumSize: CGSizeMake (width, height)];
        return [newImage ms_croppedImageWithRect: CGRectMake ((newImage.size.width - width) / 2, (newImage.size.height - height) / 2, width, height)];
    }
    
    if([spec hasSuffix:@"^"]) {
        NSString *specWithoutSuffix = [spec substringToIndex: [spec length] - 1];
        NSArray *widthAndHeight = [specWithoutSuffix componentsSeparatedByString: @"x"];
        return [self ms_resizedImageWithMinimumSize: CGSizeMake ([[widthAndHeight objectAtIndex: 0] longLongValue],
                                                              [[widthAndHeight objectAtIndex: 1] longLongValue])];
    }
    
    NSArray *widthAndHeight = [spec componentsSeparatedByString: @"x"];
    if ([widthAndHeight count] == 1) {
        return [self ms_resizedImageByWidth: [spec integerValue]];
    }
    if ([[widthAndHeight objectAtIndex: 0] isEqualToString: @""]) {
        return [self ms_resizedImageByHeight: [[widthAndHeight objectAtIndex: 1] integerValue]];
    }
    return [self ms_resizedImageWithMaximumSize: CGSizeMake ([[widthAndHeight objectAtIndex: 0] longLongValue],
                                                          [[widthAndHeight objectAtIndex: 1] longLongValue])];
}

- (CGImageRef)newCGImageWithCorrectOrientation
{
    if (self.imageOrientation == UIImageOrientationDown) {
        //retaining because caller expects to own the reference
        return CGImageRetain([self CGImage]);
    }
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, 90 * M_PI/180);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, -90 * M_PI/180);
    } else if (self.imageOrientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, 180 * M_PI/180);
    }
    
    [self drawAtPoint:CGPointMake(0, 0)];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    return cgImage;
}


- (UIImage *)ms_resizedImageByWidth:(NSUInteger)width
{
    CGImageRef imgRef = [self newCGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat ratio = width/original_width;
    CGImageRelease(imgRef);
    return [self ms_drawImageInBounds: CGRectMake(0, 0, width, round(original_height * ratio))];
}

- (UIImage *)ms_resizedImageByHeight:(NSUInteger)height
{
    CGImageRef imgRef = [self newCGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat ratio = height/original_height;
    CGImageRelease(imgRef);
    return [self ms_drawImageInBounds: CGRectMake(0, 0, round(original_width * ratio), height)];
}

- (UIImage *)ms_resizedImageWithMinimumSize:(CGSize)size
{
    CGImageRef imgRef = [self newCGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio > height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self ms_drawImageInBounds: CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio))];
}

- (UIImage *)ms_resizedImageWithMaximumSize:(CGSize)size
{
    CGImageRef imgRef = [self newCGImageWithCorrectOrientation];
    CGFloat original_width  = CGImageGetWidth(imgRef);
    CGFloat original_height = CGImageGetHeight(imgRef);
    CGFloat width_ratio = size.width / original_width;
    CGFloat height_ratio = size.height / original_height;
    CGFloat scale_ratio = width_ratio < height_ratio ? width_ratio : height_ratio;
    CGImageRelease(imgRef);
    return [self ms_drawImageInBounds: CGRectMake(0, 0, round(original_width * scale_ratio), round(original_height * scale_ratio))];
}

- (UIImage *)ms_drawImageInBounds:(CGRect)bounds
{
    //UIGraphicsBeginImageContext(bounds.size);
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
    [self drawInRect: bounds];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage*)ms_croppedImageWithRect:(CGRect)rect{
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height);
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [self drawInRect:drawRect];
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return subImage;
}

@end
