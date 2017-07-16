//
//  UdeskPhotographyHelper.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskPhotographyHelper.h"
#import "UdeskFoundationMacro.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UdeskTools.h"

@interface UdeskPhotographyHelper () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) DidFinishTakeMediaCompledBlock didFinishTakeMediaCompled;
@property (nonatomic, copy) DidFinishTakeMediaGIFCompledBlock didFinishTakeMediaGIFCompled;
@property (nonatomic, copy) DidFinishTakeMediaVideoCompledBlock didFinishTakeMediaVideoCompled;

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

- (void)showImagePickerControllerSourceType:(UIImagePickerControllerSourceType)sourceType
                           onViewController:(UIViewController *)viewController
                                    compled:(DidFinishTakeMediaCompledBlock)compled
                                 compledGif:(DidFinishTakeMediaGIFCompledBlock)compledGif
                               compledVideo:(DidFinishTakeMediaVideoCompledBlock)compledVideo {
    
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
        NSArray *arrMediaTypes=[NSArray arrayWithObjects:imageType,movieType,nil];
        [imagePickerController setMediaTypes: arrMediaTypes];
        
        imagePickerController.editing = YES;
        imagePickerController.delegate = self;
        imagePickerController.sourceType = sourceType;
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
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
                    NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
                    
                    if (self.didFinishTakeMediaVideoCompled) {
                        self.didFinishTakeMediaVideoCompled(videoData,[rep filename]);
                    }
                }
                else {
                    
                    Byte *imageBuffer = (Byte*)malloc(rep.size);
                    NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
                    NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
                    
                    NSString *type = [self contentTypeForImageData:imageData];
                    
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
            NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
            
            if (self.didFinishTakeMediaVideoCompled) {
                self.didFinishTakeMediaVideoCompled(videoData,[NSString stringWithFormat:@"%@.mp4",[UdeskTools soleString]]);
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

//通过图片Data数据第一个字节 来获取图片扩展名
- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}

@end
