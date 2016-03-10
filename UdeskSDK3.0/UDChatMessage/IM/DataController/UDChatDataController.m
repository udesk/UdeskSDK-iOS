//
//  UDChatDataController.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDChatDataController.h"
#import "UDAgentModel.h"
#import "UDManager.h"

static NSInteger const UDChatGetHistoreMessageNumber = 20;

@interface UDChatDataController() {

    NSInteger _messageNumber;

}

@end

@implementation UDChatDataController

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
