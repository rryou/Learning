//
//  LCCircleProgressView.m
//  LoochaCampusMain
//
//  Created by ChenHao on 15/5/29.
//  Copyright (c) 2015年 Real Cloud. All rights reserved.
//

#import "LCCircleProgressView.h"


@interface LCCircleProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *trackLayer;

@end

@implementation LCCircleProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineWidth = 2.;
        _progress = 0.;
        
        self.progressTintColor = [UIColor blackColor];
    }
    
    return self;
}

- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        CGFloat lineWidth = self.lineWidth;
        CGFloat radius = CGRectGetWidth(self.bounds)/2 - lineWidth/2;
        
        _progressLayer = [CAShapeLayer layer];
        CGRect rect = CGRectMake(lineWidth/2, lineWidth/2, radius * 2, radius * 2);
        _progressLayer.path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath;
        
        _progressLayer.strokeColor = [UIColor blackColor].CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = lineWidth;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineJoin = kCALineJoinRound;
        _progressLayer.strokeEnd = 0.01;
        
        [self.layer addSublayer:_progressLayer];
    }
    
    return _progressLayer;
}


- (CAShapeLayer *)trackLayer
{
    if (!_trackLayer) {
        CGFloat lineWidth = self.lineWidth;
        CGFloat radius = CGRectGetWidth(self.bounds)/2 - lineWidth/2;
        
        _trackLayer = [CAShapeLayer layer];
        CGRect rect = CGRectMake(lineWidth/2, lineWidth/2, radius * 2, radius * 2);
        _trackLayer.path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath;
        
        _trackLayer.strokeColor = [UIColor grayColor].CGColor;
        _trackLayer.fillColor = nil;
        _trackLayer.lineWidth = lineWidth;
        _trackLayer.lineCap = kCALineCapRound;
        _trackLayer.lineJoin = kCALineJoinRound;
        
        [self.layer insertSublayer:_trackLayer below:self.progressLayer];
    }
    
    return _trackLayer;
}


#pragma mark - Setter
- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    _trackTintColor = trackTintColor;
    self.trackLayer.strokeColor = _trackTintColor.CGColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    _progressTintColor = progressTintColor;
    self.progressLayer.strokeColor = _progressTintColor.CGColor;
}

- (void)setProgress:(float)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    if (_progress == progress) {
        return;
    } else if (progress < 0.) {
        progress = 0.;
    } else if (progress > 1.) {
        progress = 1.;
    }
    
    _progress = progress;
    
    if (animated) {
        self.progressLayer.strokeEnd = progress;
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [CATransaction setAnimationDuration:0.];
        self.progressLayer.strokeEnd = progress;
        [CATransaction commit];
    }
}

@end
