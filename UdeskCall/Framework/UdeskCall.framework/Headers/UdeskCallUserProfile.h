//
//  UdeskCallUserProfile.h
//  UdeskSDK
//
//  Created by xuchen on 2017/12/12.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskCallUserProfile : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *channelId;

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *resId;

@property (nonatomic, copy) NSString *toUserId;
@property (nonatomic, copy) NSString *toResId;

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *subdomain;
@property (nonatomic, assign) NSInteger bizSessionId;

@property (nonatomic, copy) NSString *agoraAppId;
@property (nonatomic, copy) NSString *serverURL;
@property (nonatomic, copy) NSString *vCallTokenURL;

- (instancetype)initWithAppId:(NSString *)appId
                    subdomain:(NSString *)subdomain
                 bizSessionId:(NSInteger)bizSessionId;

@end
