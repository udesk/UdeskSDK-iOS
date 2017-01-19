//
//  UdeskSetting.h
//  UdeskSDK
//
//  Created by xuchen on 2017/1/18.
//  Copyright © 2017年 xuchen. All rights reserved.
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
@property (nonatomic, strong, readonly) NSString *noReplyHint;
/** 机器人URL */
@property (nonatomic, strong, readonly) NSString *robot;

/**
 *  JSON数据转换成UdeskSetting
 *
 *  @param json json数据
 */
- (instancetype)initModelWithJSON:(id)json;

@end
