//
//  PINCache+URLString.m
//  Pods
//
//  Created by flora on 16/5/25.
//
//

#import "PINCache+URLString.h"

@implementation PINCache(URLString)

#pragma mark -
#pragma mark cache

+ (id)ms_cacheObjectForURLString:(NSString *)URLString
{
    NSURL *url = [NSURL URLWithString:URLString];
    return [[PINCache sharedCache] objectForKey:url.absoluteString];
}

+ (void)ms_setCacheObject:(id)json forURLString:(NSString *)URLString disk:(BOOL)disk
{
    NSURL *url = [NSURL URLWithString:URLString];
    
    if (disk)
    {
        [[PINCache sharedCache] setObject:json forKey:url.absoluteString];
    }
    else
    {
        [[PINCache sharedCache].memoryCache setObject:json forKey:url.absoluteString];
    }
}

@end
