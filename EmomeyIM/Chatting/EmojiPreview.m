//
//  EmojiPreview.m
//  LoochaCampusMain
//
//  Created by ding xiuwei on 15/6/24.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//

#import "EmojiPreview.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
//#import "EmojiDao.h"
//#import "EmojisExtension.h"
@interface EmojiPreview ()
{
    UIImageView *_imageView;
}

@end

@implementation EmojiPreview

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 50)];
        [self addSubview:_imageView];
        _imageView.backgroundColor = [UIColor clearColor];
        _arowHight = 8;
        _backGroudAlpha = 0.55;
        _arowOffsetX = 0;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect{

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAlpha(context, _backGroudAlpha);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGRect rrect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - _arowHight);
    CGFloat radius = 7.0;
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGContextMoveToPoint(context, minx, midy);//
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddLineToPoint(context, midx + _arowHight + _arowOffsetX, maxy);
    CGContextAddLineToPoint(context, midx + _arowOffsetX, maxy + _arowHight);
    CGContextAddLineToPoint(context, midx - _arowHight + _arowOffsetX, maxy);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    
    CGContextClosePath(context);
    //    // Fill & stroke the path
    CGContextDrawPath(context, kCGPathFillStroke);
}

-(void)setFrame:(CGRect)frame
{
    CGRect rect = frame;
    if (isnan(rect.origin.x) || isnan(rect.origin.y) || isnan(rect.size.width) || isnan(rect.size.height) || CGRectIsNull(rect) ) {
        return;
    }
    [super setFrame:frame];
    
    _imageView.frame = CGRectMake((frame.size.width - _imageView.frame.size.width)/2, (frame.size.height - _imageView.frame.size.height)/2 - _arowHight, _imageView.frame.size.width, _imageView.frame.size.height);
    
    [self setNeedsDisplay];
}
-(void)loadData:(DMEmo*)emo
{
    if (emo.type == LocalEmoTypeNormal)
    {
        _imageView.image = [UIImage imageNamed:emo.name];
    }
}
@end
