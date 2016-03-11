//
//  UDAgentStatusView.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDAgentViewModel.h"

@interface UDAgentStatusView : UIView

/**
 *  在线状态标题
 */
@property (nonatomic, weak) UILabel  *describeTitle;
/**
 * im标题
 */
@property (nonatomic, weak) UILabel  *titleLabel;

/**
 *  客服上下线
 *
 *  @param statusType 客服在线状态
 */
- (void)agentOnlineOrNotOnline:(NSString *)statusType;

/**
 *  拿数据显示客服状态
 *
 *  @param viewModel 客服数据
 */
//- (void)bindDataWithAgentModel:(UDAgentViewModel *)viewModel;

- (void)bindDataWithAgentModel:(UDAgentModel *)agentModel;

@end
