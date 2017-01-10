//
//  SYURLProtocol.m
//  SYURLProtocol
//
//  Created by Allen on 9/30/16.
//  Copyright © 2016 Allen. All rights reserved.
//

#import "MSURLProtocol.h"
//#import <AFNetworking/AFNetworkReachabilityManager.h>

NSString * const kMSURLPROTOCOLFORSERVERADDRESSKEY = @"MSURLProtocol_ProtocolClasses";

static NSString * URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface MSURLProtocol () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

static NSObject *SYSupportedSchemesMonitor;
static NSSet *SYSupportedSchemes;

@implementation MSURLProtocol

static id<MSURLProtocolURLMapping> ms_urlMapping;

+ (void)registerURLProtocolWithURLMapping:(id<MSURLProtocolURLMapping>)URLMapping {
    ms_urlMapping = URLMapping;
}

+ (NSMutableURLRequest *)modifiedRequestWithOriginalRequest:(NSURLRequest *)request {
    NSURL *requestURL = request.URL;
    
    NSString *newHost = [ms_urlMapping newHostForOriginalURLHost:requestURL.host];
    
    if (!newHost) {
        return (NSMutableURLRequest *)request;
    }
    
    NSMutableURLRequest *modifiedRequest = [request mutableCopy];
    modifiedRequest.URL = [NSURL URLWithString:[requestURL.absoluteString stringByReplacingOccurrencesOfString:requestURL.host withString:newHost]];
    
    return modifiedRequest;
}

+ (void)initialize
{
    if (self == [self class])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            SYSupportedSchemesMonitor = [NSObject new];
        });
        
        [self setSupportedSchemes:[NSSet setWithArray:@[@"http", @"https"]]];
    }
}

+ (void)start {
    [NSURLProtocol registerClass:[self class]];
}

#pragma mark * NSURLProtocol overrides
/*
 * return NO，不做处理
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    BOOL        shouldAccept;
    NSURL *     url;
    NSString *  scheme;
    
    shouldAccept = (request != nil);
    if (shouldAccept) {
        url = [request URL];
        shouldAccept = (url != nil);
    }
    if (!shouldAccept ) {
        //Url 不存在
    }
    
    // Get the scheme.
    
    if (shouldAccept) {
        scheme = [[url scheme] lowercaseString];
        shouldAccept = (scheme != nil);
        if (!shouldAccept ) {
            //scheme 不存在
        }
    }
 
    if (shouldAccept) {
        //只处理http 和 https请求,并且判断是否包含网络请求中的特定字符串，如果包含则是自己的服务器，替换请求
        if ([[self supportedSchemes] containsObject:scheme]) {
            
            const BOOL mappingForwardsHost = ([ms_urlMapping newHostForOriginalURLHost:request.URL.host] != nil);
            
            if (mappingForwardsHost) {
                //看看是否已经处理过了，防止无限循环
                if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
                    return NO;
                }
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest * mutableRequest = (NSMutableURLRequest *)request.mutableCopy;
    NSMutableURLRequest * newRequest = [self modifiedRequestWithOriginalRequest:mutableRequest];
    return newRequest;
}

- (void)startLoading {
//    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        NSMutableURLRequest * newRequest = (NSMutableURLRequest *)[self request].mutableCopy;
        //标示该request已经处理过了，防止无限循环
        [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:newRequest];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        self.dataTask = [session dataTaskWithRequest:newRequest];
        [self.dataTask resume];
//    } else {
//        //网络请求失败处理，或者加载缓存数据逻辑处理
//    }
}

- (void)stopLoading {
    [self.dataTask cancel];
    self.dataTask = nil;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    if (!error && error.code != NSURLErrorCancelled) {
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
}

+ (NSSet *)supportedSchemes {
    NSSet *supportedSchemes;
    @synchronized(SYSupportedSchemesMonitor)
    {
        supportedSchemes = SYSupportedSchemes;
    }
    return supportedSchemes;
}

+ (void)setSupportedSchemes:(NSSet *)supportedSchemes
{
    @synchronized(SYSupportedSchemesMonitor)
    {
        SYSupportedSchemes = supportedSchemes;
    }
}

@end
