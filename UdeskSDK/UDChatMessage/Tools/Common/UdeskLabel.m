//
//  UdeskLabel.m
//  UdeskSDK
//
//  Created by xuchen on 16/3/15.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskLabel.h"
#import <CoreText/CoreText.h>
#import "UdeskTools.h"

@interface UdeskLabel ()

@property (nonatomic, assign) NSRange                   movieStringRange;//当前选中的字符索引
@property (nonatomic, strong) NSMutableArray            *ranges;//所有链接文本的位置数组
@property (nonatomic, assign) NSInteger                 lastLineWidth;//最后一行文本的宽度
@property (nonatomic, strong) NSMutableAttributedString *attrString;//文本属性字符串
@property (nonatomic, strong) NSArray                   *row;//所有行的数组
@property (nonatomic, strong) UIColor                   *linkColor;//超链接文本颜色
@property (nonatomic, strong) UIColor                   *passColor;//鼠标经过链接文本颜色
@property (nonatomic, strong) NSArray                   *regexStrArray;//正则表达式 数组
@end

@implementation UdeskLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //开启当前点击的手势
        self.userInteractionEnabled = YES;
        self.matchArray = [NSMutableArray array];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturedDetected:)]; // 手势类型随你喜欢。
        
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}

#pragma mark - 绘制视图
- (void)drawRect:(CGRect)rect
{
    //当前文本超链接文字的颜色默认为purpleColor
    self.linkColor = [UIColor blueColor];
    //自定义当前超链接文本颜色
    if ([self.udLabelDelegate respondsToSelector:@selector(linkColorWithUDLabel:)]) {
        self.linkColor = [self.udLabelDelegate linkColorWithUDLabel:self];
    }
    
    //当前文本超链接文字手指经过的颜色默认为greenColor
    self.passColor = [UIColor lightGrayColor];
    //自定义当前超链接文本颜色
    if ([self.udLabelDelegate respondsToSelector:@selector(passColorWithUDLabel:)]) {
        self.passColor = [self.udLabelDelegate passColorWithUDLabel:self];
    }
    if (self.text == nil) {
        return;
    }
    //生成属性字符串对象
    self.attrString = [[NSMutableAttributedString alloc]initWithString:self.text];
    
    //------------------------设置字体属性--------------------------
//    CTFontRef font = CTFontCreateWithName(CFSTR("Georgia"), 15, NULL);
    //设置当前字体
    [_attrString addAttribute:(id)kCTFontAttributeName value:self.font range:NSMakeRange(0, _attrString.length)];
    //设置当前文本的颜色
    [_attrString addAttribute:(id)kCTForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, _attrString.length)];
    
    
    //----------------------设置链接文本的颜色-------------------
    //判断当前链接文本表达式是否实现
    if ([self.udLabelDelegate respondsToSelector:@selector(contentsOfRegexStringWithUDLabel:)] && [self.udLabelDelegate contentsOfRegexStringWithUDLabel:self] != nil)
    {
        //获取所有的链接文本
        NSArray *contents = [self contentsOfRegexStrArray];

        //获取所有文本的的索引集合
        NSArray *ranges = [self rangesOfContents:contents];
        //NSLog(@"ranges %@",ranges);
        for (NSValue *value in ranges) {
            NSRange range = [value rangeValue];
            //设置字体的颜色
            [_attrString addAttribute:(id)kCTForegroundColorAttributeName value:(id)self.linkColor range:range];

        }
        
        //设置选中经过字体颜色
        [_attrString addAttribute:(id)kCTForegroundColorAttributeName value:(id)self.passColor range:self.movieStringRange];
        
    }
    
    //------------------------设置段落属性-----------------------------
    //指定为对齐属性
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec=kCTParagraphStyleSpecifierFirstLineHeadIndent;//指定为对齐属性
    alignmentStyle.valueSize=sizeof(alignment);
    alignmentStyle.value=&alignment;
    
    
    //行距
    self.linespace = 10.0f;
    CTParagraphStyleSetting lineSpaceSetting;
    lineSpaceSetting.spec = kCTParagraphStyleSpecifierLineSpacing;
    lineSpaceSetting.value = &_linespace;
    lineSpaceSetting.valueSize = sizeof(_linespace);
    
    //多行高
    self.mutiHeight = 1.0f;
    CTParagraphStyleSetting Muti;
    Muti.spec = kCTParagraphStyleSpecifierLineHeightMultiple;
    Muti.value = &_mutiHeight;
    Muti.valueSize = sizeof(float);
    
    //换行模式
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByWordWrapping;
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    
    //组合设置
    CTParagraphStyleSetting settings[] = {
        lineSpaceSetting,Muti,alignmentStyle,lineBreakMode
    };
    
    //通过设置项产生段落样式对象
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 4);
    
    // build attributes
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName ];
    
    // set attributes to attributed string
    [_attrString addAttributes:attributes range:NSMakeRange(0, _attrString.length)];
    
    CFRelease(style);
    //生成CTFramesetterRef对象
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attrString);
    

    //然后创建一个CGPath对象，这个Path对象用于表示可绘制区域坐标值、长宽。
    CGRect bouds = CGRectInset(self.bounds, 0.0f, 0.0f);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, bouds);
    
    //使用上面生成的setter和path生成一个CTFrameRef对象，这个对象包含了这两个对象的信息（字体信息、坐标信息）
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    //获取当前(View)上下文以便于之后的绘画，这个是一个离屏。
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
    //压栈，压入图形状态栈中.每个图形上下文维护一个图形状态栈，并不是所有的当前绘画环境的图形状态的元素都被保存。图形状态中不考虑当前路径，所以不保存
    //保存现在得上下文图形状态。不管后续对context上绘制什么都不会影响真正得屏幕。
    CGContextSaveGState(context);
    //x，y轴方向移动
    CGContextTranslateCTM(context , 0 ,self.frame.size.height );
    //缩放x，y轴方向缩放，－1.0为反向1.0倍,坐标系转换,沿x轴翻转180度
    CGContextScaleCTM(context, 1.0 ,-1.0);
    //可以使用CTFrameDraw方法绘制了。
    CTFrameDraw(frame,context);
    
    //获取当前行的集合
    self.row = (NSArray *)CTFrameGetLines(frame);
    
    CGRect lineBounds = CTLineGetImageBounds((CTLineRef)[self.row lastObject], context);
    _lastLineWidth = lineBounds.size.width;
    
    //－－－－－－－－－－－－－－－获取当前文本的高度－－－－－－－－－－－－－－－－－－
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    //获取当前的行高
    float lineHeight = self.font.pointSize + self.linespace + 2;
    self.textHeight = CFArrayGetCount(lines) * lineHeight ;

    //释放对象
    CGPathRelease(path);
    CFRelease(framesetter);
    CFRelease(frame);
    

}
#pragma mark - 检索当前链接文本
//返回所有的链接字符串数组
- (NSArray *)contentsOfRegexStrArray
{
    //需要添加链接字符串正则表达：@用户、http://、#话题#
    NSString *regex = [self.udLabelDelegate contentsOfRegexStringWithUDLabel:self];
    
    NSError *error = NULL;
    NSArray* match;
    if (regex != nil){
        
        NSRegularExpression *regexs = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
        match = [regexs matchesInString:[self.attrString string] options:NSMatchingReportCompletion range:NSMakeRange(0, [[self.attrString string] length])];

    }
    
    if (match.count != 0)
    {
        for (NSTextCheckingResult *matc in match)
        {
            
            [self.matchArray addObject:[[self.attrString string] substringWithRange:matc.range]];
        }  
    }

    return self.matchArray;
}

//获取所有链接文字的位置
- (NSArray *)rangesOfContents:(NSArray *)contents
{
    if (_ranges == nil) {
        _ranges = [[NSMutableArray alloc]init];
    }
    [_ranges removeAllObjects];
    
    for (NSString *content in contents) {
        //获取当前字符串在文本中的位置
        NSRange range = [[self.attrString string] rangeOfString: content];
        NSValue *value = [NSValue valueWithRange:range];
        //添加到数组中
        [_ranges addObject:value];
    }
    
    return _ranges;
}


#pragma mark - touch Action

- (void)tapGesturedDetected:(UITapGestureRecognizer *)recognizer {
    
    CGPoint point = [recognizer locationInView:self];
    //获取当前选中字符的范围
    NSRange range = [self touchInLabelText:point];
    self.movieStringRange = NSMakeRange(0, 0);
    if (range.length == 0) {
    }else
    {
        //判断当前代理方法是否实现
        if ([self.udLabelDelegate respondsToSelector:@selector(toucheBenginUDLabel:withContext:)]) {
            //获取当前点击字符串
            NSString *context = [[self.attrString string] substringWithRange:range];
            //调用点击开始代理方法
            [self.udLabelDelegate toucheBenginUDLabel:self withContext:context];
        }
    }

}

#pragma mark - 检索当前点击的是否是链接文本
//检查当前点击的是否是连接文本,如果是返回文本的位置
- (NSRange)touchInLabelText:(CGPoint)point
{
    //获取当前的行高
    float lineHeight = self.font.pointSize + self.linespace;
    
    int indexLine = point.y / lineHeight;
    //NSLog(@"indexLine:%d",indexLine);
    
    //如果当前行数大于最大行数
    if (indexLine >= _row.count) {
        return NSMakeRange(0, 0);
    }
    //如果当前行是最后一行and点击位置的横坐标大于当前行文本最大的位置
    if (indexLine == _row.count - 1 && point.x > _lastLineWidth) {
        return NSMakeRange(0, 0);
    }
    
    //如果点击在当前行文字的上方空白位置
//    if (point.y <= indexLine *lineHeight + (asc+des+lead) * (_mutiHeight - 1.0f)) {
//        return NSMakeRange(0, 0);
//    }
    
    //获取当前行
    CTLineRef selectLine = CFArrayGetValueAtIndex((__bridge CFArrayRef)_row, indexLine);
    CFIndex selectCharIndex = CTLineGetStringIndexForPosition(selectLine, point);
    
    
    //获取当前行结束字符位置
    CFIndex endIndex = CTLineGetStringIndexForPosition(selectLine, CGPointMake(self.frame.size.width-1, 1));
    
    
    //获取整段文字中charIndex位置的字符相对line的原点的x值
    CGFloat beginset;
    do {
        //获取当前选中字符距离起点位置
        CTLineGetOffsetForStringIndex(selectLine,selectCharIndex,&beginset);
        //判断当前字符的开始位置是否小于点击位置
        if (point.x >= beginset) {
            //判断当前字符是否为最后一个字符
            if (selectCharIndex == endIndex) {
                break;
            }
            //判断当前字符的结束位置是否大于点击位置
            CGFloat endset;
            CTLineGetOffsetForStringIndex(selectLine,selectCharIndex + 1,&endset);
            if (point.x <= endset) {
                break;
            }else
            {
                selectCharIndex++;
            }
        }else
        {
            selectCharIndex--;
        }
        
    } while (YES);
    
    //判断当前点击的位置是否在链接文本位置
    for (NSValue *value in _ranges) {
        NSRange range = [value rangeValue];
        if (range.location <= selectCharIndex && selectCharIndex + 1 <= range.location + range.length) {
            return range;
        }
    }
    
    
    return NSMakeRange(0, 0);
}

#pragma mark - 当前手指触摸文本
//复写当前选中的链接文本的索引
- (void)setMovieStringRange:(NSRange)movieStringRange
{
    if (_movieStringRange.location != movieStringRange.location || _movieStringRange.length != movieStringRange.length) {
        _movieStringRange = movieStringRange;
        [self setNeedsDisplay];
    }
}

#pragma mark - 计算文本高度
#define kHeightDic @"kHeightDic"

+ (float)getAttributedStringHeightWithString:(NSString *)text
                                  WidthValue:(float)width
                                    delegate:(id<UDLabelDelegate>)delegate
                                        font:(UIFont*)font
{
    int total_height = 0;

    if (![UdeskTools isBlankString:text]) {
    
        //生成属性字符串对象
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:text];
        
        //------------------------设置字体属性--------------------------
        //    CTFontRef font = CTFontCreateWithName(CFSTR("Georgia"), 15, NULL);
        //设置当前字体
        [attrString addAttribute:(id)kCTFontAttributeName value:font range:NSMakeRange(0, attrString.length)];
        
        //------------------------设置段落属性-----------------------------
        //指定为对齐属性
        CTTextAlignment alignment = kCTJustifiedTextAlignment;
        CTParagraphStyleSetting alignmentStyle;
        alignmentStyle.spec=kCTParagraphStyleSpecifierFirstLineHeadIndent;//指定为对齐属性
        alignmentStyle.valueSize=sizeof(alignment);
        alignmentStyle.value=&alignment;
        
        
        //行距
        float linespace = 10.0f;
        CTParagraphStyleSetting lineSpaceSetting;
        lineSpaceSetting.spec = kCTParagraphStyleSpecifierLineSpacing;
        lineSpaceSetting.value = &linespace;
        lineSpaceSetting.valueSize = sizeof(linespace);
        
        //多行高
        float mutiHeight = 1.0f;
        CTParagraphStyleSetting Muti;
        Muti.spec = kCTParagraphStyleSpecifierLineHeightMultiple;
        Muti.value = &mutiHeight;
        Muti.valueSize = sizeof(float);
        
        //换行模式
        CTParagraphStyleSetting lineBreakMode;
        CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
        lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
        lineBreakMode.value = &lineBreak;
        lineBreakMode.valueSize = sizeof(CTLineBreakMode);
        
        //组合设置
        CTParagraphStyleSetting settings[] = {
            lineSpaceSetting,Muti,alignmentStyle,lineBreakMode
        };
        
        //通过设置项产生段落样式对象
        CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 4);
        
        // build attributes
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName ];
        
        // set attributes to attributed string
        [attrString addAttributes:attributes range:NSMakeRange(0, attrString.length)];
        
        CFRelease(style);
        
        //生成CTFramesetterRef对象
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
        CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
        
        //然后创建一个CGPath对象，这个Path对象用于表示可绘制区域坐标值、长宽。
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, drawingRect);
        
        
        CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
        CGPathRelease(path);
        CFRelease(framesetter);
        
        NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
        
        CGPoint origins[[linesArray count]];
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
        
        int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
        
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        
        CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        total_height = 1000 - line_y + (int) descent +1;    //+1为了纠正descent转换成int小数点后舍去的值
        
        CFRelease(textFrame);

    }
    
    return total_height;
    
}

@end
