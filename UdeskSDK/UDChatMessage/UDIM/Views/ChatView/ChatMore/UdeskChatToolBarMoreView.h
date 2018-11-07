//
//  UdeskChatToolBarMoreView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/20.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskChatToolBarMoreView;

typedef NS_ENUM(NSUInteger, UdeskChatToolBarMoreType) {
    UdeskChatToolBarMoreTypeAlubm,      //相册
    UdeskChatToolBarMoreTypeCamera,     //相机
    UdeskChatToolBarMoreTypeLocation,   //地理位置
    UdeskChatToolBarMoreTypeSurvey,     //评价
    UdeskChatToolBarMoreTypeVideoCall,  //视频通话
};

@protocol UdeskChatToolBarMoreViewDelegate <NSObject>

@optional
- (void)didSelectMoreMenuItem:(UdeskChatToolBarMoreView *)moreMenuItem itemType:(UdeskChatToolBarMoreType)itemType;
- (void)didSelectCustomMoreMenuItem:(UdeskChatToolBarMoreView *)moreMenuItem atIndex:(NSInteger)index;

@end

@interface UdeskChatToolBarMoreView : UIView

@property (nonatomic, strong) NSArray *customMenuItems;
@property (nonatomic, weak  ) id<UdeskChatToolBarMoreViewDelegate> delegate;
@property (nonatomic, assign) BOOL isPreSessionMessage;
@property (nonatomic, assign) BOOL isQueue;

- (instancetype)initWithEnableSurvey:(BOOL)enableSurvey enableVideoCall:(BOOL)enableVideoCall;

@end
