//
//  UDChatViewController.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UDMessageTableViewCell;
@class UDMessageTableView;
@class UDMessageInputView;
@class UDMessageTextView;
@class UDEmotionManagerView;
@class UDVoiceRecordHUD;
@class UDVoiceRecordHelper;
@class UDPhotographyHelper;
@class UDAgentStatusView;
@class UDAgentViewModel;
@class UDChatViewController;
@class UDChatViewModel;
@class UDChatCellViewModel;
@class UDChatDataController;

@interface UDChatViewController : UIViewController

/**
 *  用于显示消息的TableView
 */
@property (nonatomic, weak) UDMessageTableView *messageTableView;

/**
 *  用于显示发送消息类型控制的工具条，在底部
 */
@property (nonatomic, weak) UDMessageInputView *messageInputView;

@property (nonatomic, weak  ) UDAgentStatusView    *agentStatusView;

/**
 *  管理录音工具对象
 */
@property (nonatomic, strong) UDVoiceRecordHelper *voiceRecordHelper;

/**
 *  语音录制动画
 */
@property (nonatomic, strong) UDVoiceRecordHUD *voiceRecordHUD;
/**
 *  管理表情的控件
 */
@property (nonatomic, strong) UDEmotionManagerView *emotionManagerView;

/**
 *  管理本机的摄像和图片库的工具对象
 */
@property (nonatomic, strong) UDPhotographyHelper *photographyHelper;

/**
 *  分贝的定时器
 */
@property (nonatomic, assign) NSTimer *recordTimer;

/**
 *  计算语音时间的定时器
 */
@property (nonatomic, assign) NSTimer *playTimer;

/**
 *  语音时间
 */
@property (nonatomic, assign) NSInteger playTime;

/**
 *  记录是否同意语音
 */
@property (nonatomic, assign) BOOL agreeVoice;

/**
 *  判断是不是超出了录音最大时长
 */
@property (nonatomic, assign) BOOL isMaxTimeStop;
/**
 *  UDChatViewController 数据源
 */
@property (nonatomic, strong) UDChatDataController *dataController;
/**
 *  ChatViewModel
 */
@property (nonatomic, strong) UDChatViewModel      *chatViewModel;
/**
 *  TableViewCellModel
 */
@property (nonatomic, strong) UDChatCellViewModel  *chatCellViewModel;

@property (nonatomic, strong) UDAgentViewModel     *agentViewModel;

@end
