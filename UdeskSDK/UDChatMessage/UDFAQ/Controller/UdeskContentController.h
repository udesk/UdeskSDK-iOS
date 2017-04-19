//
//  UdeskContentController.h
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskContentController : UIViewController<UIWebViewDelegate>

/**
 *  文章ID
 */
@property (nonatomic, strong  ) NSString   *articleId;
/**
 *  文章标题
 */
@property (nonatomic, strong  ) NSString   *articlesTitle;

- (void)dismissChatViewController;

@end
