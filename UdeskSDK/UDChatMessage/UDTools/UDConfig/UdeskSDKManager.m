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

- (void)pushUdeskViewControllerWithType:(UdeskType)type viewController:(UIViewController *)viewController {

    if (_sdkConfig) {
        _sdkConfig = [UdeskSDKConfig sharedConfig];
    }
    
    if (type == UdeskRobot) {

        [UdeskManager getRobotURL:^(NSURL *robotUrl) {
           
            if (robotUrl) {
                
                if (!robotChat) {
                    robotChat = [[UdeskRobotViewController alloc] initWithSDKConfig:_sdkConfig withURL:robotUrl];
                }
                
                [_show presentOnViewController:viewController udeskViewController:robotChat transiteAnimation:UDTransiteAnimationTypePush];
            }
            else {
            
                if (!chatViewController) {
                    chatViewController = [[UdeskChatViewController alloc] initWithSDKConfig:_sdkConfig];
                }
                
                [_show presentOnViewController:viewController udeskViewController:chatViewController transiteAnimation:UDTransiteAnimationTypePush];
            }
            
        }];
        
    }
    else if(type == UdeskIM) {
    
        if (!chatViewController) {
            chatViewController = [[UdeskChatViewController alloc] initWithSDKConfig:_sdkConfig];
        }
        
        [_show presentOnViewController:viewController udeskViewController:chatViewController transiteAnimation:UDTransiteAnimationTypePush];
    }
    else if(type == UdeskFAQ) {
        
        if (!faq) {
            faq = [[UdeskFAQViewController alloc] initWithSDKConfig:_sdkConfig];
        }
        
        [_show presentOnViewController:viewController udeskViewController:faq transiteAnimation:UDTransiteAnimationTypePush];
    }
    else if (type == UdeskMenu) {
    
        [UdeskManager getAgentNavigationMenu:^(id responseObject, NSError *error) {
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                
                NSArray *result = [responseObject objectForKey:@"result"];
                if (result.count) {
                    
                    if (!agentMenu) {
                        agentMenu = [[UdeskAgentMenuViewController alloc] initWithSDKConfig:_sdkConfig menuArray:result];
                    }
                    
                    [_show presentOnViewController:viewController udeskViewController:agentMenu transiteAnimation:UDTransiteAnimationTypePush];
                }
                else {
                    
                    if (!chatViewController) {
                        chatViewController = [[UdeskChatViewController alloc] initWithSDKConfig:_sdkConfig];
                    }
                    
                    [_show presentOnViewController:viewController udeskViewController:chatViewController transiteAnimation:UDTransiteAnimationTypePush];
                }
            }
            
        }];

    }
    else if (type == UdeskTicket) {
    
        if (!ticket) {
            ticket = [[UdeskTicketViewController alloc] initWithSDKConfig:_sdkConfig];
        }
        
        [_show presentOnViewController:viewController udeskViewController:ticket transiteAnimation:UDTransiteAnimationTypePush];
    }
}

- (void)presentUdeskViewControllerWithType:(UdeskType)type viewController:(UIViewController *)viewController {
    
    if (_sdkConfig) {
        _sdkConfig = [UdeskSDKConfig sharedConfig];
    }
    
    if (type == UdeskRobot) {
        
        [UdeskManager getRobotURL:^(NSURL *robotUrl) {
            
            if (robotUrl) {
                
                if (!robotChat) {
                    robotChat = [[UdeskRobotViewController alloc] initWithSDKConfig:_sdkConfig withURL:robotUrl];
                }
                
                [_show presentOnViewController:viewController udeskViewController:robotChat transiteAnimation:UDTransiteAnimationTypePresent];
            }
            else {
                
                if (!chatViewController) {
                    chatViewController = [[UdeskChatViewController alloc] initWithSDKConfig:_sdkConfig];
                }
                
                [_show presentOnViewController:viewController udeskViewController:chatViewController transiteAnimation:UDTransiteAnimationTypePresent];
            }
            
        }];
        
    }
    else if(type == UdeskIM) {
        
        if (!chatViewController) {
            chatViewController = [[UdeskChatViewController alloc] initWithSDKConfig:_sdkConfig];
        }
        
        [_show presentOnViewController:viewController udeskViewController:chatViewController transiteAnimation:UDTransiteAnimationTypePresent];
    }
    else if(type == UdeskFAQ) {
        
        if (!faq) {
            faq = [[UdeskFAQViewController alloc] initWithSDKConfig:_sdkConfig];
        }
        
        [_show presentOnViewController:viewController udeskViewController:faq transiteAnimation:UDTransiteAnimationTypePresent];
    }
    else if (type == UdeskMenu) {
        
        [UdeskManager getAgentNavigationMenu:^(id responseObject, NSError *error) {
            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                
                NSArray *result = [responseObject objectForKey:@"result"];
                if (result.count) {
                    
                    if (!agentMenu) {
                        agentMenu = [[UdeskAgentMenuViewController alloc] initWithSDKConfig:_sdkConfig menuArray:result];
                    }
                    
                    [_show presentOnViewController:viewController udeskViewController:agentMenu transiteAnimation:UDTransiteAnimationTypePresent];
                }
                else {
                    
                    if (!chatViewController) {
                        chatViewController = [[UdeskChatViewController alloc] initWithSDKConfig:_sdkConfig];
                    }
                    
                    [_show presentOnViewController:viewController udeskViewController:chatViewController transiteAnimation:UDTransiteAnimationTypePresent];
                }
            }
            
        }];
        
    }
    else if (type == UdeskTicket) {
        
        if (!ticket) {
            ticket = [[UdeskTicketViewController alloc] initWithSDKConfig:_sdkConfig];
        }
        
        [_show presentOnViewController:viewController udeskViewController:ticket transiteAnimation:UDTransiteAnimationTypePresent];
    }
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

@end
