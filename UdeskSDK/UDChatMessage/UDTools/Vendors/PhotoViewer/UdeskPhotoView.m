//
//  UDPhotoView.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskPhotoView.h"
#import "UdeskOneScrollView.h"
#import "UdeskBundleUtils.h"
#import "Udesk_YYWebImage.h"
#import "UdeskButton.h"

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
    oneScroll.frame = CGRectMake(Gap , 0 ,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    [self addSubview:oneScroll];
    
    [oneScroll setLocalImage:photoImageView withMessageURL:url];
 
    UdeskButton *button = [UdeskButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-28-15, [[UIScreen mainScreen] bounds].size.height-26-15, 28, 28);
    [button setImage:[UIImage imageWithContentsOfFile:getUDBundlePath(@"udImageSave")] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(saveImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)saveImageAction:(UIButton *)button {
    
    if ([[Udesk_YYWebImageManager sharedManager].cache containsImageForKey:imageUrl]) {
        UIImage *image = [[Udesk_YYWebImageManager sharedManager].cache getImageForKey:imageUrl];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            });
        }
    }
    else {
        
        [[Udesk_YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:imageUrl] options:Udesk_YYWebImageOptionShowNetworkActivity progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, Udesk_YYWebImageFromType from, Udesk_YYWebImageStage stage, NSError * _Nullable error) {
           
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
                });
            }
        }];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:getUDLocalizedString(@"udesk_sure"), nil];
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
