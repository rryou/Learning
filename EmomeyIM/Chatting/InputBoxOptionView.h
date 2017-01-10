//
//  InputBoxOptionView.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 7/1/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kInputBoxOption_None                = 0,
    kInputBoxOption_Voice               = 1,
    kInputBoxOption_PickPhoto           = 1 << 1,
    kInputBoxOption_TakePhoto           = 1 << 2,
    kInputBoxOption_PickVideo           = 1 << 3,
    kInputBoxOption_TakeVideo           = 1 << 4,
    kInputBoxOption_Music               = 1 << 5,
    kInputBoxOption_Mask_OnOptionBoard  = 0x0000ffff,
    
    kInputBoxOption_Amuse               = 1 << 16,       // 逗逗ta
    
    kInputBoxOption_Default             = kInputBoxOption_Voice | kInputBoxOption_PickPhoto | kInputBoxOption_TakePhoto | kInputBoxOption_Amuse,
    
    kInputBoxOption_Group               = kInputBoxOption_Voice | kInputBoxOption_PickPhoto | kInputBoxOption_TakePhoto
                                        | kInputBoxOption_PickVideo | kInputBoxOption_TakeVideo | kInputBoxOption_Music,
    
    kInputBoxOption_AnonymousChat       = kInputBoxOption_Voice | kInputBoxOption_PickPhoto | kInputBoxOption_TakePhoto | kInputBoxOption_PickVideo | kInputBoxOption_TakeVideo | kInputBoxOption_Music | kInputBoxOption_Amuse,

    kInputBoxOption_All                 = kInputBoxOption_Group,
    
} InputBoxOption;

@protocol InputBoxOptionDelegate <NSObject>

- (void)didSelectInputBoxOption:(InputBoxOption)option;

@end

@interface InputBoxOptionView : UIImageView <UIScrollViewDelegate>

@property (nonatomic, assign) id<InputBoxOptionDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame options:(InputBoxOption)options;

- (void)updateCount:(NSInteger)count option:(InputBoxOption)option;

- (void)showNewTip:(BOOL)show option:(InputBoxOption)option;

- (void)reset;

+ (CGFloat)viewHeight;

@end
