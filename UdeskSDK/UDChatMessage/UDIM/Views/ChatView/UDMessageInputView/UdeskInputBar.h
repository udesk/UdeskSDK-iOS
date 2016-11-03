//
//  UdeskInputBar.h
//  UdeskSDK
//
//  Created by xuchen on 16/8/23.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskMessageTableView.h"
#import "UdeskAgent.h"
#import "UdeskTextView.h"

@protocol UdeskInputBarDelegate <NSObject>

/**
 *  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(UdeskTextView *)messageInputTextView;

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

@property (nonatomic, strong) UdeskTextView *inputTextView;//输入框

@property (nonatomic, weak) id <UdeskInputBarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                    tableView:(UdeskMessageTableView *)tabelView;

@end
