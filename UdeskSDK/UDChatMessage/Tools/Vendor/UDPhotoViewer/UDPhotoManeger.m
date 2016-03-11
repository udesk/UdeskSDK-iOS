//
//  UDPhotoManeger.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDPhotoManeger.h"
#import "UDPhotoView.h"


@implementation UDPhotoManeger

/**
 *  创建
 */
+(instancetype)maneger
{
    UDPhotoManeger *mg = [[UDPhotoManeger alloc]init];
    return mg;
}


/**
 *  本地图片放大浏览
 */
-(void)showLocalPhoto:(UIImageView *)selecView withImageMessage:(UDMessage *)message
{
    
    UDPhotoView *photoView = [[UDPhotoView alloc] init];
    [photoView setPhotoData:selecView withImageMessage:message];
    
    [self show:photoView];
}

//展示
-(void)show:(UIView *)mainScrollView
{
    
    //创建原始的底层View一个
    UIView *view =  [[UIView alloc]init];
    view.frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    [view addSubview:mainScrollView];
    //解决放大的图片不在当前视图
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}

@end
