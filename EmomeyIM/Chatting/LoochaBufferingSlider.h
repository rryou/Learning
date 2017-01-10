//
//  LoochaBufferingSlider.h
//  LoochaCampus
//
//  Created by zhang jinquan on 13-2-21.
//
//

#import <UIKit/UIKit.h>

#define kDefaultSliderLineWidth 3
#define kDefaultBeforeColor     RCColorWithRGB(170, 215, 226)
#define kDefaultBufferedColor   RCColorWithRGB(211, 217, 211)
#define kDefaultUnbufferedColor RCColorWithRGB(240, 240, 240)

@protocol LoochaBufferingSliderDelegate <NSObject>

- (void)actionBeginChangingProgress;

- (void)actionChangeProgress;

- (void)actionEndChangingProgress;

@end

@interface LoochaBufferingSlider : UIControl
{
    UIImageView *currentThumbView;
    BOOL tracking;
    CGFloat startDelt;
}

@property (nonatomic) float value;          // default value 0.0
@property (nonatomic) float maximumValue;   // default value 1.0
@property (nonatomic) float bufferedValue;  // default value 0.0
@property (nonatomic) float marginX;
@property (nonatomic) float sliderLineWidth;
@property (nonatomic, retain) UIColor *beforeColor;
@property (nonatomic, retain) UIColor *bufferedColor;
@property (nonatomic, retain) UIColor *unbufferedColor;
@property (nonatomic, retain) UIImage *currentThumbImage;

@property (nonatomic, assign) id<LoochaBufferingSliderDelegate> delegate;

- (void)update;

@end
