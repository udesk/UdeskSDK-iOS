//
//  UdeskBaseCell.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/17.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseCell.h"

@implementation UdeskBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateCellWithMessage:(id)message {
	
}

@end
