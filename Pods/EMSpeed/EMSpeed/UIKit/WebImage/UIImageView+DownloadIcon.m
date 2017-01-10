//
//  UIImageView+emDownloadIcon.m
//  EMSpeed
//
//  Created by flora on 14-10-12.
//  Copyright (c) 2014年 flora. All rights reserved.
//

#import "UIImageView+DownloadIcon.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <objc/runtime.h>

static NSInteger kUIImageViewActivityIndicatorTag = 888888;

static char UIImageViewPreContentMode;

@implementation UIImageView (DownloadIcon)

- (NSInteger)preContentMode
{
    NSNumber *number = objc_getAssociatedObject(self, &UIImageViewPreContentMode);
    if (number)
    {
        return [number integerValue];
    }
    else
    {
        return self.contentMode;
    }
}

- (void)setPreContentMode:(UIViewContentMode)mode
{
    objc_setAssociatedObject(self, &UIImageViewPreContentMode, [NSNumber numberWithInteger:mode], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)ms_setIconWithUrlString:(NSString *)icon placeHolderImage:(UIImage *)placeHolder
{
    UIImage *localImage = [UIImage imageNamed:icon];
    if (localImage)
    {
        self.image = localImage;
    }
    else
    {
        [self sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:placeHolder];
    }
}


- (void)ms_setIconWithUrlString:(NSString *)icon
{
    [self ms_setIconWithUrlString:icon placeHolderImage:nil];
    
}

- (void)ms_setImageWithURLString:(NSString *)urlstring
{
    self.contentMode = [self preContentMode];
    UIImage *localImage = [UIImage imageNamed:urlstring];
    if (localImage)
    {
        self.image = localImage;
    }
    else
    {
        [self setPreContentMode:self.contentMode];
        self.contentMode = UIViewContentModeCenter;
        __weak UIImageView *imageView = self;
        
        // ActivityIndicator
        UIActivityIndicatorView *indView = (UIActivityIndicatorView *)[self viewWithTag:kUIImageViewActivityIndicatorTag];
        if (indView==nil) {
            indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indView.tag = kUIImageViewActivityIndicatorTag;
        }
        [self addSubview:indView];
        indView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [indView startAnimating];
        
        [self sd_setImageWithURL:[NSURL URLWithString:urlstring]
                placeholderImage:nil
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                           if (image)
                           {
                               imageView.contentMode = [self preContentMode];
                               imageView.image = image;
                           }
                           
                           [indView stopAnimating];
                           indView.hidden = YES;
                       }];
    }
}

- (void)ms_setImageWithURL:(NSURL *)url localCache:(BOOL)localCache
{
    [self ms_setImageWithURL:url localCache:localCache placeholderImage:nil options:SDWebImageRetryFailed];
}


- (void)ms_setImageWithURL:(NSURL *)url localCache:(BOOL)localCache placeholderImage:(UIImage *)placeholderImage
{
    [self ms_setImageWithURL:url localCache:localCache placeholderImage:placeholderImage options:SDWebImageRetryFailed];
}

- (void)ms_setImageWithURL:(NSURL *)url localCache:(BOOL)localCache placeholderImage:(UIImage *)placeholderImage options:(SDWebImageOptions)options
{
    self.contentMode = [self preContentMode];
    [self setPreContentMode:self.contentMode];
    if (placeholderImage)
    {//显示底图时采用居中的方式
        self.contentMode = UIViewContentModeCenter;
    }
    __weak UIImageView *imageView = self;
    
    // ActivityIndicator
    UIActivityIndicatorView *indView = (UIActivityIndicatorView *)[self viewWithTag:kUIImageViewActivityIndicatorTag];
    if (indView==nil) {
        indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indView.tag = kUIImageViewActivityIndicatorTag;
    }
    [self addSubview:indView];
    [indView startAnimating];
    indView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self sd_setImageWithURL:url placeholderImage:placeholderImage options:options progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
        {
            imageView.contentMode = [self preContentMode];
            imageView.image = image;
        }
        [indView stopAnimating];
        indView.hidden = YES;
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIActivityIndicatorView *indView = (UIActivityIndicatorView *)[self viewWithTag:kUIImageViewActivityIndicatorTag];
    if (indView)
    {
        indView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

- (void)ms_setIconWithIcon:(NSString*)icon urlString:(NSString *)urlString placeHolderImage:(UIImage *)placeHolder
{
    UIImage *localImage = [UIImage imageNamed:icon];
    if (localImage)
    {
        self.image = localImage;
    }
    else
    {
        [self sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeHolder];
    }
}

- (void)ms_setIconWithEmptyIcon:(NSString*)icon urlString:(NSString *)urlString placeHolderImage:(UIImage *)placeHolder
{
    if ([icon length] > 0)
    {
        self.image = [UIImage imageNamed:icon];
    }
    else
    {
        [self sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeHolder];
    }
}

@end



