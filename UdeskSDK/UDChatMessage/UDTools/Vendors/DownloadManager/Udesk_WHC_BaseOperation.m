//
//  WHC_BaseOperation.m
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

#import "Udesk_WHC_BaseOperation.h"
#import "Udesk_WHC_HttpManager.h"

NSTimeInterval const kUdeskWHCRequestTimeout = 30;
NSTimeInterval const kUdeskWHCDownloadSpeedDuring = 1.5;
CGFloat        const kUdeskWHCWriteSizeLenght = 1024 * 1024;
NSString  * const  kUdeskWHCDomain = @"WHC_HTTP_OPERATION";
NSString  * const  kUdeskWHCInvainUrlError = @"无效的url:%@";
NSString  * const  kUdeskWHCCalculateFolderSpaceAvailableFailError = @"计算文件夹存储空间失败";
NSString  * const  kUdeskWHCErrorCode = @"错误码:%ld";
NSString  * const  kUdeskWHCFreeDiskSapceError = @"磁盘可用空间不足需要存储空间:%llu";
NSString  * const  kUdeskWHCRequestRange = @"bytes=%lld-";
NSString  * const  kUdeskWHCUploadCode = @"WHC";

@interface Udesk_WHC_BaseOperation () {
    NSTimer * _speedTimer;
}

@end

@implementation Udesk_WHC_BaseOperation

#pragma mark - 重写属性方法 -
- (void)setStrUrl:(NSString *)strUrl {
    _strUrl = strUrl.copy;
    NSString * newUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                              (CFStringRef)_strUrl,
                                                                                              (CFStringRef)@"!$&'()*-,-./:;=?@_~%#[]",
                                                                                              NULL,
                                                                                              kCFStringEncodingUTF8));
    _urlRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:newUrl]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutInterval = kUdeskWHCRequestTimeout;
        _requestType = Udesk_WHCHttpRequestGet;
        _requestStatus = Udesk_WHCHttpRequestNone;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _responseData = [NSMutableData data];
    }
    return self;
}

- (void)dealloc{
    [self cancelledRequest];
}


#pragma mark - 重写队列操作方法 -

- (void)start {
    if ([NSURLConnection canHandleRequest:self.urlRequest]) {
        self.urlRequest.timeoutInterval = self.timeoutInterval;
        self.urlRequest.cachePolicy = self.cachePolicy;
        [_urlRequest setValue:self.contentType forHTTPHeaderField: @"Content-Type"];
        switch (self.requestType) {
            case Udesk_WHCHttpRequestGet:
            case Udesk_WHCHttpRequestFileDownload:{
                [_urlRequest setHTTPMethod:@"GET"];
            }
                break;
            case Udesk_WHCHttpRequestPost:
            case Udesk_WHCHttpRequestFileUpload:{
                [_urlRequest setHTTPMethod:@"POST"];
                if([Udesk_WHC_HttpManager shared].cookie && [Udesk_WHC_HttpManager shared].cookie.length > 0) {
                    [_urlRequest setValue:[Udesk_WHC_HttpManager shared].cookie forHTTPHeaderField:@"Cookie"];
                }
                if (self.postParam != nil) {
                    NSData * paramData = nil;
                    if ([self.postParam isKindOfClass:[NSData class]]) {
                        paramData = (NSData *)self.postParam;
                    }else if ([self.postParam isKindOfClass:[NSString class]]) {
                        paramData = [((NSString *)self.postParam) dataUsingEncoding:self.encoderType allowLossyConversion:YES];
                    }
                    if (paramData) {
                        [_urlRequest setHTTPBody:paramData];
                        [_urlRequest setValue:[NSString stringWithFormat:@"%zd", paramData.length] forHTTPHeaderField: @"Content-Length"];
                    }
                }
            }
                break;
            default:
                break;
        }
        if(self.urlConnection == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            });
            self.urlConnection = [[NSURLConnection alloc]initWithRequest:_urlRequest delegate:self startImmediately:NO];
        }
    }else {
        [self handleReqeustError:nil code:Udesk_WHCGeneralError];
    }
}

- (BOOL)isExecuting {
    return _requestStatus == Udesk_WHCHttpRequestExecuting;
}

- (BOOL)isCancelled {
    return _requestStatus == Udesk_WHCHttpRequestCanceled ||
    _requestStatus == Udesk_WHCHttpRequestFinished;
}

- (BOOL)isFinished {
    return _requestStatus == Udesk_WHCHttpRequestFinished;
}

- (BOOL)isConcurrent{
    return YES;
}


#pragma mark - 公共方法 -

- (void)calculateNetworkSpeed {
    float downloadSpeed = (float)_orderTimeDataLenght / (kUdeskWHCDownloadSpeedDuring * 1024.0);
    _networkSpeed = [NSString stringWithFormat:@"%.1fKB/s", downloadSpeed];
    if (downloadSpeed >= 1024.0) {
        downloadSpeed = ((float)_orderTimeDataLenght / 1024.0) / (kUdeskWHCDownloadSpeedDuring * 1024.0);
        _networkSpeed = [NSString stringWithFormat:@"%.1fMB/s",downloadSpeed];
    }
    _orderTimeDataLenght = 0;
}


- (void)clearResponseData {
    [self.responseData resetBytesInRange:NSMakeRange(0, self.responseData.length)];
    [self.responseData setLength:0];
}

- (void)startRequest {
    NSRunLoop * urnLoop = [NSRunLoop currentRunLoop];
    [_urlConnection scheduleInRunLoop:urnLoop forMode:NSDefaultRunLoopMode];
    [self willChangeValueForKey:@"isExecuting"];
    _requestStatus = Udesk_WHCHttpRequestExecuting;
    [self didChangeValueForKey:@"isExecuting"];
    [_urlConnection start];
    [urnLoop run];
}

- (void)addDependOperation:(Udesk_WHC_BaseOperation *)operation {
    [self addDependency:operation];
}

- (void)startSpeedTimer {
    if (!_speedTimer && (_requestType == Udesk_WHCHttpRequestFileUpload ||
                         _requestType == Udesk_WHCHttpRequestFileDownload ||
                         _requestType == Udesk_WHCHttpRequestGet)) {
        _speedTimer = [NSTimer scheduledTimerWithTimeInterval:kUdeskWHCDownloadSpeedDuring
                                                       target:self
                                                     selector:@selector(calculateNetworkSpeed)
                                                     userInfo:nil
                                                      repeats:YES];
        [self calculateNetworkSpeed];
    }
}

- (BOOL)handleResponseError:(NSURLResponse * )response {
    BOOL isError = NO;
    NSHTTPURLResponse  *  headerResponse = (NSHTTPURLResponse *)response;
    if(headerResponse.statusCode >= 400){
        isError = YES;
        self.requestStatus = Udesk_WHCHttpRequestFinished;
        if (self.requestType != Udesk_WHCHttpRequestFileDownload) {
            [self cancelledRequest];
            NSError * error = [NSError errorWithDomain:kUdeskWHCDomain
                                                  code:Udesk_WHCGeneralError
                                              userInfo:@{NSLocalizedDescriptionKey:
                                                             [NSString stringWithFormat:kUdeskWHCErrorCode,
                                                              (long)headerResponse.statusCode]}];
            NSLog(@"UdeskSDK：%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.didFinishedBlock) {
                    self.didFinishedBlock(self, nil , error , NO);
                    self.didFinishedBlock = nil;
                }else if (self.delegate &&
                          [self.delegate respondsToSelector:@selector(WHCDownloadDidFinished:data:error:success:)]) {
                    if (headerResponse.statusCode == 404) {
                        [[Udesk_WHC_HttpManager shared].failedUrls addObject: self.strUrl];
                    }
                    [self.delegate WHCDownloadDidFinished:(Udesk_WHC_DownloadOperation *)self data:nil error:error success:NO];
                }
            });
        }
    }else {
        _responseDataLenght = headerResponse.expectedContentLength;
        [self startSpeedTimer];
    }
    return isError;
}

- (void)endRequest {
    self.didFinishedBlock = nil;
    self.progressBlock = nil;
    [self cancelledRequest];
}

- (void)cancelledRequest{
    if (_urlConnection) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        _requestStatus = Udesk_WHCHttpRequestFinished;
        [self willChangeValueForKey:@"isCancelled"];
        [self willChangeValueForKey:@"isFinished"];
        [_urlConnection cancel];
        _urlConnection = nil;
        [self didChangeValueForKey:@"isCancelled"];
        [self didChangeValueForKey:@"isFinished"];
        if (_requestType == Udesk_WHCHttpRequestFileUpload ||
            _requestType == Udesk_WHCHttpRequestFileDownload) {
            if (_speedTimer) {
                [_speedTimer invalidate];
                [_speedTimer fire];
                _speedTimer = nil;
            }
        }
    }
}

- (void)handleReqeustError:(NSError *)error code:(NSInteger)code {
    if(error == nil){
        error = [[NSError alloc]initWithDomain:kUdeskWHCDomain
                                          code:code
                                      userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:kUdeskWHCInvainUrlError,self.strUrl]}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didFinishedBlock) {
            self.didFinishedBlock (self, nil, error , NO);
            self.didFinishedBlock = nil;
        }else if (self.delegate &&
                  [self.delegate respondsToSelector:@selector(WHCDownloadDidFinished:data:error:success:)]) {
            [self.delegate WHCDownloadDidFinished:(Udesk_WHC_DownloadOperation *)self data:nil error:error success:NO];
        }
    });
    
}

@end
