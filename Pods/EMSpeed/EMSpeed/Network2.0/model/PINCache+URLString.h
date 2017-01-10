//
//  PINCache+URLString.h
//  Pods
//
//  Created by flora on 16/5/25.
//
//

#import <PINCache/PINCache.h>

@interface PINCache(URLString)
#pragma mark -
#pragma mark cache

/**
 *  获取url对应的缓存数据
 *
 *  @param URLString 数据请求
 *
 *  @return
 */
+ (id)ms_cacheObjectForURLString:(NSString *)URLString;

/**
 *  存储json 到本地
 *
 *  @param json      数据
 *  @param URLString 地址
 *  @param disk      是否存储到本地，YES：存储到本地。 NO：存储到内存中
 */
+ (void)ms_setCacheObject:(id)json forURLString:(NSString *)URLString disk:(BOOL)disk;

@end
