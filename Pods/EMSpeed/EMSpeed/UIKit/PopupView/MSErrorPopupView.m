//
//  EMErrorView.m
//  EMStock
//
//  Created by Samuel on 15/3/24.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import "MSErrorPopupView.h"

@interface MSErrorPopupView()

@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgvAlert;
@property (weak, nonatomic) IBOutlet UIImageView *imgvArrow;

@end

@implementation MSErrorPopupView

- (IBAction)doClick:(id)sender
{
    if (self.block) {
        self.block(self);
    }
}

+ (instancetype)errorPopupWithText:(NSString *)text
{
    return [MSErrorPopupView errorPopupWithText:text block:nil];
}


+ (instancetype)errorPopupWithText:(NSString *)text
                               block:(ms_popupview_event_block_t)block
{
    static MSErrorPopupView *popupView = nil;
    
    if (popupView == nil) {
        popupView = [[[NSBundle mainBundle] loadNibNamed:@"MSErrorPopupView" owner:self options:nil] lastObject];
        popupView.isAutoDismiss = YES;
        popupView.autoDismissDelaySeconds = 3.f;
    }
    
    popupView.errorMessageLabel.text = text;
    popupView.block = block;
    
    return popupView;
}

- (void)show
{
    [super show];
}

- (void)dismiss
{
    [super dismiss];
}

@end






