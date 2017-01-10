//
//  MSJSONSessionManager.h
//  Pods
//
//  Created by flora on 16/4/27.
//
//

#import <AFNetworking/AFNetworking.h>
#import "MSHTTPSessionDebugHandler.h"
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  json解析为数据对象后的回调
 *
 *  @param jsonModel 数据对象，
 *  @param err       错误信息
 */
typedef void (^MSJSONModelBlock)(__nullable id jsonModel, JSONModelError* _Nullable  err);

/**
 *
 *  @param json     json 数据
 *  @param err       错误信息
 */
typedef void (^MSJSONObjectBlock)(__nullable id json, JSONModelError* _Nullable  err);

@interface MSJSONSessionManager : AFHTTPSessionManager


@property (nonatomic, strong) __nullable id <MSHTTPSessionDebugHandler> debugHandler;//可在回调中处理异常信息、数据回调处理
@property (nonatomic, strong) NSDictionary *defaultHeaders;   //外部可设置通用的认证参数（header）
+ (nonnull instancetype)sharedManager;


- (nullable NSURLSessionDataTask *)GET:(nonnull NSString *)URLString
                            parameters:(nullable id)parameters
                          headerFields:(nullable id)headerFields
                            completion:(nullable MSJSONObjectBlock)completeBlock;

- (nullable NSURLSessionDataTask *)POST:(nonnull NSString *)URLString
                             parameters:(nullable id)parameters
                           headerFields:(nullable id)headerFields
                             completion:(nullable MSJSONObjectBlock)completeBlock;


@end

/**
 *  通过在请求的时候配置 jsonModelClass，返回经解析过的 jsonmodel 对象数据。
 */
@interface MSJSONSessionManager(JSONModel)

- (nullable NSURLSessionDataTask *)JM_GET:(nonnull NSString *)URLString
                               parameters:(nullable id)parameters
                             headerFields:(nullable id)headerFields
                           JSONModelClass:(nonnull Class)jsonModelClass
                               completion:(nullable MSJSONModelBlock)completeBlock;

- (nullable NSURLSessionDataTask *)JM_POST:(nonnull NSString *)URLString
                                parameters:(nullable id)parameters
                              headerFields:(nullable id)headerFields
                            JSONModelClass:(nonnull Class)jsonModelClass
                                completion:(nullable MSJSONModelBlock)completeBlock;

@end

NS_ASSUME_NONNULL_END
