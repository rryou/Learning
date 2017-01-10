//
//  MSHTTPSessionHandler.h
//  Pods
//
//  Created by flora on 16/4/29.
//
//

#ifndef MSHTTPSessionDebugHandler_h
#define MSHTTPSessionDebugHandler_h

@protocol MSHTTPSessionDebugHandler <NSObject>

@optional
/**
 *  请求出现异常时，调用这个方法
 *
 *  @param error 错误对象
 */
- (void)handleRequestError:(NSError *)error;

/**
 *  当请求回调时调用，提供外部做数据统计
 *
 *  @param URL      请求的urk
 *  @param downLoadLen 下载数据长度
 *  @param uploadLen   上传参数的长度
 */
- (void)handleRequestFlowData:(NSString *)URL
                  downLoadLen:(NSUInteger)downLoadLen
                    uploadLen:(NSUInteger)uploadLen;
@end
#endif /* MSHTTPSessionDebugHandler_h */
