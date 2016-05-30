//
//  UdeskMessageContentView.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskMessage;
@class UdeskLabel;

@interface UdeskMessageContentView : UIView

/**
 *  目标消息Model对象
 */
@property (nonatomic, strong) UdeskMessage                            * message;

/**
 *  自定义显示文本消息控件
 */

@property (nonatomic, weak  ) UdeskLabel                              *textLabel;

/**
 *  用于显示气泡的ImageView控件
 */
@property (nonatomic, weak  ) UIImageView                          *bubbleImageView;

/**
 *  用于显示语音的控件，并且支持播放动画
 */
@property (nonatomic, weak  ) UIImageView                          *animationVoiceImageView;
/**
 *  发送中loading
 */
@property (nonatomic, weak  ) UIActivityIndicatorView              *indicatorView;
/**
 *  重发按钮
 */
@property (nonatomic, weak  ) UIButton                             *messageAgainButton;

/**
 *  用于显示语音时长的label
 */
@property (nonatomic, weak  ) UILabel                              *voiceDurationLabel;

/**
 *  图片
 */
@property (nonatomic, weak  ) UIImageView                          *photoImageView;

/**
 *  转移tag
 */
@property (nonatomic, weak  ) UILabel                              *redirectTagLabel;

/**
 *  初始化消息内容显示控件的方法
 *
 *  @param frame   目标Frame
 *  @param message 目标消息Model对象
 *
 *  @return 返回UDMessageBubbleView类型的对象
 */
- (instancetype)initWithFrame:(CGRect)frame
                      message:(UdeskMessage *)message;

/**
 *  获取气泡相对于父试图的位置
 *
 *  @return 返回气泡的位置
 */
- (CGRect)bubbleFrame;

/**
 *  根据消息Model对象配置消息显示内容
 *
 *  @param message 目标消息Model对象
 */
- (void)configureCellWithMessage:(UdeskMessage *)message;

/**
 *  根据消息Model对象计算消息内容的高度
 *
 *  @param message 目标消息Model对象
 *
 *  @return 返回所需高度
 */
+ (CGFloat)calculateCellHeightWithMessage:(UdeskMessage *)message;

@end
