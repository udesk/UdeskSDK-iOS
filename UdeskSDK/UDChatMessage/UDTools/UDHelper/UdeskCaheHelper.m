//
//  UdeskCaheHelper.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskCaheHelper.h"

#define UdeskCache @"UdeskCache"

@implementation UdeskCaheHelper

+ (instancetype)sharedManager {
    static UdeskCaheHelper *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[UdeskCaheHelper alloc] initWithName:UdeskCache];
    });
    
    return _sharedManager;
}

- (void)storeVideo:(NSData *)videoData videoId:(NSString *)videoId {

    NSString *filePath = self.diskCache.path;
    filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",videoId]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:filePath contents:videoData attributes:nil];
}

- (BOOL)containsObjectForKey:(NSString *)key {

    NSString *filePath = self.diskCache.path;
    filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",key]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

- (NSString *)filePathForkey:(NSString *)key {

    NSString *filePath = self.diskCache.path;
    return [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",key]];
}

- (NSString *)filePath {
    
    return self.diskCache.path;
}

@end
