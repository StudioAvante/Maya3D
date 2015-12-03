//
//  TzDatebook.h
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "TzDate.h"
#import "TzDatebook.h"


@interface TzDatebook : NSObject {
	// Datebook
	NSMutableArray *theDatebook;			// Datas do usuario
}

- (void)debugList;
- (void)addDate:(TzDate*)dt;
- (void)updateDate:(int)i :(NSString*)desc;
- (BOOL)removeDate:(int)j;
- (BOOL)removeItem:(int)i;
- (BOOL)dateExists:(int)j;
// NSMutableArray clone
- (unsigned)count;
- (id)objectAtIndex:(unsigned)index;
// XML
- (NSString*)getXMLFilename;
- (BOOL)readFromXML;
- (BOOL)saveToXML;
- (NSDictionary*)makeXMLDictionary;
- (void)debugDatebookDict:(NSMutableDictionary*)dict;

@end
