//
//  UdeskInputBar.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskMessageTableView.h"
#import "UdeskAgent.h"
#import "UdeskHPGrowingTextView.h"

typedef NS_ENUM(NSUInteger, UDInputViewType) {
    UDInputViewTypeNormal = 0,
    UDInputViewTypeText,
    UDInputViewTypeEmotion,
    UDInputViewTypeVoice,
};

@protocol UdeskInputBarDelegate <NSObject>

/**
 *  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(UdeskHPGrowingTextView *)messageInputTextView;

/**
 *  选择图片
 *
 *  @param sourceType 相册or相机
 */
- (void)sendImageWithSourceType:(UIImagePickerControllerSourceType)sourceType;
/**
 *  点击UDMessageInputView相应事件
 */
- (void)didUDMessageInputView;
/**
 *  发送文本消息，包括系统的表情
 *
 *  @param text 目标文本消息
 */
- (void)didSendTextAction:(NSString *)text;
/**
 *  显示表情
 */
- (void)didSelectEmotionButton:(BOOL)selected;
/**
 *  点击语音
 */
- (void)didSelectVoiceButton:(BOOL)selected;
/**
 *  评价成功
 */
- (void)didSurveyWithMessage:(NSString *)message hasSurvey:(BOOL)hasSurvey;

@end

@interface UdeskInputBar : UIView

@property (nonatomic, strong) UdeskAgent *agent;

@property (nonatomic, strong) UdeskHPGrowingTextView *inputTextView;

@property (nonatomic, weak) id <UdeskInputBarDelegate> delegate;

@property (nonatomic, strong) NSNumber *enableImSurvey;

- (instancetype)initWithFrame:(CGRect)frame
                    tableView:(UdeskMessageTableView *)tabelView;

//离线留言不显示任何功能按钮
- (void)updateInputBarForLeaveMessage;

@end
