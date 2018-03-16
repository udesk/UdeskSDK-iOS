//
//  WHC_HttpOperation.m
//  WHCNetWorkKit
//
//  Created by 吴海超 on 15/11/6.
//  Copyright © 2015年 吴海超. All rights reserved.
//

#import "Udesk_WHC_HttpOperation.h"
#import "Udesk_WHC_HttpManager.h"
@interface Udesk_WHC_HttpOperation ()  {
    
}

@end

@implementation Udesk_WHC_HttpOperation

#pragma mark - 重写操作方法 -

- (void)start {
    [super start];
    [self startRequest];
}

- (void)cancelledRequest{
    [super cancelledRequest];
}

#pragma mark - 实现网络代理方法 -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (![self handleResponseError:response]) {
        NSHTTPURLResponse  *  headerResponse = (NSHTTPURLResponse *)response;
        NSDictionary * fields = [headerResponse allHeaderFields];
        NSString * newCookie = fields[@"Set-Cookie"];
        if (newCookie) {
            if([Udesk_WHC_HttpManager shared].cookie == nil){
                [Udesk_WHC_HttpManager shared].cookie = newCookie.copy;
            }else if ([Udesk_WHC_HttpManager shared].cookie != newCookie){
                [Udesk_WHC_HttpManager shared].cookie = nil;
                [Udesk_WHC_HttpManager shared].cookie = newCookie.copy;
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    if (self.requestType == Udesk_WHCHttpRequestGet) {
        self.recvDataLenght += data.length;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressBlock) {
                self.progressBlock(self, self.recvDataLenght , self.responseDataLenght , self.networkSpeed);
            }
        });
    }
}

- (void)connection:(NSURLConnection *)connection
           didSendBodyData:(NSInteger)bytesWritten
         totalBytesWritten:(NSInteger)totalBytesWritten
        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    if (self.requestType == Udesk_WHCHttpRequestFileUpload) {
        [self startSpeedTimer];
        self.orderTimeDataLenght += bytesWritten;
        self.recvDataLenght += bytesWritten;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressBlock) {
                self.progressBlock(self, self.recvDataLenght , totalBytesWritten , self.networkSpeed);
            }
        });
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didFinishedBlock) {
            self.didFinishedBlock(self ,self.responseData , nil, YES);
         }
        self.didFinishedBlock = nil;
    });
    [self cancelledRequest];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.delegate = nil;
    [self cancelledRequest];
    [self handleReqeustError:error code:Udesk_WHCGeneralError];
}

@end
