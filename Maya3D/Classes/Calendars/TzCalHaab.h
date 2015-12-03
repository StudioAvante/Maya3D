//
//  TzCalHaab.h
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"

@class TzCalTzolkin;

@interface TzCalHaab : NSObject {
	int kin;				// 1-365
	int day;				// 0-19 / 0-4
	int uinal;				// 0-18
	int lord;				// 1-9
	// Related kins
	int julianYear;			// year bearer
	TzCalTzolkin *tzYear;	// year bearer
}

@property (nonatomic) int kin;
@property (nonatomic) int day;
@property (nonatomic) int uinal;
@property (nonatomic) int lord;
@property (nonatomic, readonly, getter=getTzYear)			TzCalTzolkin *tzYear;
// METHOS GETTERS
@property (nonatomic, readonly, getter=dayNameFull_get)		NSString *dayNameFull;
@property (nonatomic, readonly, getter=uinalName_get)		NSString *uinalName;
@property (nonatomic, readonly, getter=lordName_get)		NSString *lordName;
@property (nonatomic, readonly, getter=lordNameFull_get)	NSString *lordNameFull;
@property (nonatomic, readonly, getter=uinalDesc_get)		NSString *uinalDesc;
@property (nonatomic, readonly, getter=yearDesc_get)		NSString *yearDesc;
// Image names
@property (nonatomic, readonly, getter=imgNum_get)			NSString *imgNum;
@property (nonatomic, readonly, getter=imgNumSide_get)		NSString *imgNumSide;
@property (nonatomic, readonly, getter=imgNumGlyph_get)		NSString *imgNumGlyph;
@property (nonatomic, readonly, getter=imgGlyph_get)		NSString *imgGlyph;
@property (nonatomic, readonly, getter=imgLordGlyph_get)	NSString *imgLordGlyph;
@property (nonatomic, readonly, getter=imgIsigGlyph_get)	NSString *imgIsigGlyph;


- (id)init:(int)j;
- (void)updateWithJulian:(int)j;
// Constantes
+(NSString*) constUinalName:(int)i;
+(NSString*) constUinalDesc:(int)i;
+(NSString*) constYearDesc:(int)i;

@end
