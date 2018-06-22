//
//  UdeskOneScrollView.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UDOneScrollViewDelegate <NSObject>

- (void)goBack;

@optional

@end
@interface UdeskOneScrollView : UIScrollView

//代理
@property(nonatomic,weak)id<UDOneScrollViewDelegate> mydelegate;

//本地加载图
-(void)setLocalImage:(UIImageView *)imageView withMessageURL:(NSString *)url;

//回复放大缩小前的原状
-(void)reloadFrame;

@end
