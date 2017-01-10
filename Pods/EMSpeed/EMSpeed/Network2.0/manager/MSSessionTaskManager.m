//
//  MSSessionTaskManager.m
//  Pods
//
//  Created by flora on 16/5/25.
//
//

#import "MSSessionTaskManager.h"

#define MSSessionTaskManagerKey_Global @"global"

@implementation MSSessionTaskManager
{
    NSMutableDictionary *_tasks;
}

+ (id)sharedManager
{
    static dispatch_once_t onceQueue;
    static MSSessionTaskManager *mSSessionTaskManager = nil;
    
    dispatch_once(&onceQueue, ^{ mSSessionTaskManager = [[self alloc] init]; });
    return mSSessionTaskManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _tasks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSMutableArray *)_tasksForKey:(NSString *)key
{
    NSMutableArray *tasks = _tasks[key];
    if (tasks == nil && key && key.length) {
        _tasks[key] = [NSMutableArray array];
        tasks = _tasks[key];
    }
    return tasks;
}

- (void)addGlobalTask:(NSURLSessionTask *)task
{
    NSMutableArray *tasks = [self _tasksForKey:MSSessionTaskManagerKey_Global];
    [tasks addObject:task];
}

- (void)cancelGlobalTask:(NSURLSessionTask *)task
{
    [task cancel];
    NSMutableArray *tasks = [self _tasksForKey:MSSessionTaskManagerKey_Global];
    [tasks removeObject:task];
}

- (void)addTask:(NSURLSessionTask *)task forGroup:(NSString *)group
{
    NSMutableArray *tasks = [self _tasksForKey:group];
    [tasks addObject:task];
}

- (void)cancelTask:(NSURLSessionTask *)task forGroup:(NSString *)group
{
    [task cancel];
    NSMutableArray *tasks = [self _tasksForKey:group];
    [tasks removeObject:tasks];
}

- (void)cancelTasksForGroup:(NSString *)group
{
    NSMutableArray *tasks = [self _tasksForKey:group];
    [tasks makeObjectsPerformSelector: @selector(cancel)];
    [_tasks removeObjectForKey:group];
}

- (void)cancelTask:(NSURLSessionTask *)task
{
    [task cancel];
    
    for (NSMutableArray *tasks in _tasks.allValues)
    {
        if ([tasks containsObject:task]) {
            [tasks removeObject:task];
            break;
        }
    }
}

@end
