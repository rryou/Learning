//
//  LCSandboxManager.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 10/6/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LCSandboxDir_Document,
    LCSandboxDir_Cache,
    LCSandboxDir_Tmp,
    LCSandboxDir_TransferTmp,
} LCSandboxDirType;

@interface LCSandboxManager : NSObject

@property (nonatomic, readonly) NSString *dbPath;
@property (nonatomic, readonly) NSString *statisticsDBPath;
@property (nonatomic, readonly) NSString *smartAppDataDir; //app Data 的目录  因为每次重启 这个目录都是不一样的

+ (instancetype)sharedInstance;

- (NSString *)buildFolderpathInDir:(NSString *)dirpath foldername:(NSString *)foldername;
- (NSString *)buildFolderpathInDirWithType:(LCSandboxDirType)type foldername:(NSString *)foldername;

- (NSString *)documentDir;
- (NSString *)cacheDir;
- (NSString *)tmpDir;
- (NSString *)smartLocalPathWithRelativePath:(NSString*)path;

// 用于上传的文件目录
// 特征：发送完成或取消 用户自行决定是否清理产生的文件，失败的文件会缓存较长时间
// 该目录每次启动清理过期文件（如过期时间可定为3天）
// 如果该文件每次发送都要重新生成，则不要使用该接口，应该选择
- (NSString *)transferTmpDir;
- (BOOL)shouldUpgradeSandBox;
- (void)upgradeSandBox:(dispatch_block_t)completion;

- (void)removeExpiredTmpFiles;
- (void)removeExpiredTransferTmpFiles;

@end
