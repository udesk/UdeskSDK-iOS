//
//  UdeskImageCell.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseCell.h"

@interface UdeskImageCell : UdeskBaseCell

@property (nonatomic, strong) UILabel *progressLabel;

- (void)uploadImageSuccess;
- (void)imageUploading;

@end
