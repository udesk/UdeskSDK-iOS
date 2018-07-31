//
//  UdeskGoodsMessageTestViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/6/25.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskGoodsMessageTestViewController.h"
#import "UdeskGoodsModel.h"

@interface UdeskGoodsMessageTestViewController ()

@property (nonatomic, strong) UdeskGoodsModel *model;
@property (nonatomic, strong) NSArray *goodsKeys;
@property (nonatomic, strong) NSArray *goodsParamsKeys;

@end

@implementation UdeskGoodsMessageTestViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditGoodsMessage)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(appendGoodsParams)];
     self.navigationItem.rightBarButtonItems = @[done,add];
}

- (void)doneEditGoodsMessage {
    if (self.doneEditGoodsMessageBlock) {
        self.doneEditGoodsMessageBlock(self.model);
    } 
}

- (void)appendGoodsParams {
    
    UdeskGoodsParamModel *paramModel = [UdeskGoodsParamModel new];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.model.params];
    [array addObject:paramModel];
    self.model.params = array;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.params.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.goodsKeys[indexPath.row];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = self.model.goodsId;
        }
        else if (indexPath.row == 1) {
            cell.detailTextLabel.text = self.model.name;
        }
        else if (indexPath.row == 2) {
            cell.detailTextLabel.text = self.model.url;
        }
        else if (indexPath.row == 3) {
            cell.detailTextLabel.text = self.model.imgUrl;
        }
    }
    else {
        cell.textLabel.text = self.goodsParamsKeys[indexPath.row];
        UdeskGoodsParamModel *paramModel = self.model.params[indexPath.section-1];
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = paramModel.text;
        }
        else if (indexPath.row == 1) {
            cell.detailTextLabel.text = paramModel.color;
        }
        else if (indexPath.row == 2) {
            cell.detailTextLabel.text = paramModel.fold.stringValue;
        }
        else if (indexPath.row == 3) {
            cell.detailTextLabel.text = paramModel.udBreak.stringValue;
        }
        else if (indexPath.row == 3) {
            cell.detailTextLabel.text = paramModel.size.stringValue;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"请输入%@的值",cell.textLabel.text] preferredStyle:1];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = alert.textFields.firstObject;
        if (indexPath.section == 0) {
            cell.detailTextLabel.text = textField.text;
            if (indexPath.row == 0) {
                self.model.goodsId = textField.text;
            }
            else if (indexPath.row == 1) {
                self.model.name = textField.text;
            }
            else if (indexPath.row == 2) {
                self.model.url = textField.text;
            }
            else if (indexPath.row == 3) {
                self.model.imgUrl = textField.text;
            }
        }
        else {
            
            UdeskGoodsParamModel *paramModel = self.model.params[indexPath.section-1];
            cell.detailTextLabel.text = textField.text;
            if (indexPath.row == 0) {
                paramModel.text = textField.text;
            }
            else if (indexPath.row == 1) {
                paramModel.color = textField.text;
            }
            else if (indexPath.row == 2) {
                paramModel.fold = [self stringToNumber:textField.text];
            }
            else if (indexPath.row == 3) {
                paramModel.udBreak = [self stringToNumber:textField.text];
            }
            else if (indexPath.row == 4) {
                paramModel.size = [self stringToNumber:textField.text];
            }
        }
        [self.tableView reloadData];
    }]];
    
    [alert addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSNumber *)stringToNumber:(NSString *)string {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *numTemp = [numberFormatter numberFromString:string];
    return numTemp;
}

- (UdeskGoodsModel *)model {
    if (!_model) {
        _model = [UdeskGoodsModel new];
    }
    return _model;
}

- (NSArray *)goodsKeys {
    if (!_goodsKeys) {
        _goodsKeys = @[@"商品ID",@"商品名称",@"商品链接",@"商品图片链接"];
    }
    return _goodsKeys;
}

- (NSArray *)goodsParamsKeys {
    if (!_goodsParamsKeys) {
        _goodsParamsKeys = @[@"商品参数内容",@"商品参数颜色",@"商品参数加粗（0不加粗，1加粗）",@"商品参数换行（该段文本结束后换行，0不换行，1换行）",@"商品参数字体大小"];
    }
    return _goodsParamsKeys;
}

@end
