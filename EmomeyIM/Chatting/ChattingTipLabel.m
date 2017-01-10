//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "ChattingTipLabel.h"
#import <EMSpeed/MSUIKitCore.h>
@implementation ChattingTipLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = RGB(252, 252, 252);
        self.backgroundColor = RGB(195, 195, 195);
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3;
        self.font = [UIFont systemFontOfSize:14];
        self.numberOfLines = 0;
//        self.textEdgeInsets = UIEdgeInsetsMake(4, 10, 4, 10);
    }
    return self;
}

- (void)prepareForReuse {
    
}

+ (CGSize)viewSizeWithText:(NSString *)text maxWidth:(CGFloat)maxWidth {
    UIEdgeInsets ei = UIEdgeInsetsMake(4, 10, 4, 10);
    CGSize size=[text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    size.width += ei.left + ei.right;
    size.height += ei.top + ei.bottom;
    return size;
}

@end
