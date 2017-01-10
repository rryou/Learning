//
//  SYURLProtocol.h
//  SYURLProtocol
//
//  Created by Allen on 9/30/16.
//  Copyright © 2016 Allen. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMSURLPROTOCOLFORSERVERADDRESSKEY; //用来作为是否设置protocolClasses的key

@protocol MSURLProtocolURLMapping <NSObject>

- (NSString *)newHostForOriginalURLHost:(NSString *)originalURLHost;

@end

@interface MSURLProtocol : NSURLProtocol

+ (void)registerURLProtocolWithURLMapping:(id<MSURLProtocolURLMapping>)URLMapping;

// 如果使用AF，可以不调用这个方法
+ (void)start;

//设置支持的schemes，默认支持http和https
+ (void)setSupportedSchemes:(NSSet *)supportedSchemes;

@end
