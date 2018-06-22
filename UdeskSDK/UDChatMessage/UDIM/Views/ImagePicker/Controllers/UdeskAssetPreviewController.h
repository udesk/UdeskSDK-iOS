//
//  UdeskAssetPreviewController.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskAssetPreviewController : UIViewController

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray   *assetArray;
@property (nonatomic, strong) NSArray   *selectedAssetArray;
@property (nonatomic, assign) BOOL      isSelectOriginalPhoto;

//返回
@property (nonatomic, copy  ) void(^BackButtonClickBlock)(void);
//更新选择原图按钮
@property (nonatomic, copy  ) void(^UpdateOriginalButtonBlock)(BOOL isSelect);
//发送
@property (nonatomic, copy  ) void(^FinishSelectBlock)(void);

@end
