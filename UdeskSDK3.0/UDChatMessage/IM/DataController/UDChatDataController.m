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

- (void)getDatabaseHistoryMessage:(void (^)(NSArray *dbMessageArray))result {

    NSString *sql = [NSString stringWithFormat:@"select *from %@ order by replied_at desc Limit %ld,%ld",MessageDB,(long)_messageNumber,(long)UDChatGetHistoreMessageNumber];
    _messageNumber += UDChatGetHistoreMessageNumber;
    
    [UDManager queryTabelWithSqlString:sql params:nil finishedBlock:^(NSArray *dbData) {
        
        if (result) {
            result(dbData);
        }

    }];
    
}

@end
