//
//  NSAttributedString+UdeskHTML.m
//  HTMLDemo
//
//  Created by xuchen on 2018/12/18.
//  Copyright © 2018 Udesk. All rights reserved.
//

#import "NSAttributedString+UdeskHTML.h"
#include <libxml/HTMLparser.h>

#import "UdeskImageUtil.h"
#import "UIColor+UdeskSDK.h"
#import "UdeskSDKUtil.h"

@implementation NSAttributedString (UdeskHTML)

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)htmlString customFont:(UIFont *)customFont
{
    if (!htmlString || htmlString == (id)kCFNull) {
        return [[NSAttributedString alloc] initWithString:@"" attributes:nil];
    }
    
    if (!customFont || customFont == (id)kCFNull) {
        customFont = [UIFont systemFontOfSize:15];
    }
    
    NSData *documentData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    xmlDoc *document = htmlReadMemory(documentData.bytes, (int)documentData.length, nil, "UTF-8", HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    
    if (document == NULL) {
        return [[NSAttributedString alloc] initWithString:htmlString attributes:nil];
    }
    
    NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] init];
    
    xmlNodePtr currentNode = document->children;
    while (currentNode != NULL) {
        NSAttributedString *childString = [self attributedStringFromNode:currentNode customFont:customFont];
        [finalAttributedString appendAttributedString:childString];
        
        currentNode = currentNode->next;
    }
    
    xmlFreeDoc(document);
    
    return finalAttributedString;
}

+ (NSAttributedString *)attributedStringFromNode:(xmlNodePtr)xmlNode customFont:(UIFont *)customFont
{
    NSMutableAttributedString *nodeAttributedString = [[NSMutableAttributedString alloc] init];
    
    if ((xmlNode->type != XML_ENTITY_REF_NODE) && ((xmlNode->type != XML_ELEMENT_NODE) && xmlNode->content != NULL)) {
        NSAttributedString *normalAttributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithCString:(const char *)xmlNode->content encoding:NSUTF8StringEncoding] attributes:@{NSFontAttributeName : customFont}];
        [nodeAttributedString appendAttributedString:normalAttributedString];
    }
    
    //解析子集
    xmlNodePtr currentNode = xmlNode->children;
    while (currentNode != NULL) {
        NSAttributedString *childString = [self attributedStringFromNode:currentNode customFont:customFont];
        [nodeAttributedString appendAttributedString:childString];
        
        currentNode = currentNode->next;
    }
    
    if (xmlNode->type == XML_ELEMENT_NODE) {
        
        NSRange nodeAttributedStringRange = NSMakeRange(0, nodeAttributedString.length);
        
        //构建标签容器
        NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
        if (xmlNode->properties != NULL) {
            xmlAttrPtr attribute = xmlNode->properties;
            
            while (attribute != NULL) {
                NSString *attributeValue = @"";
                
                if (attribute->children != NULL) {
                    attributeValue = [NSString stringWithCString:(const char *)attribute->children->content encoding:NSUTF8StringEncoding];
                }
                NSString *attributeName = [[NSString stringWithCString:(const char*)attribute->name encoding:NSUTF8StringEncoding] lowercaseString];
                [attributeDictionary setObject:attributeValue forKey:attributeName];
                
                attribute = attribute->next;
            }
        }
        
        //加粗标签
        if (strncmp("strong", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            if (customFont) {
                UIFont *boldFont = [UIFont boldSystemFontOfSize:customFont.pointSize];
                [nodeAttributedString addAttribute:NSFontAttributeName value:boldFont range:nodeAttributedStringRange];
            }
        }
        //列表
        else if (strncmp("li", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            [nodeAttributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"● "] atIndex:0];
        }
        
        //有序列表
        else if (strncmp("ol", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
//            1.
            @try {
             
                if ([nodeAttributedString.string rangeOfString:@"\n"].location != NSNotFound) {
                    [nodeAttributedString replaceCharactersInRange:[nodeAttributedString.string rangeOfString:@"\n"] withString:@""];
                }
                
                NSMutableArray *array = [NSMutableArray arrayWithArray:[nodeAttributedString.string componentsSeparatedByString:@"\n"]];
                if ([array.lastObject isEqualToString:@""]) {
                    [array removeLastObject];
                }
                for (NSString *string in array) {
                    if ([nodeAttributedString.string rangeOfString:@"\n"].location != NSNotFound) {
                        [nodeAttributedString replaceCharactersInRange:[nodeAttributedString.string rangeOfString:@"● "] withString:[NSString stringWithFormat:@"%ld. ",[array indexOfObject:string]+1]];
                    }
                }
                
            } @catch (NSException *exception) {
                NSLog(@"%@",exception);
            } @finally {
            }
        }
        
        //无序列表
        else if (strncmp("ul", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
//            ●
            if ([nodeAttributedString.string rangeOfString:@"\n"].location != NSNotFound) {
                [nodeAttributedString replaceCharactersInRange:[nodeAttributedString.string rangeOfString:@"\n"] withString:@""];
            }
        }
        
        //样式标签
        else if (strncmp("span", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            
            @try {
                
                //解析颜色
                if ([attributeDictionary.allKeys containsObject:@"style"]) {
                    NSString *style = attributeDictionary[@"style"];
                    NSArray *array = [style componentsSeparatedByString:@";"];
                    for (NSString *tagStr in array) {
                        //7是：“#ff9900” 的length
                        if ([tagStr hasPrefix:@"color"] && [tagStr rangeOfString:@"#"].location != NSNotFound) {
                            if (tagStr.length >= ([tagStr rangeOfString:@"#"].length+7)) {
                                NSString *s = [tagStr substringWithRange:NSMakeRange([tagStr rangeOfString:@"#"].location, 7)];
                                UIColor *color = [UIColor udColorWithHexString:s];
                                [nodeAttributedString addAttribute:NSForegroundColorAttributeName value:color range:nodeAttributedStringRange];
                            }
                        } else if ([tagStr hasPrefix:@"background-color"] && [tagStr rangeOfString:@"#"].location != NSNotFound) {
                            if (tagStr.length >= ([tagStr rangeOfString:@"#"].length+7)) {
                                NSString *s = [tagStr substringWithRange:NSMakeRange([tagStr rangeOfString:@"#"].location, 7)];
                                UIColor *color = [UIColor udColorWithHexString:s];
                                [nodeAttributedString addAttribute:NSBackgroundColorAttributeName value:color range:nodeAttributedStringRange];
                            }
                        }
                    }
                }
                
                //流程
                if ([attributeDictionary.allKeys containsObject:@"data-type"] && [attributeDictionary.allKeys containsObject:@"class"]) {
                    
                    NSString *class = [NSString stringWithFormat:@"%@",attributeDictionary[@"class"]];
                    if ([class isEqualToString:@"flow-item"]) {
                        
                        NSString *dataType = attributeDictionary[@"data-type"];
                        NSString *dataId = attributeDictionary[@"data-id"];
                        
                        NSString *value = [NSString stringWithFormat:@"data-type:%@;dataId:%@",dataType,dataId];
                        [nodeAttributedString addAttribute:NSLinkAttributeName value:value range:nodeAttributedStringRange];
                        [nodeAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:nodeAttributedStringRange];
                    }
                }

                //跳转
                if (([attributeDictionary.allKeys containsObject:@"data-message-type"] || [attributeDictionary.allKeys containsObject:@"data-replace-type"]) && [attributeDictionary.allKeys containsObject:@"class"]) {

//                    NSString *class = [NSString stringWithFormat:@"%@",attributeDictionary[@"class"]];
                    NSString *replaceType = [NSString stringWithFormat:@"%@",attributeDictionary[@"data-replace-type"]];
                    NSString *messageType = [NSString stringWithFormat:@"%@",attributeDictionary[@"data-message-type"]];
                    if ([replaceType isEqualToString:@"QUESTION"] || [messageType isEqualToString:@"1"]) {
                        
                        NSString *dataContent = attributeDictionary[@"data-content"];
                        NSString *value = [NSString stringWithFormat:@"data-message-type:%@;data-content:%@",messageType,dataContent];
                        value = [[value stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        [nodeAttributedString addAttribute:NSLinkAttributeName value:value range:nodeAttributedStringRange];
                        [nodeAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:nodeAttributedStringRange];
                    }
                }
                if ([attributeDictionary.allKeys containsObject:@"data-udesk-go-chat"]) {
                    NSString *gochatValue = [NSString stringWithFormat:@"%@",attributeDictionary[@"data-udesk-go-chat"]];
                    if ([@"true" isEqualToString:gochatValue]) {
                        [nodeAttributedString addAttribute:NSLinkAttributeName value:@"gotochat://" range:nodeAttributedStringRange];
                    }
                }
            } @catch (NSException *exception) {
                NSLog(@"%@",exception);
            } @finally {
            }
        }
        
        //段落标签
        else if (strncmp("p", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            
            @try {
                
                NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                
                if ([attributeDictionary objectForKey:@"align"]) {
                    NSString *alignString = [attributeDictionary[@"align"] lowercaseString];
                    
                    if ([alignString isEqualToString:@"left"]) {
                        paragraphStyle.alignment = NSTextAlignmentLeft;
                    }
                    else if ([alignString isEqualToString:@"center"]) {
                        paragraphStyle.alignment = NSTextAlignmentCenter;
                    }
                    else if ([alignString isEqualToString:@"right"]) {
                        paragraphStyle.alignment = NSTextAlignmentRight;
                    }
                    else if ([alignString isEqualToString:@"justify"]) {
                        paragraphStyle.alignment = NSTextAlignmentJustified;
                    }
                }
                if ([attributeDictionary objectForKey:@"linebreakmode"]) {
                    NSString *lineBreakModeString = [attributeDictionary[@"linebreakmode"] lowercaseString];
                    
                    if ([lineBreakModeString isEqualToString:@"wordwrapping"]) {
                        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    }
                    else if ([lineBreakModeString isEqualToString:@"charwrapping"]) {
                        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
                    }
                    else if ([lineBreakModeString isEqualToString:@"clipping"]) {
                        paragraphStyle.lineBreakMode = NSLineBreakByClipping;
                    }
                    else if ([lineBreakModeString isEqualToString:@"truncatinghead"]) {
                        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingHead;
                    }
                    else if ([lineBreakModeString isEqualToString:@"truncatingtail"]) {
                        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
                    }
                    else if ([lineBreakModeString isEqualToString:@"truncatingmiddle"]) {
                        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
                    }
                }
                
                if ([attributeDictionary objectForKey:@"firstlineheadindent"]) {
                    paragraphStyle.firstLineHeadIndent = [attributeDictionary[@"firstlineheadindent"] doubleValue];
                }
                if ([attributeDictionary objectForKey:@"headindent"]) {
                    paragraphStyle.headIndent = [attributeDictionary[@"headindent"] doubleValue];
                }
                if ([attributeDictionary objectForKey:@"hyphenationfactor"]) {
                    paragraphStyle.hyphenationFactor = [attributeDictionary[@"hyphenationfactor"] doubleValue];
                }
                if ([attributeDictionary objectForKey:@"lineheightmultiple"]) {
                    paragraphStyle.lineHeightMultiple = [attributeDictionary[@"lineheightmultiple"] doubleValue];
                }
                if ([attributeDictionary objectForKey:@"linespacing"]) {
                    paragraphStyle.lineSpacing = [attributeDictionary[@"linespacing"] doubleValue];
                }
                if ([attributeDictionary objectForKey:@"maximumlineheight"]) {
                    paragraphStyle.maximumLineHeight = [attributeDictionary[@"maximumlineheight"] doubleValue];
                }
                if ([attributeDictionary objectForKey:@"minimumlineheight"]) {
                    paragraphStyle.minimumLineHeight = [attributeDictionary[@"minimumlineheight"] doubleValue];
                }
                if ([attributeDictionary objectForKey:@"paragraphspacing"]) {
                    paragraphStyle.paragraphSpacing = [attributeDictionary[@"paragraphspacing"] doubleValue];
                }
                if ([attributeDictionary objectForKey:@"paragraphspacingbefore"]) {
                    paragraphStyle.paragraphSpacingBefore = [attributeDictionary[@"paragraphspacingbefore"] doubleValue];
                }
                if ([attributeDictionary objectForKey:@"tailindent"]) {
                    paragraphStyle.tailIndent = [attributeDictionary[@"tailindent"] doubleValue];
                }
                
                [nodeAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:nodeAttributedStringRange];
                
                //段落换行
                [nodeAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                
            } @catch (NSException *exception) {
                NSLog(@"%@",exception);
            } @finally {
            }
        }
        
        //链接标签
        else if (strncmp("a href", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            
//            xmlChar *value = xmlNodeListGetString(xmlNode->doc, xmlNode->xmlChildrenNode, 1);
//            if (value) {
//
//                NSString *title = [NSString stringWithCString:(const char *)value encoding:NSUTF8StringEncoding];
//                NSString *link = attributeDictionary[@"href"];
//                [nodeAttributedString addAttribute:NSLinkAttributeName value:link range:NSMakeRange(0, title.length)];
//            }
            
            NSString *link = attributeDictionary[@"href"];
            if (link) {
                link = [UdeskSDKUtil urlEncode:link];
//                link = [link stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`%^{}\"[]|\\<> "].invertedSet];
                
                [nodeAttributedString addAttribute:NSLinkAttributeName value:link range:nodeAttributedStringRange];
                [nodeAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:nodeAttributedStringRange];
            }
        }
        
        //换行标签
        else if (strncmp("br", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            [nodeAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        
        //图片标签
        else if (strncmp("img", (const char *)xmlNode->name, strlen((const char *)xmlNode->name)) == 0) {
            
            @try {
                
                NSString *src = attributeDictionary[@"src"];
                if (src != nil) {
                    
                    src = [[src stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSError *error = nil;
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:src] options:0 error:&error];
                    UIImage *image = [UIImage imageWithData:data];
                    
                    if (image != nil) {
                        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
                        imageAttachment.image = image;
                        
                        CGSize imageSize = [UdeskImageUtil richImageSize:image];
                        imageAttachment.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
                        
                        NSAttributedString *imageAttributeString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
                        [nodeAttributedString appendAttributedString:imageAttributeString];
                        
                        NSString *imgLink = [@"img:" stringByAppendingString:src];
                        [nodeAttributedString addAttribute:NSLinkAttributeName value:imgLink range:NSMakeRange(0, imageAttributeString.length)];
                    }
                }
                
            } @catch (NSException *exception) {
                NSLog(@"%@",exception);
            } @finally {
            }
        }
    }
    
    return nodeAttributedString;
}

@end
