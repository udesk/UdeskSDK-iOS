//
//  UdeskGeneral.m
//  UdeskSDK
//
//  Created by xuchen on 15/12/21.
//  Copyright © 2015年 xuchen. All rights reserved.
//

#import "UdeskStringSizeUtil.h"
#import "UdeskFoundationMacro.h"
#import <CoreText/CoreText.h>

@implementation UdeskStringSizeUtil

+ (CGSize)textSize:(NSString *)text withFont:(UIFont *)font withSize:(CGSize)size {

    CGSize newSize;
    
    if (text.length>0 && font) {
    
        if (ud_isIOS6) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            newSize = [text sizeWithFont:font constrainedToSize:size];
#pragma clang diagnostic pop
        } else {
            newSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
        }
    }
    
    return newSize;
}

+ (float)getAttributedStringHeightWithString:(NSString *)text
                                  WidthValue:(float)width
                                        font:(UIFont*)font
{
    int total_height = 0;
    
    if (text.length) {
        
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        lineSpaceSetting.spec = kCTParagraphStyleSpecifierLineSpacing;
#pragma clang diagnostic pop
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
        CGRect drawingRect = CGRectMake(0, 0, width, 90000);  //这里的高要设置足够大
        
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
        
        total_height = 90000 - line_y + (int) descent +1;    //+1为了纠正descent转换成int小数点后舍去的值
        
        if (total_height>900) {
            total_height+=35;
        }
        
        CFRelease(textFrame);
        
    }
    
    return total_height;
    
}


@end
