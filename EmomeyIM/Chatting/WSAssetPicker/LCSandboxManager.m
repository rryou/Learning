//
//  LCSandboxManager.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 10/6/15.
//  Copyright (c) 2015 Real Cloud. All rights reserved.
//

#import "LCSandboxManager.h"
const NSTimeInterval MaxAge_TmpFile = 24*60*60;
const NSTimeInterval MaxAge_TransferTmpFile = 3*24*60*60;

static BOOL removeFolder(NSString *folderPath)
{
    BOOL ok = YES;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *e = [fm enumeratorAtPath:folderPath];
    NSString *subpath = nil;
    while ((subpath = [e nextObject]) != nil) {
        BOOL isDirectory = NO;
        NSString *path = [folderPath stringByAppendingPathComponent:subpath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                if (!removeFolder(path)) {
                    ok = NO;
                }
            }
            else {
                error = nil;
                [fm removeItemAtPath:path error:&error];
                if (error) {
                    ok = NO;
                }
            }
        }
    }
    error = nil;
    [fm removeItemAtPath:folderPath error:&error];
    if (error) {
        ok = NO;
    }
    return ok;
}

@implementation LCSandboxManager

+ (instancetype)sharedInstance {
    static LCSandboxManager *instance;
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[LCSandboxManager alloc] init];
        });
    }
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _smartAppDataDir = [[self documentDir] stringByDeletingLastPathComponent];
    }
    return self;
}

- (NSString *)buildFolderpathInDir:(NSString *)dirpath foldername:(NSString *)foldername {
    NSString *folderpath = [dirpath stringByAppendingPathComponent:foldername];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderpath]) {
        [fileManager createDirectoryAtPath:folderpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folderpath;
}

- (NSString *)buildFolderpathInDirWithType:(LCSandboxDirType)type foldername:(NSString *)foldername {
    NSString *dir = nil;
    switch (type) {
        case LCSandboxDir_Tmp:
            dir = [self tmpDir];
            break;
            
        case LCSandboxDir_Cache:
            dir = [self cacheDir];
            break;
            
        case LCSandboxDir_Document:
            dir = [self documentDir];
            break;
            
        case LCSandboxDir_TransferTmp:
            dir = [self transferTmpDir];
            break;
            
        default:
            break;
    }
    if (dir) {
        dir = [self buildFolderpathInDir:dir foldername:foldername];
    }
    return dir;
}



- (NSString *)documentDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths firstObject];
    if (path == nil) {
        path = NSTemporaryDirectory();
    }
    return path;
}

- (NSString *)cacheDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths firstObject] : NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:basePath]) {
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return basePath;
}

- (NSString *)tmpDir {
    return NSTemporaryDirectory();
}

- (NSString *)transferTmpDir {
    return [self buildFolderpathInDir:[self documentDir] foldername:@"TransferTmp"];
}


- (BOOL)shouldUpgradeSandBox {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *sandBoxVersion = [ud stringForKey:@"kVersion_SandBox"];
    return NO;
}

- (void)upgradeSandBox:(dispatch_block_t)completion {
    dispatch_block_t blk = ^(){
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"kVersion_SandBox"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (completion) {
            completion();
        }
    };
    NSString *sandBoxVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"kVersion_SandBox"];
    if (sandBoxVersion == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *caches = [paths firstObject];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self removeSubPath:@"image" inRootPath:caches];
            [self removeSubPath:@"ImageCache/videos" inRootPath:caches];
            [self removeSubPath:@"voice" inRootPath:caches];
            [self removeSubPath:@"Export" inRootPath:caches];
            [self removeSubPath:@"LetterPager" inRootPath:caches];
            
            dispatch_async(dispatch_get_main_queue(), blk);
        });
    }
    else {
        blk();
    }
}

- (void)removeSubPath:(NSString *)subPath inRootPath:(NSString *)rootPath {
    [[NSFileManager defaultManager] removeItemAtPath:[rootPath stringByAppendingPathComponent:subPath] error:NULL];
}

- (void)removeExpiredTmpFiles {
    NSString *tempDir = [self tmpDir];
    NSURL *url = [NSURL fileURLWithPath:tempDir];
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-MaxAge_TmpFile];
    [self removeTempFilesInFolderURL:url expirationDate:expirationDate];
}

- (void)removeExpiredTransferTmpFiles {
    NSString *tempDir = [self transferTmpDir];
    NSURL *url = [NSURL fileURLWithPath:tempDir];
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-MaxAge_TransferTmpFile];
    [self removeTempFilesInFolderURL:url expirationDate:expirationDate];
}

- (void)removeTempFilesInFolderURL:(NSURL *)folderURL expirationDate:(NSDate *)expirationDate {
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:folderURL
                                                                 includingPropertiesForKeys:resourceKeys
                                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               errorHandler:NULL];
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        // Skip directories.
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
            [self removeTempFilesInFolderURL:fileURL expirationDate:expirationDate];
            continue;
        }
        
        // Remove files that are older than the expiration date;
        NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
        if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:NULL];
        }
    }
}

- (NSString *)smartLocalPathWithRelativePath:(NSString*)path
{
    return [self.smartAppDataDir stringByAppendingPathComponent:path];
}
@end
