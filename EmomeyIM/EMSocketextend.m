//
//  EMSocketextend.m
//  EmomeyIM
//
//  Created by yourongrong on 2016/10/31.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "EMSocketextend.h"
#import <GCDAsyncSocket.h>
#import "CommDataModel.h"
@interface EMSocketextend()<GCDAsyncSocketDelegate>{
}
@property (nonatomic, strong) GCDAsyncSocket *localsocket;
@property (nonatomic, strong) NSTimer *hearttimer;
@property (nonatomic, strong) dispatch_queue_t localsocketQueue;
@property (nonatomic, strong) NSMutableDictionary <NSString *, id<EMSocketextendDelegate> > *objcetdict;
@property (atomic, assign) NSInteger indexNumber;
@property (nonatomic, assign) long heartNumber;
@property (nonatomic, strong) NSMutableData *receiveDataBuffer;
@end

@implementation EMSocketextend:NSObject
- (id)initWithDelegateQueue:(dispatch_queue_t )delequeue{
    self = [super init];
    if(self){
        self.localsocketQueue = delequeue;
        self.localsocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.localsocketQueue];
        self.objcetdict = [NSMutableDictionary dictionary];
    }
    return self;
}

-(BOOL)isConnected {
    return self.localsocket.isConnected;
}

- (void)reconnecthost{
    NSError *error = nil;
    [self.localsocket connectToHost:SOCKETADDRESS onPort:SOCKETPORT withTimeout:-1 error:&error];
    if(error){
        [self.localsocket disconnect];
        self.localsocket.delegate = nil;
        NSLog(@"socket connect failed");
    }else{
        
    }
    self.receiveDataBuffer = [[NSMutableData alloc] init];
}

- (void)stopHeartconnect{
    [self.hearttimer fire];
}

- (void)startHeartConnect{
    if (self.hearttimer) {
        [self.hearttimer invalidate];
    }
    self.hearttimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(heartConnect) userInfo:nil repeats:YES];
    [self heartConnect];
    [[NSRunLoop currentRunLoop] addTimer:self.hearttimer forMode:NSDefaultRunLoopMode];
}

- (void)heartConnect{
    CCheckData* pDataCheck = [[CCheckData alloc] init];
    if (pDataCheck){
        pDataCheck.m_wStatus = WantAll;
        [pDataCheck sendSockPost];
    }
}

- (void)sendSockData:(NSData *)data sender:(id<EMSocketextendDelegate>) senderObject dwDataID:(NSInteger)m_dwDataID;{
    if (data && senderObject) {
        @synchronized (self.objcetdict) {
            [self.localsocket writeData:data withTimeout: -1 tag:m_dwDataID];
            [self.localsocket readDataWithTimeout:-1 tag:m_dwDataID];
            [self.objcetdict setObject:senderObject forKey:[self createdicKeyValue:m_dwDataID]];
        }
    }
}

- (void) socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    if (sock) {
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
      [self.localsocket readDataWithTimeout:-1 tag:tag];
}

- (NSString *)createdicKeyValue:(NSInteger )indexNumber{
    return [NSString stringWithFormat:@"localsockID%ld",(long)indexNumber];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if (data.length == 0) {
        return;
    }
    @synchronized (self) {
        [_receiveDataBuffer appendData:data];
        BOOL hasCompletionMess = YES;
        while (hasCompletionMess) {
            NSInteger templegth = [_receiveDataBuffer length];
            if(templegth > 16){
                Byte *answerbyte = (Byte *)[_receiveDataBuffer bytes];
                CDataHead *tempHead = new CDataHead;
                tempHead->Recv((char *)answerbyte);
                NSInteger bodyLength = tempHead->m_dwDataLength;
                NSData *handledata;
                if(templegth >= bodyLength +16){
                    handledata = [[NSData alloc] initWithBytes:answerbyte length:bodyLength + 16];
                    NSString *keyStr = [self createdicKeyValue: tempHead->m_dwDataID];
                    [self handeleSocketMessage:handledata objectKey:keyStr];
                    if(templegth - bodyLength > 16 ){
                        _receiveDataBuffer = [[NSMutableData alloc] initWithBytes:answerbyte + bodyLength + 16  length:templegth - bodyLength - 16];
                    }else{
                        _receiveDataBuffer = [[NSMutableData alloc] init];
                    }
                }else{
                    hasCompletionMess = NO;
                     [self.localsocket readDataWithTimeout:-1 tag:tag];
                }
            }else{
                hasCompletionMess = NO;
            }
        }
    }
}

- (void)handeleSocketMessage:(NSData *)messageData objectKey:(NSString *)objectKey{
    if (objectKey) {
        id<EMSocketextendDelegate > objcetdict = [self.objcetdict objectForKey:objectKey];
        if (objcetdict) {
            if ([objcetdict respondsToSelector:@selector(receviedSocket:receivedata:)]) {
                [objcetdict receviedSocket:self receivedata:messageData];
            }
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    if (sock) {
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (sock) {
        NSLog(@"sock down");
    }
}

@end
