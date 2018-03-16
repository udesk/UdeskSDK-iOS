//
//  WHC_DownloadObject.m
//  WHC_FileDownloadDemo
//
//  Created by 吴海超 on 15/11/27.
//  Copyright © 2015年 吴海超. All rights reserved.
//

#import "Udesk_WHC_DownloadObject.h"
#import <CommonCrypto/CommonDigest.h>
const static double k1MB = 1024 * 1024;

@implementation Udesk_WHC_DownloadObject 

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadSpeed = @"0KB/s";
        _downloadState = Udesk_WHCNone;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_etag forKey:@"etag"];
    [aCoder encodeObject:_fileName forKey:@"fileName"];
    [aCoder encodeObject:_downloadPath forKey:@"downloadPath"];
    [aCoder encodeInt64:_totalLenght forKey:@"totalLenght"];
    [aCoder encodeInt64:_currentDownloadLenght forKey:@"currentDownloadLenght"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _etag = [aDecoder decodeObjectForKey:@"fileName"];
        _downloadSpeed = @"0KB/s";
        _fileName = [aDecoder decodeObjectForKey:@"fileName"];
        _downloadPath = [aDecoder decodeObjectForKey:@"downloadPath"];
        _currentDownloadLenght = [aDecoder decodeInt64ForKey:@"currentDownloadLenght"];
        _totalLenght = [aDecoder decodeInt64ForKey:@"totalLenght"];
        _downloadState = _totalLenght != 0 ? (self.currentDownloadLenght == self.totalLenght ? Udesk_WHCDownloadCompleted : Udesk_WHCDownloadCanceled) : Udesk_WHCNone;
    }
    return self;
}

+ (NSString *)cacheDirectory {
    return [NSString stringWithFormat:@"%@/Library/Caches/WHCDownloadObjectCache/",NSHomeDirectory()];
}

+ (NSString *)cachePlistDirectory {
    return [NSString stringWithFormat:@"%@/Library/Caches/WHCCachePlistDirectory/",NSHomeDirectory()];
}

+ (NSString *)cachePlistPath {
    return [NSString stringWithFormat:@"%@WHCDownloadCache.plist",[Udesk_WHC_DownloadObject cachePlistDirectory]];
}

+ (NSString *)videoDirectory {
    return [NSString stringWithFormat:@"%@/Library/Caches/WHCVideos/",NSHomeDirectory()];
}

+ (Udesk_WHC_DownloadObject *)readDiskCache:(NSString *)downloadPath {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[Udesk_WHC_DownloadObject getCachedFileName:downloadPath]];
}

+ (NSArray *)readDiskAllCache {
    NSMutableArray * downloadObjectArr = [NSMutableArray array];
    NSMutableDictionary * cacheDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[Udesk_WHC_DownloadObject cachePlistPath]];
    if (cacheDictionary != nil) {
        NSArray * allKeys = [cacheDictionary allKeys];
        for (NSString * path in allKeys) {
            [downloadObjectArr addObject:[Udesk_WHC_DownloadObject readDiskCache:path]];
        }
    }
    return downloadObjectArr;
}

+ (NSString *)getCachedFileName:(NSString *)name {
    NSMutableString * cachedFileName = [NSMutableString string];
    if (name != nil) {
        const char * cStr = name.UTF8String;
        unsigned char buffer[CC_MD5_DIGEST_LENGTH];
        memset(buffer, 0x00, CC_MD5_DIGEST_LENGTH);
        CC_MD5(cStr, (CC_LONG)(strlen(cStr)), buffer);
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [cachedFileName appendFormat:@"%02x",buffer[i]];
        }
        return [NSString stringWithFormat:@"%@%@",[Udesk_WHC_DownloadObject cacheDirectory],cachedFileName];
    }
    return [NSString stringWithFormat:@"%@WHC",[Udesk_WHC_DownloadObject cacheDirectory]];
}

- (float)downloadProcessValue {
    return (double)_currentDownloadLenght / ((double)_totalLenght == 0 ? 1 : _totalLenght);
}

- (NSString *)currentDownloadLenghtToString {
    return [NSString stringWithFormat:@"%.1fMB",(double)_currentDownloadLenght / k1MB];
}

- (NSString *)totalLenghtToString {
    return [NSString stringWithFormat:@"%.1fMB",(double)_totalLenght / k1MB];
}

- (NSString *)downloadProcessText {
    return [NSString stringWithFormat:@"%@/%@", self.currentDownloadLenghtToString,self.totalLenghtToString];
}

- (void)createCacheDirectory:(NSString *)path {
    NSFileManager * fm = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if (![fm fileExistsAtPath:path isDirectory:&isDirectory]) {
        [fm createDirectoryAtPath:path
      withIntermediateDirectories:YES
                       attributes:@{NSFileProtectionKey:NSFileProtectionNone} error:nil];
    }
}

- (void)writeDiskCache {
    if (_downloadPath != nil) {
        [self createCacheDirectory:[Udesk_WHC_DownloadObject cacheDirectory]];
        [NSKeyedArchiver archiveRootObject:self
                                    toFile:[Udesk_WHC_DownloadObject getCachedFileName:_fileName]];//_downloadPath
        [self createCacheDirectory:[Udesk_WHC_DownloadObject cachePlistDirectory]];
        NSMutableDictionary * cacheDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[Udesk_WHC_DownloadObject cachePlistPath]];
        if (cacheDictionary == nil) {
            cacheDictionary = [NSMutableDictionary dictionary];
        }
        [cacheDictionary setObject:@"WHC" forKey:_fileName];//_downloadPath
        [cacheDictionary writeToFile:[Udesk_WHC_DownloadObject cachePlistPath] atomically:YES];
    }
}

- (void)removeFromDisk {
    NSFileManager * fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[Udesk_WHC_DownloadObject getCachedFileName:_fileName]]) {//_downloadPath
        [fm removeItemAtPath:[Udesk_WHC_DownloadObject getCachedFileName:_fileName] error:nil];//_downloadPath
        NSMutableDictionary * cacheDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[Udesk_WHC_DownloadObject cachePlistPath]];
        if (cacheDictionary != nil) {
            [cacheDictionary removeObjectForKey:_fileName];//_downloadPath
            [cacheDictionary writeToFile:[Udesk_WHC_DownloadObject cachePlistPath] atomically:YES];
        }
        if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@%@",[Udesk_WHC_DownloadObject videoDirectory],_fileName]]) {
            [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@",[Udesk_WHC_DownloadObject videoDirectory],_fileName] error:nil];
        }
    }
}

@end
