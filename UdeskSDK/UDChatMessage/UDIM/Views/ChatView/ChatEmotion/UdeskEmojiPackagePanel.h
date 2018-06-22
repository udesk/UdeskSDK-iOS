//
//  UdeskEmojiPackagePanel.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat UdeskEmojiPackagePanelHeight = 36;

@protocol UdeskEmojiPackagePanelDelegate <NSObject>

//点击表情面板
- (void)tapPackagePaneAtIndex:(NSInteger)packageIndex;

@end

@interface UdeskEmojiPackagePanel : UIScrollView

@property (nonatomic, weak) id<UdeskEmojiPackagePanelDelegate> udDelegate;
@property (nonatomic, strong) NSArray *emojiPanels;

@end
