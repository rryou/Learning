//
//  EMLocalSocketManaget.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//
#import "EMLocalSocketManaget.h"
#import <GCDAsyncSocket.h>
#import "Buffer.h"
#import <libkern/OSAtomic.h>
#include "Compress.h"
#import "CommDataModel.h"
#import "MyDefine.h"
#define  _DATAHEDALENGTH 16
typedef NS_ENUM(NSInteger, SockConnectType){
  SockConnectType_send = 1,
  SockConnectType_download = 2,
  SockConnectType_upload = 3
};

@interface EMLocalSocketManaget()<GCDAsyncSocketDelegate>{
    
}
@property (nonatomic, strong) EMSocketextend *sendMessagesocket;
@property (nonatomic, strong) EMSocketextend *downloadsocket;
@property (nonatomic, strong) EMSocketextend *uploadSocket;
@property (nonatomic, assign) NSInteger indexNumber;
@property (nonatomic, strong) dispatch_queue_t downloadsocketQueue;
@property (nonatomic, strong) dispatch_queue_t uploadsocketQueue;
@end

@implementation EMLocalSocketManaget
 
static EMLocalSocketManaget *sharedSocketManget = nil;

- (id)init{
    self = [super init];
    if (self) {
        self.indexNumber = 10;
        _downloadsocketQueue =  dispatch_queue_create([RHSocketQueuedown UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _uploadsocketQueue = dispatch_queue_create([RHSocketQueueupload UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

+(EMLocalSocketManaget*) sharedSocketManaget{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedSocketManget  = [[self alloc] init];
    });
    return sharedSocketManget;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t token;
     dispatch_once(&token, ^{
         if(sharedSocketManget == nil)
         {
             sharedSocketManget = [super allocWithZone:zone];
         }
     });
     return sharedSocketManget;
}

- (id)copy{
    return self;
}

- (id)mutableCopy{
    return self;
}

- (NSInteger )geCurrentIndex{
    return self.indexNumber ;
}

-(NSInteger )getNewIndex{
    __block OSSpinLock oslock = OS_SPINLOCK_INIT;
     OSSpinLockLock(&oslock);
    self.indexNumber = self.indexNumber+2;
    OSSpinLockUnlock(&oslock);
    return self.indexNumber;
}

- (NSString *)createdicKeyValue:(NSInteger )indexNumber{
    return [NSString stringWithFormat:@"sockquest%ld",indexNumber];
}

- (BOOL)socketPostMessage:(NSData *)data sendobject:(id<EMSocketextendDelegate>)senderObject{
    Byte *answerbyte = (Byte *)[data bytes];
    CDataHead *tempHead = new CDataHead;
    tempHead->Recv((char *)answerbyte);
    NSInteger m_dwDataID = tempHead->m_dwDataID;
    NSInteger m_wDataType = tempHead->m_wDataType;
    SockConnectType sockType = [self getSocketType:m_wDataType];
    switch (sockType) {
        case SockConnectType_send:
            if (!self.sendMessagesocket) {
                self.sendMessagesocket = [[EMSocketextend alloc] initWithDelegateQueue:dispatch_get_main_queue()];
                [self.sendMessagesocket reconnecthost];
            }
            [self.sendMessagesocket sendSockData:data sender:senderObject dwDataID:m_dwDataID];
        break;
        case SockConnectType_download:{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.sendMessagesocket sendSockData:data sender:senderObject dwDataID:m_dwDataID];
            });
        }
            break;
        case SockConnectType_upload:{
            dispatch_queue_t downDQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(downDQueue, ^{
                [self.sendMessagesocket sendSockData:data sender:senderObject dwDataID:m_dwDataID];
                
            });
        }
            break;
        default:
            break;
    }
    return YES;
}

- (void)startbackGroupHear{
    if (self.sendMessagesocket) {
        [self.sendMessagesocket heartConnect];
    }
}

- (void)resetAllSocket{
    [self.sendMessagesocket stopHeartconnect];
    self.sendMessagesocket =nil;
    
}

- (BOOL)sockConnectAvailble{
   return  [self.sendMessagesocket isConnected];
}

- (void)startHeartconnect{
    [self.sendMessagesocket startHeartConnect];
    if (!self.downloadsocket) {
         self.downloadsocket = [[EMSocketextend alloc] initWithDelegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [self.downloadsocket reconnecthost];
    }
    [self.downloadsocket startHeartConnect];
    
    if (!self.uploadSocket) {
          self.uploadSocket = [[EMSocketextend alloc] initWithDelegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [self.uploadSocket reconnecthost];
    }
    [self.uploadSocket startHeartConnect];
}

- (SockConnectType )getSocketType:(NSInteger )dataType{
    if (dataType == _DATA_IM_Upload_ ) {
        return SockConnectType_upload;
    }else if (dataType ==_DATA_IM_Download_){
        return SockConnectType_download;
    }else{
        return SockConnectType_send;
    }
}

#pragma delegate - GCDAsyncSocketDelegate
@end
