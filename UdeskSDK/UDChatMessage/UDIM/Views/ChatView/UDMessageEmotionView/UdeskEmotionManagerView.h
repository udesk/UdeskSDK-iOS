//
//  UdeskEmotionManagerView.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UDEmotionManagerViewDelegate <NSObject>

@optional
/**
 *  点击表情
 */
-(void)emojiViewDidSelectEmoji:(NSString *)emoji;

/**
 *  删除表情
 */
-(void)emojiViewDidPressDeleteButton:(UIButton *)deletebutton;
/**
 *  发送按钮
 */
- (void)didEmotionViewSendAction;

@end


@interface UdeskEmotionManagerView : UIView

@property (nonatomic, weak) id <UDEmotionManagerViewDelegate> delegate;


@end
