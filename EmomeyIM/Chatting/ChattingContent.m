//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "ChattingContent.h"

@implementation ChattingContent

- (NSArray *)attachments {
    if ([_data isKindOfClass:[NSArray class]]) {
        return _data;
    }
    return nil;
}

- (NSArray *)emoArray {
    if ([_data isKindOfClass:[NSArray class]]) {
        return _data;
    }
    return nil;
}

- (BOOL)supportDelete {
    return YES;
}

- (BOOL)supportForward{
     return YES;
}

- (BOOL)supportCopyText {
    if (self.contentType == ChattingContent_Text ||self.contentType ==ChattingContent_SpecialEmo) {
        return YES;
    }else{
        return NO;
    }
    return NO;
}
@end
