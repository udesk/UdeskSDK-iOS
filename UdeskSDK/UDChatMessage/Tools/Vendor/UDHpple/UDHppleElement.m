//
//  TFHppleElement.m
//  Hpple
//
//  Created by Geoffrey Grosenbach on 1/31/09.
//
//  Copyright (c) 2009 Topfunky Corporation, http://topfunky.com
//
//  MIT LICENSE
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "UDHppleElement.h"
#import "UDXPathQuery.h"

static NSString * const UDHppleNodeContentKey           = @"nodeContent";
static NSString * const UDHppleNodeNameKey              = @"nodeName";
static NSString * const UDHppleNodeChildrenKey          = @"nodeChildArray";
static NSString * const UDHppleNodeAttributeArrayKey    = @"nodeAttributeArray";
static NSString * const UDHppleNodeAttributeNameKey     = @"attributeName";

static NSString * const UDHppleTextNodeName            = @"text";

@interface UDHppleElement ()
{    
    NSDictionary * node;
    BOOL isXML;
    NSString *encoding;
    __unsafe_unretained UDHppleElement *parent;
}

@property (nonatomic, unsafe_unretained, readwrite) UDHppleElement *parent;

@end

@implementation UDHppleElement
@synthesize parent;


- (id) initWithNode:(NSDictionary *) theNode isXML:(BOOL)isDataXML withEncoding:(NSString *)theEncoding
{
  if (!(self = [super init]))
    return nil;

    isXML = isDataXML;
    node = theNode;
    encoding = theEncoding;

  return self;
}

+ (UDHppleElement *) hppleElementWithNode:(NSDictionary *) theNode isXML:(BOOL)isDataXML withEncoding:(NSString *)theEncoding
{
  return [[[self class] alloc] initWithNode:theNode isXML:isDataXML withEncoding:theEncoding];
}

#pragma mark -

- (NSString *)raw
{
    return [node objectForKey:@"raw"];
}

- (NSString *) content
{
  return [node objectForKey:UDHppleNodeContentKey];
}


- (NSString *) tagName
{
  return [node objectForKey:UDHppleNodeNameKey];
}

- (NSArray *) children
{
  NSMutableArray *children = [NSMutableArray array];
  for (NSDictionary *child in [node objectForKey:UDHppleNodeChildrenKey]) {
      UDHppleElement *element = [UDHppleElement hppleElementWithNode:child isXML:isXML withEncoding:encoding];
      element.parent = self;
      [children addObject:element];
  }
  return children;
}

- (UDHppleElement *) firstChild
{
  NSArray * children = self.children;
  if (children.count)
    return [children objectAtIndex:0];
  return nil;
}


- (NSDictionary *) attributes
{
  NSMutableDictionary * translatedAttributes = [NSMutableDictionary dictionary];
  for (NSDictionary * attributeDict in [node objectForKey:UDHppleNodeAttributeArrayKey]) {
      if ([attributeDict objectForKey:UDHppleNodeContentKey] && [attributeDict objectForKey:UDHppleNodeAttributeNameKey]) {
          [translatedAttributes setObject:[attributeDict objectForKey:UDHppleNodeContentKey]
                                   forKey:[attributeDict objectForKey:UDHppleNodeAttributeNameKey]];
      }
  }
  return translatedAttributes;
}

- (NSString *) objectForKey:(NSString *) theKey
{
  return [[self attributes] objectForKey:theKey];
}

- (id) description
{
  return [node description];
}

- (BOOL)hasChildren
{
    if ([node objectForKey:UDHppleNodeChildrenKey])
        return YES;
    else
        return NO;
}

- (BOOL)isTextNode
{
    // we must distinguish between real text nodes and standard nodes with tha name "text" (<text>)
    // real text nodes must have content
    if ([self.tagName isEqualToString:UDHppleTextNodeName] && (self.content))
        return YES;
    else
        return NO;
}

- (NSArray*) childrenWithTagName:(NSString*)tagName
{
    NSMutableArray* matches = [NSMutableArray array];
    
    for (UDHppleElement* child in self.children)
    {
        if ([child.tagName isEqualToString:tagName])
            [matches addObject:child];
    }
    
    return matches;
}

- (UDHppleElement *) firstChildWithTagName:(NSString*)tagName
{
    for (UDHppleElement* child in self.children)
    {
        if ([child.tagName isEqualToString:tagName])
            return child;
    }
    
    return nil;
}

- (NSArray*) childrenWithClassName:(NSString*)className
{
    NSMutableArray* matches = [NSMutableArray array];
    
    for (UDHppleElement* child in self.children)
    {
        if ([[child objectForKey:@"class"] isEqualToString:className])
            [matches addObject:child];
    }
    
    return matches;
}

- (UDHppleElement *) firstChildWithClassName:(NSString*)className
{
    for (UDHppleElement* child in self.children)
    {
        if ([[child objectForKey:@"class"] isEqualToString:className])
            return child;
    }
    
    return nil;
}

- (UDHppleElement *) firstTextChild
{
    for (UDHppleElement* child in self.children)
    {
        if ([child isTextNode])
            return child;
    }
    
    return [self firstChildWithTagName:UDHppleTextNodeName];
}

- (NSString *) text
{
    return self.firstTextChild.content;
}

// Returns all elements at xPath.
- (NSArray *) searchWithXPathQuery:(NSString *)xPathOrCSS
{
    
    NSData *data = [self.raw dataUsingEncoding:NSUTF8StringEncoding];

    NSArray * detailNodes = nil;
    if (isXML) {
        detailNodes = ud_PerformXMLXPathQueryWithEncoding(data, xPathOrCSS, encoding);
    } else {
        detailNodes = ud_PerformHTMLXPathQueryWithEncoding(data, xPathOrCSS, encoding);
    }
    
    NSMutableArray * hppleElements = [NSMutableArray array];
    for (id newNode in detailNodes) {
        [hppleElements addObject:[UDHppleElement hppleElementWithNode:newNode isXML:isXML withEncoding:encoding]];
    }
    return hppleElements;
}

// Custom keyed subscripting
- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

@end
