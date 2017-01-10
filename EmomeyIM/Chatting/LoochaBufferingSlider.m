//
//  LoochaBufferingSlider.m
//  LoochaCampus
//
//  Created by zhang jinquan on 13-2-21.
//
//

#import "LoochaBufferingSlider.h"
//#import "UIView+Loocha.h"

#define kMarginX 5
#define kThumbWidth 20

@implementation LoochaBufferingSlider

@synthesize value;
@synthesize maximumValue;
@synthesize bufferedValue;
@synthesize sliderLineWidth;
@synthesize beforeColor;
@synthesize bufferedColor;
@synthesize unbufferedColor;
@synthesize delegate;
@synthesize marginX;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        self.ignoreGlobalPanGesture = YES;
        self.enabled = YES;
        currentThumbView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        currentThumbView.image = [UIImage imageNamed:@"common_music_btn_pointer"];

        currentThumbView.backgroundColor = [UIColor clearColor];
        currentThumbView.userInteractionEnabled = NO;
        [self addSubview:currentThumbView];
        self.maximumValue = 1.0;
        self.value = 0;
        self.marginX = kMarginX;
        self.sliderLineWidth = kDefaultSliderLineWidth;
//        self.beforeColor = kDefaultBeforeColor;
//        self.bufferedColor = kDefaultBufferedColor;
//        self.unbufferedColor = kDefaultUnbufferedColor;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    currentThumbView.center = CGPointMake(currentThumbView.center.x, CGRectGetMidY(self.bounds));
    [self update];
}

- (void)setSliderLineWidth:(float)aSliderLineWidth
{
    sliderLineWidth = aSliderLineWidth;
    [self setNeedsLayout];
}

- (void)setCurrentThumbImage:(UIImage *)aCurrentThumbImage
{
    currentThumbView.image = aCurrentThumbImage;
}

- (UIImage *)currentThumbImage
{
    return currentThumbView.image;
}

- (void)setValue:(float)aValue
{
    if (aValue < 0) {
        aValue = 0;
    }
    else if (aValue > maximumValue) {
        aValue = maximumValue;
    }
    value = aValue;
    [self update];
}

- (void)setBufferedValue:(float)aBufferedValue
{
    bufferedValue = aBufferedValue;
    [self setNeedsDisplay];
}

- (float)currentWidth
{
    if (maximumValue > 0) {
        return value*(self.bounds.size.width - marginX - marginX)/maximumValue;
    }
    return 0;
}

- (float)bufferedWidth
{
    if (maximumValue > 0) {
        return bufferedValue*(self.bounds.size.width - marginX - marginX)/maximumValue;
    }
    return 0;
}

- (void)drawRect:(CGRect)rect
{
    CGRect r = self.bounds;
    CGRect lineRect;
    lineRect.origin.x = marginX;
    lineRect.origin.y = (r.size.height - sliderLineWidth)/2;
    lineRect.size.width = r.size.width - marginX - marginX;
    lineRect.size.height = sliderLineWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    CGContextSaveGState(context);
//    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
//    CGContextSetLineWidth(context, 0.5);
//    CGContextStrokeRect(context, lineRect);
//    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
//    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [self.unbufferedColor setFill];
    CGContextFillRect(context, lineRect);
    lineRect.size.width = [self bufferedWidth];
    [self.bufferedColor setFill];
    CGContextFillRect(context, lineRect);
    lineRect.size.width = [self currentWidth];
    [self.beforeColor setFill];
    CGContextFillRect(context, lineRect);
    CGContextRestoreGState(context);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    CGRect r = CGRectInset(currentThumbView.frame, -10, -10);
    if (CGRectContainsPoint(r, loc)) {
        tracking = YES;
        startDelt = currentThumbView.center.x - loc.x;
        [delegate actionBeginChangingProgress];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (tracking) {
        [self handleTouches:touches];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (tracking) {
        tracking = NO;
        [delegate actionEndChangingProgress];
    }
    else {
        // 禁用掉随机定位
//        [self handleTouches:touches];
    }
}

- (void)moveToPositionX:(CGFloat)x
{
    currentThumbView.center = CGPointMake(x, CGRectGetMidY(self.bounds));
    if (tracking) {
        CGFloat width = (self.bounds.size.width-marginX-marginX);
        if (width == 0) {
            return;
        }
        float aValue = maximumValue*(x-marginX)/width;
        if (aValue < 0) {
            aValue = 0;
        }
        else if (aValue > maximumValue) {
            aValue = maximumValue;
        }
        self.value = aValue;
        [delegate actionChangeProgress];
    }
}

- (void)handleTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    CGFloat cur = startDelt + loc.x;
    if (cur < marginX) {
        cur = marginX;
    }
    else if (cur > marginX + [self bufferedWidth]) {
        cur = marginX + [self bufferedWidth] - 0.1;
    }
    [self moveToPositionX:cur];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    tracking = NO;
    [delegate actionEndChangingProgress];
}

- (void)update
{
    if (!tracking) {
        float x = marginX;
        if (maximumValue > 0) {
            x += value*(self.bounds.size.width - marginX - marginX)/maximumValue;
        }
        [self moveToPositionX:x];
        [self setNeedsDisplay];
    }
}

@end
