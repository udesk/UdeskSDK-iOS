//
//  UdeskSpeechRecognizerView.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/8.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UdeskSpeechRecognizerViewDelegate <NSObject>

- (void)didSendRecognizerVoiceResultText:(NSString *)resultText;

@end

@interface UdeskSpeechRecognizerView : UIView

@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak  ) id<UdeskSpeechRecognizerViewDelegate> delegate;

- (void)show;
- (void)dismiss;

- (void)startEditContent;
- (void)stopEditContent;

@end
