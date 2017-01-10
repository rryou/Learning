//
//  ChattingInputBoxController.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 2/12/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import "ChattingInputBoxController.h"

@interface ChattingInputBoxController ()

@end

@implementation ChattingInputBoxController

- (instancetype)initWithParent:(UIViewController *)parent beginState:(InputBoxBeginState)beginState capabilities:(InputBoxCapability)capabilities {
    self = [super initWithParent:parent beginState:beginState capabilities:capabilities];
    if (self) {
        self.maxPhotoCount = 1;
        self.maxVideoCount = 1;
        self.sendSeparatedly = YES;
    }
    return self;
}

- (instancetype)initWithParent:(UIViewController *)parent options:(InputBoxOption)options {
    InputBoxCapability capbilities = InputBoxCapability(InputBoxCapability_Text | InputBoxCapability_Emoji);
    if (options != kInputBoxOption_None) {
        capbilities = (InputBoxCapability)(capbilities |InputBoxCapability_Attachment);
    }
    return [self initWithParent:parent beginState:InputBoxBeginState_DisplayToolbar capabilities:capbilities];
}

- (instancetype)initWithParent:(UIViewController *)parent {
    return [self initWithParent:parent options:kInputBoxOption_Default];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
