//
//  UdeskPhotographyHelper.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^DidFinishTakeMediaCompledBlock)(UIImage *image);
typedef void(^DidFinishTakeMediaGIFCompledBlock)(NSData *imageData);
typedef void(^DidFinishTakeMediaVideoCompledBlock)(NSData *video,NSString *fileName);

@interface UdeskPhotographyHelper : NSObject

- (void)showImagePickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType
                           onViewController:(UIViewController *)viewController
                                    compled:(DidFinishTakeMediaCompledBlock)compled
                                 compledGif:(DidFinishTakeMediaGIFCompledBlock)compledGif
                               compledVideo:(DidFinishTakeMediaVideoCompledBlock)compledVideo;

@end
