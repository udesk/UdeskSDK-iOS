//
//  UdeskCallManager.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/18.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UdeskMessage;
@class UdeskSetting;
@class UdeskAgent;

@interface UdeskCallManager : NSObject

@property (nonatomic, copy) void(^didSendMessageBlock)(UdeskMessage *message);

- (instancetype)initWithSetting:(UdeskSetting *)sdkSetting;

//配置视频通话
- (void)configUdeskCallWithCustomerJID:(NSString *)customerJID agentModel:(UdeskAgent *)agentModel;
//关闭视频铃声
- (void)stopPlayVideoCallRing;
//开始视频通话
- (void)startUdeskVideoCall;

@end
