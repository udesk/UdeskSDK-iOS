//
//  UDStatus.h
//  UdeskSDK
//
//  Created by Mac开发机 on 2016/12/28.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDStatus : NSObject

+ (UDStatus *)shareInstance;

/**
 * type 1 has app_id | 0 no app_id
 */
- (void)requestData:(void(^)(NSInteger type, UDStatus *status))requestCallBack;

@property (nonatomic, assign, readonly) BOOL enable_agent;
@property (nonatomic, assign, readonly) BOOL enable_im_group;
@property (nonatomic, assign, readonly) BOOL enable_robot;
@property (nonatomic, assign, readonly) BOOL enable_sdk_robot;
@property (nonatomic, assign, readonly) BOOL enable_web_im_feedback;
@property (nonatomic, assign, readonly) BOOL has_robot;
@property (nonatomic, assign, readonly) BOOL in_session;
@property (nonatomic, assign, readonly) BOOL is_worktime;
@property (nonatomic, copy, readonly) NSString *no_reply_hint;
@property (nonatomic, copy, readonly) NSString *robot;


- (void)quiteQueue:(void(^)(NSInteger type, UDStatus *status))result;




@end
