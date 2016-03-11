//
//  UDChatCellViewModel.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/20.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDChatCellViewModel.h"
#import "UDMessageTableViewCell.h"
#import "UDAudioPlayerHelper.h"
#import "UDPhotoManeger.h"
#import "UDMessageInputView.h"
#import "UDMessageTextView.h"
#import "UDTools.h"

@interface UDChatCellViewModel()<UDAudioPlayerHelperDelegate>

@property (nonatomic, strong) UDMessageTableViewCell *currentSelectedCell;

@end

@implementation UDChatCellViewModel

- (void)didSelectedOnMessage:(UDMessage *)message
                   indexPath:(NSIndexPath *)indexPath
            messageInputView:(UDMessageInputView *)inputView
        messageTableViewCell:(UDMessageTableViewCell *)messageTableViewCell {

    switch (message.messageType) {
        case UDMessageMediaTypeText:
            
            if (![UDTools isBlankString:[UDTools contentsOfRegexStrArray:message.text]]) {
                
                if ([[UDTools contentsOfRegexStrArray:message.text] hasPrefix:@"www"]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[UDTools contentsOfRegexStrArray:message.text]]]];
                }else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[UDTools contentsOfRegexStrArray:message.text]]];
                }
            }
            
            break;
            
        case UDMessageMediaTypePhoto: {
            
            [inputView.inputTextView resignFirstResponder];
            
            UDPhotoManeger *photoManeger = [UDPhotoManeger maneger];
            
            [photoManeger showLocalPhoto:messageTableViewCell.messageContentView.photoImageView withImageMessage:message];
            
        }
            break;
        case UDMessageMediaTypeVoice:
            
            [[UDAudioPlayerHelper shareInstance] setDelegate:(id<NSFileManagerDelegate>)self];
            if (_currentSelectedCell) {
                [_currentSelectedCell.messageContentView.animationVoiceImageView stopAnimating];
            }
            if (_currentSelectedCell == messageTableViewCell) {
                [messageTableViewCell.messageContentView.animationVoiceImageView stopAnimating];
                [[UDAudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            } else {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageContentView.animationVoiceImageView startAnimating];
                [[UDAudioPlayerHelper shareInstance] managerAudio:message toPlay:YES];
            }
            
            break;
            
        default:
            break;
    }

}

#pragma mark - UDAudioPlayerHelper Delegate
- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer {
    
    [_currentSelectedCell.messageContentView.animationVoiceImageView stopAnimating];
    
}

@end
