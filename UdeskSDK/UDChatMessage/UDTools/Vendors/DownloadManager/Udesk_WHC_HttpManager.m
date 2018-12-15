//
//  WHC_HttpManager.m
//  WHCNetWorkKit
//
//  Created by 吴海超 on 15/11/6.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */

#import "Udesk_WHC_HttpManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Udesk_WHC_DownloadObject.h"
#import "UdeskBundleUtils.h"

//默认下载并发数量 在这里修改
const NSInteger kUdeskWHCDefaultDownloadNumber = 5;

@interface Udesk_WHC_HttpManager () {
    NSOperationQueue     * _httpOperationQueue;
    NSOperationQueue     * _fileDownloadOperationQueue;
    
    NSMutableArray       * _fileDataArr;
    NSMutableArray       * _uploadParamArr;
    NSMutableData        * _uploadPostData;
}


@end

@implementation Udesk_WHC_HttpManager

+ (nonnull instancetype)shared {
    static  Udesk_WHC_HttpManager * WHCHttpManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WHCHttpManager = [Udesk_WHC_HttpManager new];
    });
    return WHCHttpManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _httpOperationQueue = [NSOperationQueue new];
        _httpOperationQueue.maxConcurrentOperationCount = 20;
        _failedUrls = [NSMutableSet set];
        _encoderType = NSUTF8StringEncoding;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _contentType = @"application/x-www-form-urlencoded";
    }
    return self;
}

#pragma mark - get请求 -

- (nullable Udesk_WHC_HttpOperation *)get:(nonnull NSString *)strUrl
               didFinished:(nullable Udesk_WHCDidFinished)finishedBlock {
    return [self get:strUrl process:nil didFinished:finishedBlock];
}

- (nullable Udesk_WHC_HttpOperation *)get:(nonnull NSString *)strUrl
                   process:(nullable Udesk_WHCProgress) processBlock
               didFinished:(nullable Udesk_WHCDidFinished)finishedBlock {
    Udesk_WHC_HttpOperation * getOperation = nil;
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        getOperation = [Udesk_WHC_HttpOperation new];
        getOperation.requestType = Udesk_WHCHttpRequestGet;
        getOperation.progressBlock = processBlock;
        getOperation.strUrl = strUrl;
        __weak typeof(self) weakSelf = self;
        getOperation.didFinishedBlock = ^(Udesk_WHC_BaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
            if (!isSuccess && error.code == 404) {
                [weakSelf.failedUrls addObject:strUrl];
            }
            if (finishedBlock) {
                finishedBlock(operation , data , error , isSuccess);
            }
        };
        [self setHttpOperation:getOperation];
        [_httpOperationQueue addOperation:getOperation];
    }else {
        if (finishedBlock) {
            __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
            finishedBlock(nil , nil , error , NO);
        }
    }
    return getOperation;
}

#pragma mark - post请求 -

- (nullable Udesk_WHC_HttpOperation *)post:(nonnull NSString *)strUrl
                      param:(nullable NSString *)param
                didFinished:(nullable Udesk_WHCDidFinished)finishedBlock {
    return [self post:strUrl param:param process:nil didFinished:finishedBlock];
}

- (nullable Udesk_WHC_HttpOperation *)post:(nonnull NSString *)strUrl
                      param:(nullable NSString *)param
                    process:(nullable Udesk_WHCProgress) processBlock
                didFinished:(nullable Udesk_WHCDidFinished)finishedBlock {
    Udesk_WHC_HttpOperation * postOperation = nil ;
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        postOperation = [Udesk_WHC_HttpOperation new];
        postOperation.requestType = Udesk_WHCHttpRequestPost;
        postOperation.progressBlock = processBlock;
        postOperation.postParam = param;
        postOperation.strUrl = strUrl;
        __weak typeof(self) weakSelf = self;
        postOperation.didFinishedBlock = ^(Udesk_WHC_BaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
            if (!isSuccess && error.code == 404) {
                [weakSelf.failedUrls addObject:strUrl];
            }
            if (finishedBlock) {
                finishedBlock(operation , data , error , isSuccess);
            }
        };
        [self setHttpOperation:postOperation];
        [_httpOperationQueue addOperation:postOperation];
    }else {
        if (finishedBlock) {
            __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
            finishedBlock(nil , nil , error , NO);
        }
    }

    return postOperation;
}

#pragma mark - 文件上传 -

- (nullable Udesk_WHC_HttpOperation *)upload:(nonnull NSString *)strUrl
                        param:(nullable NSDictionary *)paramDict
                  didFinished:(nullable Udesk_WHCDidFinished)finishedBlock {
    return [self upload:strUrl
                  param:paramDict
                process:nil
            didFinished:finishedBlock];
}
/**
 说明:文件上传开始
 strUrl:上传路径
 param:上传附带参数
 callBack：上传结束回调
 */
- (nullable Udesk_WHC_HttpOperation *)upload:(nonnull NSString *)strUrl
                        param:(nullable NSDictionary *)paramDict
                      process:(nullable Udesk_WHCProgress) processBlock
                  didFinished:(nullable Udesk_WHCDidFinished)finishedBlock {
    [self setPostParamDict:paramDict];
    [self buildMultipartFormDataPostBody];
    Udesk_WHC_HttpOperation * uploadOperation = nil ;
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        uploadOperation = [Udesk_WHC_HttpOperation new];
        [self setHttpOperation:uploadOperation];
        uploadOperation.requestType = Udesk_WHCHttpRequestFileUpload;
        uploadOperation.progressBlock = processBlock;
        uploadOperation.strUrl = strUrl;
        uploadOperation.postParam = _uploadPostData;
        __weak typeof(self) weakSelf = self;
        uploadOperation.didFinishedBlock = ^(Udesk_WHC_BaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
            [_uploadParamArr removeAllObjects];
            [_fileDataArr removeAllObjects];
            [_uploadPostData resetBytesInRange:NSMakeRange(0, _uploadPostData.length)];
            [_uploadPostData setLength:0];
            if (!isSuccess && error.code == 404) {
                [weakSelf.failedUrls addObject:strUrl];
            }
            if (finishedBlock) {
                finishedBlock(operation , data , error , isSuccess);
            }
        };
        NSString * charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        uploadOperation.contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, kUdeskWHCUploadCode];
        [_httpOperationQueue addOperation:uploadOperation];
    }else {
        if (finishedBlock) {
            __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
            finishedBlock(nil , nil , error , NO);
        }
    }
    return uploadOperation;
}

#pragma mark - 文件下载 -

- (nullable Udesk_WHC_DownloadOperation *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                    delegate:(nullable id<WHC_DownloadDelegate>)delegate {
    return [self download:strUrl savePath:savePath saveFileName:nil delegate:delegate];
}


- (nullable Udesk_WHC_DownloadOperation *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                saveFileName:(nullable NSString *)saveFileName
                                    delegate:(nullable id<WHC_DownloadDelegate>)delegate {
    
    Udesk_WHC_DownloadOperation  * downloadOperation = nil;
    NSString * fileName = nil;
    if (!saveFileName) {
        saveFileName = [[NSUUID UUID] UUIDString];
    }
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        fileName = [self handleFileName:saveFileName url:strUrl];
        for (Udesk_WHC_DownloadOperation * tempDownloadOperation in _fileDownloadOperationQueue.operations) {
            if ([fileName isEqualToString:tempDownloadOperation.saveFileName]){
                __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:已经在下载中",fileName]];
                if (delegate && [delegate respondsToSelector:@selector(WHCDownloadResponse:error:ok:)]) {
                    [delegate WHCDownloadResponse:tempDownloadOperation error:error ok:NO];
                } else if (delegate && [delegate respondsToSelector:@selector(WHCDownloadDidFinished:data:error:success:)]) {
                    [delegate WHCDownloadDidFinished:tempDownloadOperation data:nil error:error success:NO];
                }
                return tempDownloadOperation;
            }
        }
        if([self createFileSavePath:savePath]) {
            downloadOperation = [Udesk_WHC_DownloadOperation new];
            downloadOperation.requestType = Udesk_WHCHttpRequestGet;
            downloadOperation.saveFileName = fileName;
            downloadOperation.saveFilePath = savePath;
            downloadOperation.delegate = delegate;
            downloadOperation.strUrl = strUrl;
            [self setHttpOperation:downloadOperation];
            [_fileDownloadOperationQueue addOperation:downloadOperation];
        }
    }else {
        __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:请求失败",saveFileName]];
        if (delegate && [delegate respondsToSelector:@selector(WHCDownloadDidFinished:data:error:success:)]) {
            [delegate WHCDownloadDidFinished:downloadOperation data:nil error:error success:NO];
        }
    }
    return downloadOperation;
}

/**
 参数说明：
 url:下载路径
 savePath:文件本地存储路径
 delegate:下载状态监控代理
 */
- (nullable Udesk_WHC_DownloadOperation *)download:(nonnull NSString *)strUrl
                           savePath:(nonnull NSString *)savePath
                            response:(nullable Udesk_WHCResponse) responseBlock
                            process:(nullable Udesk_WHCProgress) processBlock
                        didFinished:(nullable Udesk_WHCDidFinished) finishedBlock {
    
    return [self download:strUrl
                 savePath:savePath
             saveFileName:nil
                 response:responseBlock
                  process:processBlock
              didFinished:finishedBlock];
}

/**
 参数说明：
 url:下载路径
 savePath:文件本地存储路径
 savefileName:下载要存储的文件名
 delegate:下载状态监控代理
 */
- (nullable Udesk_WHC_DownloadOperation *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                saveFileName:(nullable NSString *)saveFileName
                                    response:(nullable Udesk_WHCResponse) responseBlock
                                     process:(nullable Udesk_WHCProgress) processBlock
                                 didFinished:(nullable Udesk_WHCDidFinished) finishedBlock {

    Udesk_WHC_DownloadOperation  * downloadOperation = nil;
    NSString * fileName = nil;
    if (!saveFileName) {
        saveFileName = [[NSUUID UUID] UUIDString];
    }
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        fileName = [self handleFileName:saveFileName url:strUrl];
        
        if([self createFileSavePath:savePath]) {
            downloadOperation = [Udesk_WHC_DownloadOperation new];
            downloadOperation.isDeleted = YES;
            downloadOperation.requestType = Udesk_WHCHttpRequestGet;
            downloadOperation.saveFileName = fileName;
            downloadOperation.saveFilePath = savePath;
            downloadOperation.progressBlock = processBlock;
            downloadOperation.responseBlock = responseBlock;
            downloadOperation.strUrl = strUrl;
            __weak typeof(self) weakSelf = self;
            downloadOperation.didFinishedBlock = ^(Udesk_WHC_BaseOperation *operation,
                                                   NSData *data,
                                                   NSError *error,
                                                   BOOL isSuccess) {
                if (!isSuccess && error.code == 404) {
                    [weakSelf.failedUrls addObject:strUrl];
                }
                if (finishedBlock) {
                    finishedBlock(operation , data , error , isSuccess);
                }
            };
            [self setHttpOperation:downloadOperation];
            [_fileDownloadOperationQueue addOperation:downloadOperation];
        }
    }else {
        __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"请求失败"]];
        if (responseBlock) {
            responseBlock(downloadOperation , error , NO);
        }else if (finishedBlock) {
            finishedBlock(downloadOperation , nil , error , NO);
        }
    }
    return downloadOperation;
}



#pragma mark - 文件上传工具方法 -

/*
 说明:添加上传文件数据,可多次调用添加上传多个文件
 data:可以是二进制数据也可以是本地文件路径
 fileName:文件名称
 mimeType:文件类型如图片(image/jpeg)
 key：关键字名称这个必须和服务端对应
 */
- (void)addUploadFileData:(nonnull NSObject *)data
             withFileName:(nonnull NSString *)fileName
                 mimeType:(nonnull NSString *)mimeType
                   forKey:(nonnull NSString *)key {
    
    if (_fileDataArr == nil) {
        _fileDataArr = [NSMutableArray array];
    }
    if (!mimeType) {
        mimeType = @"application/octet-stream";
    }
    
    NSMutableDictionary *fileInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    [fileInfo setValue:key forKey:@"key"];
    [fileInfo setValue:fileName forKey:@"fileName"];
    [fileInfo setValue:mimeType forKey:@"contentType"];
    [fileInfo setValue:data forKey:@"data"];
    
    [_fileDataArr addObject:fileInfo];
}

/*
 说明:添加上传文件路径，可多次调用添加上传多个文件
 filePath：文件路径
 key：关键字名称这个必须和服务端对应
 */
- (void)addUploadFile:(nonnull NSString *)filePath
               forKey:(nonnull NSString *)key {
    NSFileManager  * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:filePath]){
        NSString  * fileName = filePath.lastPathComponent;
        NSString  * mimeType = [self mimeTypeForFileAtPath:filePath];
        [self addUploadFileData:filePath withFileName:fileName mimeType:mimeType forKey:key];
    }
}

#pragma mark - 文件下载工具方法 -

- (BOOL)waitingDownload {
    return _fileDownloadOperationQueue.operations.count > kUdeskWHCDefaultDownloadNumber;
}

- (nullable NSString *)handleFileName:(NSString *)saveFileName url:(NSString *)strUrl {
    if (!_fileDownloadOperationQueue) {
        _fileDownloadOperationQueue = [NSOperationQueue new];
        _fileDownloadOperationQueue.maxConcurrentOperationCount = kUdeskWHCDefaultDownloadNumber;
    }
    NSString * fileName = saveFileName;
    if(saveFileName){
        NSString * format = [self fileFormatWithUrl:strUrl];
        if(format && ![format isEqualToString:[NSString stringWithFormat:@".%@",
                                    [[saveFileName componentsSeparatedByString:@"."] lastObject]]]){
            fileName = [NSString stringWithFormat:@"%@%@",saveFileName,format];
        }
    }
    return fileName;
}

//返回指定文件名下载对象
- (nullable Udesk_WHC_DownloadOperation *)downloadOperationWithFileName:(nonnull NSString *)fileName {
    Udesk_WHC_DownloadOperation * downloadOperation = nil;
    for (Udesk_WHC_DownloadOperation * tempDownloadOperation in _fileDownloadOperationQueue.operations) {
        if([tempDownloadOperation.saveFileName isEqualToString:fileName]){
            downloadOperation = tempDownloadOperation;
            break;
        }
    }
    return downloadOperation;
}

/**
 note:该方法必须在开始下载之前调用
 说明：
 设置最大下载数量
 */
- (void)setMaxDownloadQueueCount:(NSUInteger)count {
    _fileDownloadOperationQueue.maxConcurrentOperationCount = count;
}

/**
 说明:返回下载中心最大同时下载操作个数
 */
- (NSInteger)currentDownloadCount {
    return _fileDownloadOperationQueue.maxConcurrentOperationCount;
}

/**
 说明：
 取消所有正下载并是否取消删除文件
 */
- (void)cancelAllDownloadTaskAndDelFile:(BOOL)isDelete {
    for (Udesk_WHC_DownloadOperation * operation in _fileDownloadOperationQueue.operations) {
        [operation cancelDownloadTaskAndDeleteFile:isDelete];
    }
}

/**
 说明：
 取消指定正下载url的下载
 */
- (void)cancelDownloadWithDownloadUrl:(nonnull NSString *)strUrl deleteFile:(BOOL)isDelete {
    for(Udesk_WHC_DownloadOperation * operation in _fileDownloadOperationQueue.operations){
        if ([operation.strUrl isEqualToString:strUrl]) {
            [operation cancelDownloadTaskAndDeleteFile:isDelete];
            break;
        }
    }
}

/**
 说明：
 取消指定正下载文件名的下载
 */
- (void)cancelDownloadWithFileName:(nonnull NSString *)fileName deleteFile:(BOOL)isDelete {
    for(Udesk_WHC_DownloadOperation * operation in _fileDownloadOperationQueue.operations){
        if([operation.saveFileName isEqualToString:fileName]){
            [operation cancelDownloadTaskAndDeleteFile:isDelete];
            break;
        }
    }
}


/**
 说明：
 替换当前代理通过要下载的文件名
 使用情景:(当从控制器B进入到控制器C然后在控制器C中进行下载，然后下载过程中突然退出到控制器B，
 在又进入到控制器C，这个时候还是在下载但是代理对象和之前的那个控制器C不是一个对象所以要替换)
 */


- (Udesk_WHC_DownloadOperation *)replaceCurrentDownloadOperationBlockResponse:(nullable Udesk_WHCResponse)responseBlock
                                             process:(nullable Udesk_WHCProgress)processBlock
                                         didFinished:(nullable Udesk_WHCDidFinished)didFinishedBlock
                                            fileName:(nonnull NSString *)fileName {
    for (Udesk_WHC_DownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
        if([downloadOperation.saveFileName isEqualToString:fileName]){
            downloadOperation.delegate = nil;
            downloadOperation.progressBlock = processBlock;
            downloadOperation.responseBlock = responseBlock;
            downloadOperation.didFinishedBlock = didFinishedBlock;
            return downloadOperation;
        }
    }
    return nil;
}

- (Udesk_WHC_DownloadOperation *)replaceCurrentDownloadOperationDelegate:(nullable id<WHC_DownloadDelegate>)delegate
                                       fileName:(nonnull NSString *)fileName {
    for (Udesk_WHC_DownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
        if([downloadOperation.saveFileName isEqualToString:fileName]){
            downloadOperation.progressBlock = nil;
            downloadOperation.responseBlock = nil;
            downloadOperation.didFinishedBlock = nil;
            downloadOperation.delegate = delegate;
            return downloadOperation;
        }
    }
    return nil;
}

//替换所有当前下载代理
- (Udesk_WHC_DownloadOperation *)replaceAllDownloadOperationBlockResponse:(nullable Udesk_WHCResponse)responseBlock
                                         process:(nullable Udesk_WHCProgress)processBlock
                                     didFinished:(nullable Udesk_WHCDidFinished)didFinishedBlock {
    if (_fileDownloadOperationQueue.operations.count > 0) {
        for (Udesk_WHC_DownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
            downloadOperation.delegate = nil;
            downloadOperation.progressBlock = processBlock;
            downloadOperation.responseBlock = responseBlock;
            downloadOperation.didFinishedBlock = didFinishedBlock;
        }
        return nil;
    }
    return nil;
}

- (Udesk_WHC_DownloadOperation *)replaceAllDownloadOperationDelegate:(nullable id<WHC_DownloadDelegate>)delegate {
    if (_fileDownloadOperationQueue.operations.count > 0) {
        for (Udesk_WHC_DownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
            downloadOperation.progressBlock = nil;
            downloadOperation.responseBlock = nil;
            downloadOperation.didFinishedBlock = nil;
            downloadOperation.delegate = delegate;
        }
        return nil;
    }
    return nil;
}


/**
 说明：
 通过要下载的文件名来判断当前是否在进行下载任务
 */
- (BOOL)existDownloadOperationTaskWithFileName:(nonnull NSString *)fileName {
    BOOL  result = NO;
    for (Udesk_WHC_DownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
        if([downloadOperation.saveFileName isEqualToString:fileName]){
            result = YES;
            break;
        }
    }
    return result;
}

- (BOOL)existDownloadOperationTaskWithUrl:(nonnull NSString *)strUrl {
    BOOL  result = NO;
    for (Udesk_WHC_DownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
        if([downloadOperation.strUrl isEqualToString:strUrl]){
            result = YES;
            break;
        }
    }
    return result;
}

#pragma mark - 公共方法 -

- (void)cancelHttpRequestWithUrl:(nonnull NSString *)url {
    for (Udesk_WHC_BaseOperation * operation in _httpOperationQueue.operations) {
        if ([operation.strUrl isEqualToString:url]) {
            [operation endRequest];
        }
    }
}

- (nullable NSString *)fileFormatWithUrl:(nonnull NSString *)downloadUrl {
    NSArray  * strArr = [downloadUrl componentsSeparatedByString:@"."];
    if(strArr && strArr.count > 0){
        NSString * suffix = strArr.lastObject;
        if (suffix.length > 7) {
            return nil;
        }
        return [NSString stringWithFormat:@".%@",strArr.lastObject].lowercaseString;
    }else{
        return nil;
    }
}

- (nonnull NSString*)createHttpParam:(nonnull NSDictionary *)paramDictionary {
    NSString *postString=@"";
    for(NSString *key in [paramDictionary allKeys]){
        NSString *value = [paramDictionary objectForKey:key];
        postString = [postString stringByAppendingFormat:@"%@=%@&",key,value];
    }
    if([postString length] > 1){
        postString = [postString substringToIndex:[postString length]-1];
    }
    return postString;
}

#pragma mark - 私有方法 -

- (__autoreleasing NSError *)error:(nonnull NSString *)message {
    __autoreleasing NSError  * error = [[NSError alloc]initWithDomain:kUdeskWHCDomain
                                                                 code:Udesk_WHCGeneralError
                                                             userInfo:@{NSLocalizedDescriptionKey:
                                                                            message}];
    return error;
}

- (void)setHttpOperation:(Udesk_WHC_BaseOperation *)httpOperation {
    httpOperation.encoderType = _encoderType;
    httpOperation.cachePolicy = _cachePolicy;
    httpOperation.contentType = _contentType;
    httpOperation.timeoutInterval = _timeoutInterval;
}

- (BOOL)createFileSavePath:(nonnull NSString *)savePath {
    BOOL  result = YES;
    if(savePath != nil && savePath.length > 0){
        NSFileManager  * fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:savePath]){
            __autoreleasing NSError *error = nil;
            [fm createDirectoryAtPath:savePath
          withIntermediateDirectories:YES
                           attributes:@{NSFileProtectionKey : NSFileProtectionNone}
                                error:&error];
            if(error){
                result = NO;
            }
        }
    }else{
        result = NO;
    }
    return result;
}

#pragma mark - 上传文件私有方法

- (nullable NSString *)mimeTypeForFileAtPath:(nullable NSString *)path{
    if (![[NSFileManager defaultManager]fileExistsAtPath:path]) {
        return nil;
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    NSString *type = [(__bridge NSString *)MIMEType copy];
    CFRelease(UTI);
    CFRelease(MIMEType);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return type;
}

- (void)appendPostString:(nullable NSString *)string{
    if(_uploadPostData == nil){
        _uploadPostData = [NSMutableData data];
    }
    [_uploadPostData appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}


- (void)setPostParamDict:(nullable NSDictionary *)paramDict{
    
    if (paramDict == nil) {
        return;
    }
    if (_uploadParamArr == nil) {
        _uploadParamArr = [NSMutableArray array];
    }else{
        [_uploadParamArr removeAllObjects];
    }
    NSArray  * keyArr = paramDict.allKeys;
    if(keyArr){
        for (NSString * strKey in keyArr) {
            NSMutableDictionary *keyValuePair = [NSMutableDictionary dictionaryWithCapacity:2];
            [keyValuePair setValue:strKey forKey:@"key"];
            [keyValuePair setValue:[[paramDict objectForKey:strKey] description] forKey:@"value"];
            [_uploadParamArr addObject:keyValuePair];
        }
    }
}

- (void)appendPostData:(nullable NSData *)data{
    if ([data length] == 0) {
        return;
    }
    if(_uploadPostData == nil){
        _uploadPostData = [NSMutableData data];
    }
    [_uploadPostData appendData:data];
}

- (void)appendPostDataFromFile:(nullable NSString *)file {
    if(_uploadPostData == nil){
        _uploadPostData = [NSMutableData data];
    }
    NSFileManager  * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:file]){
        NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:file];
        [stream open];
        NSUInteger bytesRead;
        while ([stream hasBytesAvailable]) {
            unsigned char buffer[1024 * 256];
            bytesRead = [stream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead == 0) {
                break;
            }
            [_uploadPostData appendData:[NSData dataWithBytes:buffer length:bytesRead]];
        }
        [stream close];
    }
}

- (void)buildMultipartFormDataPostBody {
    if(_uploadParamArr == nil){
        _uploadParamArr = [NSMutableArray array];
    }
    NSString *stringBoundary = kUdeskWHCUploadCode;
    [self appendPostString:[NSString stringWithFormat:@"--%@\r\n",stringBoundary]];
    NSUInteger i = 0;
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    // 设置文件数据
    for (NSDictionary *val in _fileDataArr) {
        
        [self appendPostString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", val[@"key"], val[@"fileName"]]];
        [self appendPostString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", val[@"contentType"]]];
        
        id data = val[@"data"];
        if ([data isKindOfClass:[NSString class]]) {
            [self appendPostDataFromFile:data];
        } else {
            [self appendPostData:data];
        }
        [self appendPostString:@"\r\n"];
        i++;
        //添加分隔符在边界除了最后一个元素
        if (i != [_fileDataArr count]) {
            [self appendPostString:endItemBoundary];
        }
    }
    [self appendPostString:endItemBoundary];
    //设置普通参数
    i = 0;
    for (NSDictionary *val in _uploadParamArr) {
        [self appendPostString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",val[@"key"]]];
        [self appendPostString:val[@"value"]];
        [self appendPostString:@"\r\n"];
        i++;
        //添加分隔符在边界除了最后一个元素
        if (i != _uploadParamArr.count) {
            [self appendPostString:endItemBoundary];
        }
    }
    [self appendPostString:[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary]];
}

@end
