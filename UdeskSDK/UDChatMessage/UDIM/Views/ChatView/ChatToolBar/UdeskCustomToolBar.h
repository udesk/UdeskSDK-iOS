//
//  UdeskCustomToolBar.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/21.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class UdeskCustomToolBar;
@class UdeskCustomButtonConfig;

@protocol UdeskCustomToolBarDelegate <NSObject>

@optional
- (void)didSelectCustomToolBar:(UdeskCustomToolBar *)toolBar atIndex:(NSInteger)index;
- (void)didTapSurveyAction:(UdeskCustomToolBar *)toolBar;

@end

@interface UdeskCustomToolBar : UIView

@property (nonatomic, weak) id<UdeskCustomToolBarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
          customButtonConfigs:(NSArray<UdeskCustomButtonConfig *> *)customButtonConfigs
                 enableSurvey:(BOOL)enableSurvey;

@end
