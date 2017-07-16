//
//  UdeskSDKManager.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskSDKManager.h"
#import "UdeskChatViewController.h"
#import "UdeskTransitioningAnimation.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskFoundationMacro.h"
#import "UdeskRobotViewController.h"
#import "UdeskFAQViewController.h"
#import "UdeskAgentMenuViewController.h"
#import "UdeskTicketViewController.h"
#import "UdeskSDKShow.h"

@interface UdeskSDKManager()

@end

@implementation UdeskSDKManager{
    UdeskChatViewController *chatViewController;
    UdeskRobotViewController *robotChat;
    UdeskFAQViewController *faq;
    UdeskAgentMenuViewController *agentMenu;
    UdeskTicketViewController *ticket;
    UdeskSDKConfig *_sdkConfig;
    UdeskSDKShow *_show;
}

+ (instancetype)managerWithSDKStyle:(UdeskSDKStyle *)style
{
    return [[self alloc] initWithSDKStyle:style];
}

- (instancetype)initWithSDKStyle:(UdeskSDKStyle *)style
{
    self = [super init];
    if (self) {
        
        _sdkConfig = [UdeskSDKConfig sharedConfig];
        _sdkConfig.sdkStyle = style;
        _show = [[UdeskSDKShow alloc] initWithConfig:_sdkConfig];
    }
    return self;
}

//push-setting
- (void)pushUdeskInViewController:(UIViewController *)viewController
                       completion:(void (^)(void))completion {

    //根据后台配置
    [self presentUdeskViewController:viewController transiteAnimation:UDTransiteAnimationTypePush completion:completion];
}

//present-setting
- (void)presentUdeskInViewController:(UIViewController *)viewController
                          completion:(void (^)(void))completion {
    
    //根据后台配置
    [self presentUdeskViewController:viewController transiteAnimation:UDTransiteAnimationTypePresent completion:completion];
}

- (void)pushUdeskInViewController:(UIViewController *)viewController
                        udeskType:(UdeskType)udeskType
                       completion:(void (^)(void))completion {

    [self customPresentViewController:viewController udeskType:udeskType transiteAnimation:UDTransiteAnimationTypePush completion:completion];
}

- (void)presentUdeskInViewController:(UIViewController *)viewController
                           udeskType:(UdeskType)udeskType
                          completion:(void (^)(void))completion {
    
    [self customPresentViewController:viewController udeskType:udeskType transiteAnimation:UDTransiteAnimationTypePresent completion:completion];
}

- (void)customPresentViewController:(UIViewController *)viewController
                          udeskType:(UdeskType)udeskType
                  transiteAnimation:(UDTransiteAnimationType)animationType
                         completion:(void (^)(void))completion {
    
    switch (udeskType) {
        case UdeskIM:
            [self presentIMController:viewController transiteAnimation:animationType sdkSetting:nil completion:completion];
            break;
        case UdeskFAQ:
            [self presentFAQController:viewController transiteAnimation:animationType completion:completion];
            break;
        case UdeskTicket:
            [self presentTicketController:viewController transiteAnimation:animationType completion:completion];
            break;
            
        default:
            break;
    }
}

//根据后台配置
- (void)presentUdeskViewController:(UIViewController *)viewController
                 transiteAnimation:(UDTransiteAnimationType)animationType
                        completion:(void (^)(void))completion {

    //根据后台配置
    [UdeskManager getServerSDKSetting:^(UdeskSetting *setting) {
        
        //容错处理
        if (!setting.inSession || !setting.enableRobot || !setting.enableImGroup) {
            
            [self presentIMController:viewController transiteAnimation:animationType sdkSetting:setting completion:completion];
            return ;
        }
        
        //客户正在会话
        if (setting.inSession.boolValue) {
            [self presentIMController:viewController transiteAnimation:animationType sdkSetting:setting completion:completion];
            return ;
        }
        
        //开通机器人
        if (setting.enableRobot.boolValue) {
            [self presentRobotController:viewController transiteAnimation:animationType sdkSetting:setting completion:completion];
            return ;
        }
        
        //开通客户导航栏
        if (setting.enableImGroup.boolValue) {
            [self presentMenuController:viewController transiteAnimation:animationType sdkSetting:setting completion:completion];
            return ;
        }
        
        [self presentIMController:viewController transiteAnimation:animationType sdkSetting:setting completion:completion];
        
    } failure:^(NSError *error) {
        
        [self presentIMController:viewController transiteAnimation:animationType sdkSetting:nil completion:completion];
    }];
}

//推到聊天页面
- (void)presentIMController:(UIViewController *)viewController
          transiteAnimation:(UDTransiteAnimationType)animationType
                 sdkSetting:(UdeskSetting *)setting
                 completion:(void (^)(void))completion {
    
    if (!chatViewController) {
        chatViewController = [[UdeskChatViewController alloc] initWithSDKConfig:_sdkConfig withSettings:setting];
    }
    
    [_show presentOnViewController:viewController udeskViewController:chatViewController transiteAnimation:animationType completion:completion];
}

//推到机器人页面
- (void)presentRobotController:(UIViewController *)viewController
             transiteAnimation:(UDTransiteAnimationType)animationType
                    sdkSetting:(UdeskSetting *)setting
                    completion:(void (^)(void))completion {
    
    //如果选择了配置
    if (setting) {
        
        NSURL *url = [UdeskManager getServerRobotURLWithBaseURL:setting.robot];
        if (!robotChat) {
            robotChat = [[UdeskRobotViewController alloc] initWithSDKConfig:_sdkConfig withURL:url withSetting:setting];
        }
        [_show presentOnViewController:viewController udeskViewController:robotChat transiteAnimation:animationType completion:completion];
    }
}

//推到帮助中心页面
- (void)presentFAQController:(UIViewController *)viewController
           transiteAnimation:(UDTransiteAnimationType)animationType
                  completion:(void (^)(void))completion {
    
    
    if (!faq) {
        faq = [[UdeskFAQViewController alloc] initWithSDKConfig:_sdkConfig];
    }
    
    [_show presentOnViewController:viewController udeskViewController:faq transiteAnimation:animationType completion:completion];
}

//推到留言页面
- (void)presentTicketController:(UIViewController *)viewController
              transiteAnimation:(UDTransiteAnimationType)animationType
                     completion:(void (^)(void))completion {
    
    if (!ticket) {
        ticket = [[UdeskTicketViewController alloc] initWithSDKConfig:_sdkConfig];
    }
    [viewController presentViewController:ticket animated:YES completion:nil];
}

//推到客服导航栏页面
- (void)presentMenuController:(UIViewController *)viewController
           transiteAnimation:(UDTransiteAnimationType)animationType
                   sdkSetting:(UdeskSetting *)setting
                  completion:(void (^)(void))completion {
    
    //查看是否有导航栏
    [UdeskManager getAgentNavigationMenu:^(id responseObject, NSError *error) {
        
        @try {
            
            //查看导航栏错误，直接进入聊天页面
            if (error) {
                [self presentIMController:viewController transiteAnimation:animationType sdkSetting:setting completion:completion];
                return ;
            }
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                
                NSArray *result = [responseObject objectForKey:@"result"];
                //有设置客服导航栏
                if (result.count) {
                    
                    if (!agentMenu) {
                        agentMenu = [[UdeskAgentMenuViewController alloc] initWithSDKConfig:_sdkConfig menuArray:result withSetting:setting];
                    }
                    
                    [_show presentOnViewController:viewController udeskViewController:agentMenu transiteAnimation:animationType completion:completion];
                }
                else {
                    //没有设置导航栏 直接进入聊天页面
                    [self presentIMController:viewController transiteAnimation:animationType sdkSetting:setting completion:completion];
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }];

}

- (void)setScheduledAgentId:(NSString *)agentId {
	
    if (!agentId) {
        return;
    }
    _sdkConfig.scheduledAgentId = agentId;
}

- (void)setScheduledGroupId:(NSString *)groupId {
	
    if (!groupId) {
        return;
    }
    _sdkConfig.scheduledGroupId = groupId;
}

- (void)setProductMessage:(NSDictionary *)product {

    _sdkConfig.productDictionary = product;
}

- (void)setCustomerAvatarWithImage:(UIImage *)avatarImage {
    if (!avatarImage) {
        return;
    }
    _sdkConfig.customerImage = avatarImage;
}

- (void)setCustomerAvatarWithURL:(NSString *)avatarURL {
    if (!avatarURL) {
        return;
    }
    _sdkConfig.customerImageURL = avatarURL;
}

- (void)setIMNavigationTitle:(NSString *)title {
    if (!title) {
        return;
    }
    _sdkConfig.imTitle = title;
}

- (void)setRobotNavigationTitle:(NSString *)title {
    if (!title) {
        return;
    }
    _sdkConfig.robotTtile = title;
}

- (void)setFAQNavigationTitle:(NSString *)title {
    if (!title) {
        return;
    }
    _sdkConfig.faqTitle = title;
}

- (void)setTransferText:(NSString *)text {
    if (!text) {
        return;
    }
    _sdkConfig.transferText = text;
}

- (void)setTicketNavigationTitle:(NSString *)title {
    if (!title) {
        return;
    }
    _sdkConfig.ticketTitle = title;
}

- (void)setArticleNavigationTitle:(NSString *)title {
    if (!title) {
        return;
    }
    _sdkConfig.articleTitle = title;
}

- (void)setAgentMenuNavigationTitle:(NSString *)title {
    if (!title) {
        return;
    }
    _sdkConfig.agentMenuTitle = title;
}

- (void)setTransferToAgentMenu:(BOOL)toMenu {

    _sdkConfig.transferToMenu = toMenu;
}

- (void)setGroupName:(NSString *)name
{
    _sdkConfig.name = name;
}

/**
 * 设置排队放弃类型
 */
- (void)setQuitQueueType:(UDQuitQueueType)type {

    _sdkConfig.quitQueueType = type;
}

- (void)leaveMessageButtonAction:(void(^)(UIViewController *viewController))completion {

    _sdkConfig.leaveMessageAction = completion;
}

/**
 结构化消息点击事件
 
 @param completion 事件完成回调
 */
- (void)structMessageButtonCallBack:(void(^)(void))completion {
    
    _sdkConfig.structMessageCallBack = completion;
}

- (void)leaveChatViewControllerCallBack:(void(^)(void))completion {
    
    _sdkConfig.leaveChatViewController = completion;
}

@end
