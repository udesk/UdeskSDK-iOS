//
//  UdeskPhotographyHelper.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DidFinishTakeMediaCompledBlock)(UIImage *image);

@interface UdeskPhotographyHelper : NSObject

- (void)showImagePickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType onViewController:(UIViewController *)viewController compled:(DidFinishTakeMediaCompledBlock)compled;

@end
