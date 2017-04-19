//
//  UdeskBaseCell.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/17.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

//通知重发消息
#define UdeskClickResendMessage   @"UdeskClickResendMessage"

@protocol UdeskCellDelegate <NSObject>

- (void)didSelectImageCell;

- (void)sendProductURL:(NSString *)url;

- (void)didSelectStructButton;

@end

@interface UdeskBaseCell : UITableViewCell

@property (nonatomic, weak) id<UdeskCellDelegate> delegate;

- (void)updateCellWithMessage:(id)message;

@end
