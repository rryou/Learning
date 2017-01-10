//
//  EMSocketextend.h
//  EmomeyIM
//
//  Created by yourongrong on 2016/10/31.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EMSocketextend;
@protocol EMSocketextendDelegate <NSObject>
@required //必须实现的方法
-(void)receviedSocket:(EMSocketextend *)socket receivedata:(NSData *)sockData;
@end

@interface EMSocketextend : NSObject
- (id)initWithDelegateQueue:(dispatch_queue_t )delequeue;
- (void)reconnecthost;
- (void)startHeartConnect;
- (void)heartConnect;
- (void)stopHeartconnect;
-(BOOL)isConnected;
- (void)sendSockData:(NSData *)data sender:(id<EMSocketextendDelegate>) senderObject dwDataID:(NSInteger)m_dwDataID;
//tag为socktet 头部中的id
@end
