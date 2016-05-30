//
//  UdeskPhotoManeger.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UdeskMessage.h"

@interface UdeskPhotoManeger : NSObject
/**
 *  创建
 */
+(instancetype)maneger;

/**
 *  本地图片放大浏览    
 */
-(void)showLocalPhoto:(UIImageView *)selecView withImageMessage:(UdeskMessage *)message;


@end
