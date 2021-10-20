//
//  UdeskCustomCustomerTableViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/7/4.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskCustomCustomerTableViewController.h"
#import "UdeskCustomButtonTestViewController.h"
#import "Udesk.h"

@interface UdeskCustomCustomerTableViewController ()

@property (nonatomic, strong) NSMutableArray *customerInfo;
@property (nonatomic, strong) UdeskCustomer *customerModel;
@property (nonatomic, assign) BOOL selectCustomFieldType;

@end

@implementation UdeskCustomCustomerTableViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *customField = [[UIBarButtonItem alloc] initWithTitle:@"新增字段" style:UIBarButtonItemStylePlain target:self action:@selector(addCustomField)];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pushUdeskSDK)];
    
    self.navigationItem.rightBarButtonItems = @[customField,done];
}

- (void)addCustomField {
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"请选择自定义字段类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (ud_isPad) {
        //ipad适配
        [sheet setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [sheet popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"选择性字段" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.selectCustomFieldType = YES;
        [self inputCustomField];
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"文本字段" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.selectCustomFieldType = NO;
        [self inputCustomField];
    }]];
    
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)inputCustomField {
    
    UdeskCustomerCustomField *customField = [UdeskCustomerCustomField new];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入自定义字段" preferredStyle:1];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *key = alert.textFields.firstObject;
        UITextField *value = alert.textFields.lastObject;
        customField.fieldKey = key.text;
        
        if (self.selectCustomFieldType) {
            customField.fieldValue = @[value.text];
        }
        else {
            customField.fieldValue = value.text;
        }
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.customerModel.customField];
        [array addObject:customField];
        self.customerModel.customField = [array copy];
        [self.tableView reloadData];
    }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"自定义字段的key";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"自定义字段的value";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)pushUdeskSDK {
    
    UdeskOrganization *organization = [[UdeskOrganization alloc] initWithDomain:[UdeskManager domain]
                                                                         appKey:[UdeskManager key]
                                                                          appId:[UdeskManager appId]];
    
    //初始化sdk
    [UdeskManager initWithOrganization:organization customer:self.customerModel];
    

    UdeskCustomButtonConfig *buttonConfig1 = [[UdeskCustomButtonConfig alloc] initWithTitle:@"自定义按钮" image:nil type:UdeskCustomButtonConfigTypeInInputTop clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
        
        UdeskProductOrdersViewController *orders = [[UdeskProductOrdersViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:orders];
        [viewController presentViewController:nav animated:YES completion:nil];
        
        orders.didSendOrderBlock = ^(UdeskOrderSendType sendType,UdeskGoodsModel *goodsModel) {
            [UdeskCustomButtonTestViewController sendOrderWithType:sendType viewController:viewController goodsModel:goodsModel];
        };
    }];
    
    UdeskCustomButtonConfig *buttonConfig2 = [[UdeskCustomButtonConfig alloc] initWithTitle:@"断开Socket" image:nil type:UdeskCustomButtonConfigTypeInInputTop clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
        
        [UdeskManager setupCustomerOffline];
    }];
    
    UdeskCustomButtonConfig *buttonConfig3 = [[UdeskCustomButtonConfig alloc] initWithTitle:@"连接Socket" image:nil type:UdeskCustomButtonConfigTypeInInputTop clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
        
        [UdeskManager setupCustomerOnline];
    }];
    
    UdeskSDKConfig *config = [UdeskSDKConfig customConfig];
    config.customButtons = @[buttonConfig1,buttonConfig2,buttonConfig3];
    config.showCustomButtons = YES;
    
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:config];
    [chatViewManager pushUdeskInViewController:self completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.customerInfo.count;
    }
    else {
        return self.customerModel.customField.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    if (indexPath.section == 0) {
        
        cell.textLabel.text = self.customerInfo[indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = self.customerModel.sdkToken;
                break;
            case 1:
                cell.detailTextLabel.text = self.customerModel.customerToken;
                break;
            case 2:
                cell.detailTextLabel.text = self.customerModel.nickName;
                break;
            case 3:
                cell.detailTextLabel.text = self.customerModel.cellphone;
                break;
            case 4:
                cell.detailTextLabel.text = self.customerModel.email;
                break;
            case 5:
                cell.detailTextLabel.text = self.customerModel.customerDescription;
                break;
            case 6:
                cell.detailTextLabel.text = self.customerModel.channel;
                break;
                
            default:
                break;
        }
    }
    else {
        
        UdeskCustomerCustomField *customField = self.customerModel.customField[indexPath.row];
        cell.textLabel.text = customField.fieldKey;
        cell.detailTextLabel.text = customField.fieldValue;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section != 0) {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"请输入%@的值",cell.textLabel.text] preferredStyle:1];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = alert.textFields.firstObject;
        if (indexPath.section == 0) {
            cell.detailTextLabel.text = textField.text;
            switch (indexPath.row) {
                case 0:
                    self.customerModel.sdkToken = textField.text;
                    break;
                case 1:
                    self.customerModel.customerToken = textField.text;
                    break;
                case 2:
                    self.customerModel.nickName = textField.text;
                    break;
                case 3:
                    self.customerModel.cellphone = textField.text;
                    break;
                case 4:
                    self.customerModel.email = textField.text;
                    break;
                case 5:
                    self.customerModel.customerDescription = textField.text;
                    break;
                case 6:
                    self.customerModel.channel = textField.text;
                    break;
                    
                default:
                    break;
            }
        }
        
        [self.tableView reloadData];
    }]];
    
    [alert addTextFieldWithConfigurationHandler:nil];
    [self presentViewController:alert animated:YES completion:nil];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return NO;
    }
    
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        if (indexPath.section == 1) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.customerModel.customField];
            [array removeObjectAtIndex:indexPath.row];
            self.customerModel.customField = array;
            [tableView reloadData];
        }
    }
}

- (NSMutableArray *)customerInfo {
    if (!_customerInfo) {
        _customerInfo = [NSMutableArray arrayWithObjects:@"sdkToken",@"customerToken",@"nickName",@"cellphone",@"email",@"description",@"channel", nil];
    }
    return _customerInfo;
}

- (UdeskCustomer *)customerModel {
    if (!_customerModel) {
        _customerModel = [UdeskCustomer new];
    }
    return _customerModel;
}

@end
