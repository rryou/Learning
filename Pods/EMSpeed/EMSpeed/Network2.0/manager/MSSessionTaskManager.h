//
//  MSSessionTaskManager.h
//  Pods
//
//  Created by flora on 16/5/25.
//
//任务管理
//帮助controller、model 进行任务的管理，分为两个部分
//1、全局任务的处理，这类任务跟页面无关
//2、页面任务的处理，增加页面group的概念，添加任务时按照group添加，后续可通过cancel group中所有的任务。

#import <Foundation/Foundation.h>


@interface MSSessionTaskManager : NSObject

+ (id)sharedManager;

- (void)addGlobalTask:(NSURLSessionTask *)task;
- (void)cancelGlobalTask:(NSURLSessionTask *)task;

- (void)addTask:(NSURLSessionTask *)task forGroup:(NSString *)group;
- (void)cancelTask:(NSURLSessionTask *)task forGroup:(NSString *)group;
- (void)cancelTask:(NSURLSessionTask *)task;
- (void)cancelTasksForGroup:(NSString *)group;

@end
