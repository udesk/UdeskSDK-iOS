//
//  UdeskMessageInputView.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskMessageTableView;
@class UdeskMessageTextView;

@protocol UDMessageInputViewDelegate <NSObject>

@required

/**
 *  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(UdeskMessageTextView *)messageInputTextView;

/**
 *  选择图片
 *
 *  @param sourceType 相册or相机
 */
- (void)sendImageWithSourceType:(UIImagePickerControllerSourceType)sourceType;

@optional

/**
 *  点击UDMessageInputView相应事件
 */
- (void)didUDMessageInputView;

/**
 *  在发送文本和语音之间发送改变时，会触发这个回调函数
 *
 *  @param changed 是否改为发送语音状态
 */
- (void)didChangeSendVoiceAction:(BOOL)changed;

/**
 *  发送文本消息，包括系统的表情
 *
 *  @param text 目标文本消息
 */
- (void)didSendTextAction:(NSString *)text;

/**
 *  点击+号按钮Action
 */
- (void)didSelectedMultipleMediaAction;
/**
 *  按下錄音按鈕 "準備" 錄音
 */
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion;

/**
 *  开始录音
 */
- (void)didStartRecordingVoiceAction;
/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction;
/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction;
/**
 *  当手指离开按钮的范围内时，主要为了通知外部的HUD
 */
- (void)didDragOutsideAction;
/**
 *  当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
 */
- (void)didDragInsideAction;

/**
 *  显示表情
 *
 *  @param facePath 目标表情的本地路径
 */
- (void)didSendFaceAction:(BOOL)sendFace;

@end

@interface UdeskMessageInputView : UIImageView

@property (nonatomic, weak) id <UDMessageInputViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                    tableView:(UdeskMessageTableView *)tabelView;

/**
 *  用于输入文本消息的输入框
 */
@property (nonatomic, weak) UdeskMessageTextView *inputTextView;

/**
 *  切换文本和语音的按钮
 */
@property (nonatomic, weak) UIButton *voiceChangeButton;

/**
 *  +号按钮
 */
@property (nonatomic, weak) UIButton *multiMediaSendButton;

/**
 *  第三方表情按钮
 */
@property (nonatomic, weak) UIButton *faceSendButton;

/**
 *  语音录制按钮
 */
@property (nonatomic, weak) UIButton *holdDownButton;

@property (nonatomic, strong) NSNumber *agentCode;

/**
 *  在切换语音和文本消息的时候，需要保存原本已经输入的文本，这样达到一个好的UE
 */
@property (nonatomic, copy) NSString *inputedText;

#pragma mark - Message input view

/**
 *  动态改变高度
 *
 *  @param changeInHeight 目标变化的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

/**
 *  获取最大行数
 *
 *  @return 返回最大行数
 */
+ (CGFloat)maxLines;

/**
 *  获取根据最大行数和每行高度计算出来的最大显示高度
 *
 *  @return 返回最大显示高度
 */
+ (CGFloat)maxHeight;



@end
