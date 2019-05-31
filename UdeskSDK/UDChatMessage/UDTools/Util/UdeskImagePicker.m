//
//  UdeskImagePicker.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskImagePicker.h"
#import "UdeskSDKMacro.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UdeskSDKUtil.h"
#import "UdeskSDKConfig.h"
#import "UdeskImageUtil.h"

@interface UdeskImagePicker () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) UDDidFinishTakeMediaCompledBlock didFinishTakeMediaCompled;
@property (nonatomic, copy) UDDidFinishTakeMediaGIFCompledBlock didFinishTakeMediaGIFCompled;
@property (nonatomic, copy) UDDidFinishTakeMediaVideoCompledBlock didFinishTakeMediaVideoCompled;

@end

@implementation UdeskImagePicker

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    _didFinishTakeMediaCompled = nil;
}

- (void)showImagePickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType
                           onViewController:(UIViewController *)viewController
                                    compled:(UDDidFinishTakeMediaCompledBlock)compled
                                 compledGif:(UDDidFinishTakeMediaGIFCompledBlock)compledGif
                               compledVideo:(UDDidFinishTakeMediaVideoCompledBlock)compledVideo {
    
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        compled(nil);
        return;
    }
    self.didFinishTakeMediaCompled = [compled copy];
    self.didFinishTakeMediaGIFCompled = [compledGif copy];
    self.didFinishTakeMediaVideoCompled = [compledVideo copy];
    
    //兼容ipad打不开相册问题，使用队列延迟
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        NSString *movieType = (NSString *)kUTTypeMovie;
        NSString *imageType = (NSString *)kUTTypeImage;
        NSArray *arrMediaTypes = [NSArray arrayWithObjects:imageType,movieType,nil];
        if (![UdeskSDKConfig customConfig].isAllowShootingVideo) {
            arrMediaTypes = [NSArray arrayWithObjects:imageType,nil];
        }
        [imagePickerController setMediaTypes: arrMediaTypes];
        
        imagePickerController.editing = YES;
        imagePickerController.delegate = self;
        imagePickerController.sourceType = sourceType;
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
        if ([UdeskSDKConfig customConfig].sdkStyle.albumCancelColor) {
            imagePickerController.navigationBar.tintColor = [UdeskSDKConfig customConfig].sdkStyle.albumCancelColor;
        }
        
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
    
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    if (refURL) {
    
        ALAssetsLibrary* assetLibrary = [[ALAssetsLibrary alloc] init];
        @udWeakify(self);
        void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset) {
            
            @udStrongify(self);
            if (asset != nil) {
                
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSString *type = info[UIImagePickerControllerMediaType];
                if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
                    
                    NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
                    
                    if (self.didFinishTakeMediaVideoCompled) {
                        self.didFinishTakeMediaVideoCompled(videoPath,[rep filename]);
                    }
                }
                else {
                    
                    Byte *imageBuffer = (Byte*)malloc(rep.size);
                    NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
                    NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
                    
                    NSString *type = [UdeskImageUtil contentTypeForImageData:imageData];
                    
                    if ([type isEqualToString:@"gif"]) {
                        
                        if (self.didFinishTakeMediaGIFCompled) {
                            self.didFinishTakeMediaGIFCompled(imageData);
                        }
                    }
                    else {
                        
                        if (self.didFinishTakeMediaCompled) {
                            self.didFinishTakeMediaCompled(info[UIImagePickerControllerOriginalImage]);
                        }
                    }
                }
            }
        };
        
        [assetLibrary assetForURL:refURL
                      resultBlock:ALAssetsLibraryAssetForURLResultBlock
                     failureBlock:^(NSError *error){
                     }];

    }
    else {

        NSString *type = info[UIImagePickerControllerMediaType];
        if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
            
            NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
            
            if (self.didFinishTakeMediaVideoCompled) {
                self.didFinishTakeMediaVideoCompled(videoPath,[NSString stringWithFormat:@"%@.mp4",[UdeskSDKUtil soleString]]);
            }
        }
        else {

            if (self.didFinishTakeMediaCompled) {
                self.didFinishTakeMediaCompled(info[UIImagePickerControllerOriginalImage]);
            }
        }
    }
    
    [self dismissPickerViewController:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissPickerViewController:picker];
}

@end
