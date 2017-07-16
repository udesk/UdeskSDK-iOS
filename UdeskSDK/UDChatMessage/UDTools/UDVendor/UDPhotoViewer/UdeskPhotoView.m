//
//  UDPhotoView.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskPhotoView.h"
#import "UdeskOneScrollView.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "Udesk_YYWebImage.h"

#define Gap 10   //俩照片间黑色间距

@implementation UdeskPhotoView {

    NSString *imageUrl;
}

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

-(void)setPhotoData:(UIImageView *)photoImageView withMessageURL:(NSString *)url {
    
    imageUrl = url;
    //传值给单个滚动器
    UdeskOneScrollView *oneScroll = [[UdeskOneScrollView alloc]init];
    oneScroll.mydelegate = self;
    //自己是数组中第几个图
    //设置位置并添加
    oneScroll.frame = CGRectMake(Gap , 0 ,UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT);
    [self addSubview:oneScroll];
    
    [oneScroll setLocalImage:photoImageView withMessageURL:url];
 
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(UD_SCREEN_WIDTH-45-15, UD_SCREEN_HEIGHT-26-15, 45, 26);
    [button setTitle:getUDLocalizedString(@"udesk_save") forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blackColor]];
    [button addTarget:self action:@selector(saveImageAction:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    UDViewBorderRadius(button, 3, 1, [UIColor grayColor]);
    [self addSubview:button];
}

- (void)saveImageAction:(UIButton *)button {
    
    UIImage *image;
    if ([[Udesk_YYWebImageManager sharedManager].cache containsImageForKey:imageUrl]) {
        image = [[Udesk_YYWebImageManager sharedManager].cache getImageForKey:imageUrl];
    }
    else {
    
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        image = [UIImage imageWithData:data];
    }
    
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        });
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = getUDLocalizedString(@"udesk_failed_save");
    }else{
        msg = getUDLocalizedString(@"udesk_success_save");
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
#pragma clang diagnostic pop
}

#pragma mark - OneScroll的代理方法

//退出图片浏览器
-(void)goBack
{
    //让原始底层UIView死掉
    [self.superview removeFromSuperview];
}


@end
