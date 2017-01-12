//
//  XPathQuery.h
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NSArray *ud_PerformHTMLXPathQuery(NSData *document, NSString *query);
NSArray *ud_PerformHTMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding);
NSArray *ud_PerformXMLXPathQuery(NSData *document, NSString *query);
NSArray *ud_PerformXMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding);
