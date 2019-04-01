//
//  UdeskSetting.h
//  UdeskSDK
//
//  Created by Udesk on 2017/1/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskSetting : NSObject

/** 是否支持转移 */
@property (nonatomic, strong, readonly) NSNumber *enableAgent;
/** 是否支持客服导航栏 */
@property (nonatomic, strong, readonly) NSNumber *enableImGroup;
/** 是否支持机器人 */
@property (nonatomic, strong, readonly) NSNumber *enableRobot;
/** 是否支持留言 */
@property (nonatomic, strong, readonly) NSNumber *enableWebImFeedback;
/** 是否正在会话 */
@property (nonatomic, strong, readonly) NSNumber *inSession;
/** 是否在工作时间 */
@property (nonatomic, strong, readonly) NSNumber *isWorktime;
/** 留言文案 */
@property (nonatomic, copy  , readonly) NSString *noReplyHint;
/** 机器人URL */
@property (nonatomic, copy  , readonly) NSString *robotURL;
/** 留言类型 msg、form */
@property (nonatomic, copy  , readonly) NSString *leaveMessageType;
/** 返回弹出留言 */
@property (nonatomic, strong, readonly) NSNumber *investigationWhenLeave;
/** 是否开启了满意度调查 */
@property (nonatomic, strong, readonly) NSNumber *enableImSurvey;
/** 公司是否开启了视频功能 */
@property (nonatomic, strong, readonly) NSNumber *vCall;
/** SDK是否开启了视频功能 */
@property (nonatomic, strong, readonly) NSNumber *sdkVCall;
/** 视频通话appid */
@property (nonatomic, copy  , readonly) NSString *vcAppId;
/** agora appid */
@property (nonatomic, copy  , readonly) NSString *agoraAppId;
/** socket */
@property (nonatomic, copy  , readonly) NSString *serverURL;
/** 获取tokenURL */
@property (nonatomic, copy  , readonly) NSString *vCallTokenURL;
/** 直接留言引导文案 */
@property (nonatomic, copy  , readonly) NSString *leaveMessageGuide;
/** 客户需要发送的条数才转人工 */
@property (nonatomic, copy  , readonly) NSString *showRobotTimes;
/** 机器人名称 */
@property (nonatomic, copy  , readonly) NSString *robotName;
/** 无消息标题 */
@property (nonatomic, copy  , readonly) NSString *preSessionTitle;
/** 无消息对话过滤ID */
@property (nonatomic, strong, readonly) NSNumber *preSessionId;
/** 无消息对话过滤 */
@property (nonatomic, strong, readonly) NSNumber *showPreSession;
/** 图片请求头 */
@property (nonatomic, copy  , readonly) NSString *referer;
/** 是否在黑名单 */
@property (nonatomic, strong, readonly) NSNumber *isBlocked;
/** 黑名单提示语 */
@property (nonatomic, copy  , readonly) NSString *blackListNotice;
/** 会话状态（chatting|queuing|pre_session|init） */
@property (nonatomic, copy  , readonly) NSString *status;

/**
 *  JSON数据转换成UdeskSetting
 *
 *  @param json json数据
 */
- (instancetype)initModelWithJSON:(id)json;

@end
