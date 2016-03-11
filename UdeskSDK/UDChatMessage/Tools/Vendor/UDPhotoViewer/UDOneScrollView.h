//
//  UDOneScrollView.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDMessage.h"

@protocol UDOneScrollViewDelegate <NSObject>

-(void)goBack;

@optional

@end
@interface UDOneScrollView : UIScrollView

//代理
@property(nonatomic,weak)id<UDOneScrollViewDelegate> mydelegate;

//本地加载图
-(void)setLocalImage:(UIImageView *)imageView withImageMessage:(UDMessage *)message;

//回复放大缩小前的原状
-(void)reloadFrame;

@end
