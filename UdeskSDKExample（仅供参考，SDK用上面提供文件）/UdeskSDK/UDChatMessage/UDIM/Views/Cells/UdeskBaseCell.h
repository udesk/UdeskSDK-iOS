//
//  UdeskBaseCell.h
//  UdeskSDK
//
//  Created by xuchen on 16/8/17.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

//通知重发消息
#define UdeskClickResendMessage   @"UdeskClickResendMessage"

@protocol UdeskCellDelegate <NSObject>

- (void)didSelectImageCell;

- (void)sendProductURL:(NSString *)url;

@end

@interface UdeskBaseCell : UITableViewCell

@property (nonatomic, weak) id<UdeskCellDelegate> delegate;

- (void)updateCellWithMessage:(id)message;

@end
