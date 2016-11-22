//
//  UdeskSDKManager.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/18.
//  Copyright © 2016年 xuchen. All rights reserved.
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
#import "UdeskManager.h"
#import "UdeskSDKShow.h"

@implementation UdeskSDKManager{
    UdeskChatViewController *chatViewController;
    UdeskRobotViewController *robotChat;
    UdeskFAQViewController *faq;
    UdeskAgentMenuViewController *agentMenu;
    UdeskTicketViewController *ticket;
    UdeskSDKConfig *_sdkConfig;
    UdeskSDKShow *_show;
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

- (void)pushUdeskViewControllerWithType:(UdeskType)type
                         viewController:(UIViewController *)viewController
                             completion:(void (^)(void))completion {

    if (_sdkConfig) {
        _sdkConfig = [UdeskSDKConfig sharedConfig];
    }
    
    if (type == UdeskRobot) {
        
        //推到机器人页面
        [self presentRobotController:viewController transiteAnimation:UDTransiteAnimationTypePush completion:completion];
    }
    else if(type == UdeskIM) {
    
        //推到聊天页面
        [self presentIMController:viewController transiteAnimation:UDTransiteAnimationTypePush completion:completion];
    }
    else if(type == UdeskFAQ) {
        
        //推到帮助中心页面
        [self presentFAQController:viewController transiteAnimation:UDTransiteAnimationTypePush completion:completion];
    }
    else if (type == UdeskMenu) {
        
        //推到客服导航栏页面
        [self presentMenuController:viewController transiteAnimation:UDTransiteAnimationTypePush completion:completion];
    }
    else if (type == UdeskTicket) {
    
        //推到留言页面
        [self presentTicketController:viewController transiteAnimation:UDTransiteAnimationTypePush completion:completion];
    }
}

- (void)presentUdeskViewControllerWithType:(UdeskType)type
                            viewController:(UIViewController *)viewController
                                completion:(void (^)(void))completion {
    
    if (_sdkConfig) {
        _sdkConfig = [UdeskSDKConfig sharedConfig];
    }
    
    if (type == UdeskRobot) {
        
        //推到机器人页面
        [self presentRobotController:viewController transiteAnimation:UDTransiteAnimationTypePresent completion:completion];
    }
    else if(type == UdeskIM) {
        
        //推到聊天页面
        [self presentIMController:viewController transiteAnimation:UDTransiteAnimationTypePresent completion:completion];
    }
    else if(type == UdeskFAQ) {
        
        //推到帮助中心页面
        [self presentFAQController:viewController transiteAnimation:UDTransiteAnimationTypePresent completion:completion];
    }
    else if (type == UdeskMenu) {
        
        //推到客服导航栏页面
        [self presentMenuController:viewController transiteAnimation:UDTransiteAnimationTypePresent completion:completion];
    }
    else if (type == UdeskTicket) {
        
        //推到留言页面
        [self presentTicketController:viewController transiteAnimation:UDTransiteAnimationTypePresent completion:completion];
    }
}

//推到聊天页面
- (void)presentIMController:(UIViewController *)viewController
          transiteAnimation:(UDTransiteAnimationType)animationType
                 completion:(void (^)(void))completion {

    if (!chatViewController) {
        chatViewController = [[UdeskChatViewController alloc] initWithSDKConfig:_sdkConfig];
    }
    
    [_show presentOnViewController:viewController udeskViewController:chatViewController transiteAnimation:animationType completion:completion];
}

//推到机器人页面
- (void)presentRobotController:(UIViewController *)viewController
             transiteAnimation:(UDTransiteAnimationType)animationType
                    completion:(void (^)(void))completion {
    
    
    //如果用户正在会话 直接进入聊天页面
    if ([UdeskManager customersAreSession]) {
        [self presentIMController:viewController transiteAnimation:animationType completion:completion];
    }
    else {
        
        //开通机器人进入机器人页面
        [UdeskManager getRobotURL:^(NSURL *robotUrl) {
            
            if (robotUrl) {
                
                if (!robotChat) {
                    robotChat = [[UdeskRobotViewController alloc] initWithSDKConfig:_sdkConfig withURL:robotUrl];
                }
                
                [_show presentOnViewController:viewController udeskViewController:robotChat transiteAnimation:animationType completion:completion];
            }
            else {
                //没有机器人直接进入聊天页面
                [self presentIMController:viewController transiteAnimation:animationType completion:completion];
            }
            
        }];
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

//推到客服导航栏页面
- (void)presentMenuController:(UIViewController *)viewController
           transiteAnimation:(UDTransiteAnimationType)animationType
                  completion:(void (^)(void))completion {
    
    //如果用户正在会话 直接进入聊天页面
//    if ([UdeskManager customersAreSession]) {
//        [self presentIMController:viewController transiteAnimation:animationType completion:completion];
//    }
//    else {
    
        //查看是否有导航栏
        [UdeskManager getAgentNavigationMenu:^(id responseObject, NSError *error) {
            
            //查看导航栏错误，直接进入聊天页面
            if (error) {
                [self presentIMController:viewController transiteAnimation:animationType completion:completion];
                return ;
            }
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                
                NSArray *result = [responseObject objectForKey:@"result"];
                //有设置客服导航栏
                if (result.count) {
                    
                    if (!agentMenu) {
                        agentMenu = [[UdeskAgentMenuViewController alloc] initWithSDKConfig:_sdkConfig menuArray:result];
                    }
                    
                    [_show presentOnViewController:viewController udeskViewController:agentMenu transiteAnimation:animationType completion:completion];
                }
                else {
                    //没有设置导航栏 直接进入聊天页面
                    [self presentIMController:viewController transiteAnimation:animationType completion:completion];
                }
            }
            
        }];
        
//    }

}

//推到留言页面
- (void)presentTicketController:(UIViewController *)viewController
           transiteAnimation:(UDTransiteAnimationType)animationType
                  completion:(void (^)(void))completion {
    
    if (!ticket) {
        ticket = [[UdeskTicketViewController alloc] initWithSDKConfig:_sdkConfig];
    }
    
    [_show presentOnViewController:viewController udeskViewController:ticket transiteAnimation:animationType completion:completion];
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

    if (!product) {
        return;
    }
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

@end
