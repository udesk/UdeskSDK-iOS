//
//  UDChatCellViewModel.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/20.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UDMessageTableViewCell;
@class UDMessageInputView;
@class UDMessage;

@interface UDChatCellViewModel : NSObject

/**
 *  消息点击事件处理
 *
 *  @param message              点击的Message
 *  @param indexPath            点击的indexPath
 *  @param messageTableViewCell 点击的messageTableViewCell
 */
- (void)didSelectedOnMessage:(UDMessage *)message
                   indexPath:(NSIndexPath *)indexPath
            messageInputView:(UDMessageInputView *)inputView
        messageTableViewCell:(UDMessageTableViewCell *)messageTableViewCell;

@end
