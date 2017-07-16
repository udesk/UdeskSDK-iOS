//
//  UdeskSpectrumView.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskSpectrumView.h"
#import "UdeskTimerLabel.h"
#import "UIColor+UdeskSDK.h"

@interface UdeskSpectrumView ()

@property (nonatomic, strong) NSMutableArray * levelArray;
@property (nonatomic) NSMutableArray * itemArray;
@property (nonatomic) CGFloat itemHeight;
@property (nonatomic) CGFloat itemWidth;

@end

@implementation UdeskSpectrumView


- (id)init
{
    if(self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    
    @try {
        
        self.itemArray = [NSMutableArray new];
        
        self.numberOfItems = 20;//偶数
        
        self.itemColor = [UIColor colorWithHexString:@"#007AFF"];
        
        self.itemHeight = CGRectGetHeight(self.bounds);
        self.itemWidth  = CGRectGetWidth(self.bounds);
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.itemWidth*0.3, 0, self.itemWidth*0.5, self.itemHeight)];
        self.timeLabel.text = @"0:00";
        self.timeLabel.font = [UIFont systemFontOfSize:16];
        [self.timeLabel setTextColor:[UIColor grayColor]];
        [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.timeLabel];
        
        self.stopwatch = [[UdeskTimerLabel alloc] initWithLabel:self.timeLabel];
        self.stopwatch.timeFormat = @"m:ss";
        
        self.levelArray = [[NSMutableArray alloc]init];
        for(int i = 0 ; i < self.numberOfItems/2 ; i++){
            [self.levelArray addObject:@(1)];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}
-(void)setItemLevelCallback:(void (^)())itemLevelCallback
{
    
    @try {
        
        _itemLevelCallback = itemLevelCallback;
        
        CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:_itemLevelCallback selector:@selector(invoke)];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0f) {
            displaylink.preferredFramesPerSecond = 6;
        }
        else {
            displaylink.frameInterval = 6;
        }
        
        [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        for(int i=0; i < self.numberOfItems; i++)
        {
            CAShapeLayer *itemline = [CAShapeLayer layer];
            itemline.lineCap       = kCALineCapButt;
            itemline.lineJoin      = kCALineJoinRound;
            itemline.strokeColor   = [[UIColor clearColor] CGColor];
            itemline.fillColor     = [[UIColor clearColor] CGColor];
            //单个波浪的宽度
            [itemline setLineWidth:self.itemWidth*0.3/self.numberOfItems];
            itemline.strokeColor   = [self.itemColor CGColor];
            
            [self.layer addSublayer:itemline];
            [self.itemArray addObject:itemline];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)setLevel:(CGFloat)level
{
    @try {
        level = (level+43)*3.2;
        if( level < 0 ) level = 0;
        
        [self.levelArray removeObjectAtIndex:self.numberOfItems/2-1];
        [self.levelArray insertObject:@((level / 6) < 1 ? 1 : level / 6) atIndex:0];
        
        [self updateItems];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}


- (void)setText:(NSString *)text{
    self.timeLabel.text = text;
}


- (void)updateItems
{

    //NSLog(@"updateMeters");
    
    @try {
        
        UIGraphicsBeginImageContext(self.frame.size);
        
        int x = self.itemWidth*0.7/self.numberOfItems;
        int z = self.itemWidth*0.25/self.numberOfItems;
        int y = self.itemWidth*0.7 - z;
        
        for(int i=0; i < (self.numberOfItems / 2); i++) {
            
            UIBezierPath *itemLinePath = [UIBezierPath bezierPath];
            
            y += x;
            
            [itemLinePath moveToPoint:CGPointMake(y, self.itemHeight/2+([[self.levelArray objectAtIndex:i]intValue]+1)*z/2)];
            
            [itemLinePath addLineToPoint:CGPointMake(y, self.itemHeight/2-([[self.levelArray objectAtIndex:i]intValue]+1)*z/2)];
            
            CAShapeLayer *itemLine = [self.itemArray objectAtIndex:i];
            itemLine.path = [itemLinePath CGPath];
            
        }
        
        
        y = self.itemWidth*0.4 + z;
        
        for(int i = (int)self.numberOfItems / 2; i < self.numberOfItems; i++) {
            
            UIBezierPath *itemLinePath = [UIBezierPath bezierPath];
            
            y -= x;
            
            [itemLinePath moveToPoint:CGPointMake(y, self.itemHeight/2+([[self.levelArray objectAtIndex:i-self.numberOfItems/2]intValue]+1)*z/2)];
            
            [itemLinePath addLineToPoint:CGPointMake(y, self.itemHeight/2-([[self.levelArray objectAtIndex:i-self.numberOfItems/2]intValue]+1)*z/2)];
            
            CAShapeLayer *itemLine = [self.itemArray objectAtIndex:i];
            itemLine.path = [itemLinePath CGPath];
            
        }
        
        UIGraphicsEndImageContext();
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
