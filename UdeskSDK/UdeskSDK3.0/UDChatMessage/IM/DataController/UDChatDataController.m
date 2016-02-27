//
//  UDChatDataController.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDChatDataController.h"
#import "UDAgentDataController.h"
#import "UDAgentModel.h"

static NSInteger const UDChatGetHistoreMessageNumber = 20;

@interface UDChatDataController() {

    NSInteger _messageNumber;

}

@property (nonatomic, strong) UDAgentDataController *agentDataController;

@end

@implementation UDChatDataController

- (void)requestAgentDataWithCallback:(void(^)(UDAgentModel *udAgent,NSError *error))callback {
    
    UDAgentDataCallBack dataCallback = ^(UDAgentModel *udAgent,NSError *error) {
    
        if (callback) {
            
            callback(udAgent,error);
        }
        
        if (udAgent.code == 2001) {
            
            // 客服状态码等于2001 20s轮训一次
            __weak typeof(self) weakSelf = self;
            double delayInSeconds = 20.0f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [weakSelf requestAgentDataWithCallback:callback];
                
            });
            
            
        }
        
    };
    
    [UDAgentDataController.store requestAgentDataWithCallback:dataCallback];
    
}

- (void)getDatabaseHistoryMessage:(void (^)(NSMutableArray *dbMessageArray))result {
    
    NSMutableArray *onlyMessage = [NSMutableArray array];

    NSString *sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%ld",MessageDB,(long)_messageNumber,(long)UDChatGetHistoreMessageNumber];
    _messageNumber += UDChatGetHistoreMessageNumber;
    
    [UDManager queryTabelWithSqlString:sql params:nil finishedBlock:^(NSArray *dbData) {
        
        [dbData ud_each:^(NSDictionary *dic) {
            
            [onlyMessage insertObject:[self dbMessageResolving:dic] atIndex:0];
            
        }];
        
        if (result) {
            result(onlyMessage);
        }

    }];
    
}


- (UDMessage *)dbMessageResolving:(NSDictionary *)dbMessage {
    
    UDMessage *message = [[UDMessage alloc] init];
    message.messageFrom = [[dbMessage objectForKey:@"direction"] integerValue];
    message.messageType = [[dbMessage objectForKey:@"mesType"] integerValue];
    message.contentId = [dbMessage objectForKey:@"msgid"];
    message.messageStatus = [[dbMessage objectForKey:@"sendflag"] integerValue];
    message.timestamp = [UDTools dateFromString:[dbMessage objectForKey:@"replied_at"]];
    
    switch (message.messageType) {
        case UDMessageMediaTypeText:
            message.text = [UDTools receiveTextEmoji:[dbMessage objectForKey:@"content"]];
            
            break;
        case UDMessageMediaTypePhoto:{
            
            message.width = [dbMessage objectForKey:@"width"];
            message.height = [dbMessage objectForKey:@"height"];
            message.photoUrl = [dbMessage objectForKey:@"content"];
            
        }
            break;
        case UDMessageMediaTypeVoice:
            message.voiceDuration = [dbMessage objectForKey:@"duration"];
            message.voiceUrl = [dbMessage objectForKey:@"content"];
            
            
            break;
        case UDMessageMediaTypeRedirect:{
        
            message.text = [dbMessage objectForKey:@"content"];
            
            break;
        }
            
        default:
            break;
    }
    
    return message;
    
}

@end
