//
//  UdeskImagePicker.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^UDDidFinishTakeMediaCompledBlock)(UIImage *image);
typedef void(^UDDidFinishTakeMediaGIFCompledBlock)(NSData *imageData);
typedef void(^UDDidFinishTakeMediaVideoCompledBlock)(NSString *filePath,NSString *fileName);

@interface UdeskImagePicker : NSObject

- (void)showImagePickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType
                           onViewController:(UIViewController *)viewController
                                    compled:(UDDidFinishTakeMediaCompledBlock)compled
                                 compledGif:(UDDidFinishTakeMediaGIFCompledBlock)compledGif
                               compledVideo:(UDDidFinishTakeMediaVideoCompledBlock)compledVideo;

@end
