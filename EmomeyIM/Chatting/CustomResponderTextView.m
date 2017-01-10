//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "CustomResponderTextView.h"
#import <PureLayout.h>
#import <EMSpeed/MSUIKitCore.h>
@interface CustomResponderTextView(){
    
}
@property (nonatomic, strong)    CALayer *bottomBorder;

@end
@implementation CustomResponderTextView
@synthesize overrideNextReponser;
- (UIResponder *)nextResponder{
    if (overrideNextReponser!=nil) {
        return overrideNextReponser;
    }else{
        return [super nextResponder];
    }
}

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    if (self.bottomBorder) {
//        _bottomBorder.frame = CGRectMake(0.0f, self.size.height -1, self.size.width, 1.0f);
//    }
//    if (self.bottomline) {
//       [self.bottomline setFrame:CGRectMake(1, self.size.height - 2, self.size.width - 2, 2)];   
//    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (overrideNextReponser!=nil) {
        return NO;
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}
@end
