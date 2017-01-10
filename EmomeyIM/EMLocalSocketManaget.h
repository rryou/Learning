//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSocketextend.h"

@interface EMLocalSocketManaget : NSObject
+(EMLocalSocketManaget*)sharedSocketManaget;
- (BOOL)socketPostMessage:(NSData *)data sendobject:(id<EMSocketextendDelegate>)senderObject;
- (NSInteger )getNewIndex;
- (void)startHeartconnect;
- (void)startbackGroupHear;
- (void)resetAllSocket;
- (BOOL)sockConnectAvailble;
@end
