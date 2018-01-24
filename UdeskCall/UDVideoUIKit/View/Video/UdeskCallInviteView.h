//
//  UdeskCallInviteView.h
//  UdeskSDK
//
//  Created by xuchen on 2017/12/12.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskCallInviteView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *avatarView;
@property (strong, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UIButton *declineButton;
@property (strong, nonatomic) IBOutlet UILabel *declineLabel;
@property (strong, nonatomic) IBOutlet UIButton *answerButton;
@property (strong, nonatomic) IBOutlet UILabel *answerLabel;

@property (nonatomic, copy  ) NSString *avatarURL;
@property (nonatomic, copy  ) NSString *nickName;

@property (nonatomic, copy) void(^callEndedBlock)(void);

+ (UdeskCallInviteView *)instanceCallInviteView;

@end
