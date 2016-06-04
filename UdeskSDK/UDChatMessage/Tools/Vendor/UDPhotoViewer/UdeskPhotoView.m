//
//  UDPhotoView.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskPhotoView.h"
#import "UdeskOneScrollView.h"
#import "UdeskFoundationMacro.h"

#define Gap 10   //俩照片间黑色间距

@implementation UdeskPhotoView

#pragma mark - 自己的属性设置一下
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        //设置主滚动创的大小位置
        self.frame = CGRectMake(-Gap, 0, [UIScreen mainScreen].bounds.size.width + Gap + Gap,[UIScreen mainScreen].bounds.size.height);
        
    }
    return self;
}

#pragma mark - 拿到数据时展示

-(void)setPhotoData:(UIImageView *)photoImageView withImageMessage:(UdeskMessage *)message {
    
    //传值给单个滚动器
    UdeskOneScrollView *oneScroll = [[UdeskOneScrollView alloc]init];
    oneScroll.mydelegate = self;
    //自己是数组中第几个图
    //设置位置并添加
    oneScroll.frame = CGRectMake(Gap , 0 ,UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT);
    [self addSubview:oneScroll];
    
    [oneScroll setLocalImage:photoImageView withImageMessage:message];
    
}

#pragma mark - OneScroll的代理方法

//退出图片浏览器
-(void)goBack
{
    //让原始底层UIView死掉
    [self.superview removeFromSuperview];
}


@end
