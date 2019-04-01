//
//  UdeskSpeechRecognizerViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/8.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskSpeechRecognizerView;

@interface UdeskSpeechRecognizerViewController : UIViewController

@property(nonatomic, strong, readonly) UdeskSpeechRecognizerView *recognizerView;

- (void)showRecognizerView:(UdeskSpeechRecognizerView *)recognizerView completion:(void (^)(void))completion;
- (void)dismissWithCompletion:(void (^)(void))completion;

@end
