//
//  UdeskPhotographyHelper.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskPhotographyHelper.h"
#import "UdeskFoundationMacro.h"

@interface UdeskPhotographyHelper () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) DidFinishTakeMediaCompledBlock didFinishTakeMediaCompled;

@end

@implementation UdeskPhotographyHelper

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.didFinishTakeMediaCompled = nil;
}

- (void)showImagePickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType onViewController:(UIViewController *)viewController compled:(DidFinishTakeMediaCompledBlock)compled {
    
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        compled(nil);
        return;
    }
    self.didFinishTakeMediaCompled = [compled copy];
    
    //兼容ipad打不开相册问题，使用队列延迟
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.editing = YES;
        imagePickerController.delegate = self;
        imagePickerController.sourceType = sourceType;
        
        [viewController presentViewController:imagePickerController animated:YES completion:NULL];
    }];
}

- (void)dismissPickerViewController:(UIImagePickerController *)picker {
    
    @udWeakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @udStrongify(self);
        self.didFinishTakeMediaCompled = nil;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (self.didFinishTakeMediaCompled) {
        self.didFinishTakeMediaCompled(info[UIImagePickerControllerOriginalImage]);
    }
    
    [self dismissPickerViewController:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissPickerViewController:picker];
}

@end
