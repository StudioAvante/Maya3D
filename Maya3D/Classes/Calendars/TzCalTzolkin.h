//
//  TzCalTzolkin.h
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"

@interface TzCalTzolkin : NSObject {
	// Misc
	int firstKin;				// Tzolkin KIN on 0.0.0.0.0
	int firstCR;				// Tzolkin KIN on 0.0.0.0.0
	// Current Date
	int kin;					// 1-260
	int number;					// 1-13
	int day;					// 1-20
	// Calendar Round
	int calendarRoundKin;		// 1 - 18980 (52*365)
	int calendarRound;			// current, since 0.0.0.0.0 + TZFIRSTCR
	// Day info
	int color;					// 1-4 (color & direction)
	BOOL good;
	// Gear Angle
	CGFloat angleNumber;		// Angulo da engrenagem - Number
	CGFloat angleDay;			// Angulo da engrenagem - Day
}

@property (nonatomic) int kin;
@property (nonatomic) int number;
@property (nonatomic) int day;
@property (nonatomic) int color;
@property (nonatomic) int calendarRound;
@property (nonatomic) int calendarRoundKin;
@property (nonatomic) CGFloat angleNumber;
@property (nonatomic) CGFloat angleDay;
@property (nonatomic, readonly, getter=dayName_get)			NSString *dayName;
@property (nonatomic, readonly, getter=dayNameFull_get)		NSString *dayNameFull;
@property (nonatomic, readonly, getter=dayMeaning_get)		NSString *dayMeaning;
@property (nonatomic, readonly, getter=dayAnimal_get)		NSString *dayAnimal;
@property (nonatomic, readonly, getter=dayEnergy_get)		NSString *dayEnergy;
@property (nonatomic, readonly, getter=colorName_get)		NSString *colorName;
@property (nonatomic, readonly, getter=directionName_get)	NSString *directionName;
@property (nonatomic, readonly, getter=elementName_get)		NSString *elementName;
@property (nonatomic, readonly, getter=personality_get)		NSString *personality;
@property (nonatomic, readonly, getter=goodDayTo1_get)		NSString *goodDayTo1;
@property (nonatomic, readonly, getter=goodDayTo2_get)		NSString *goodDayTo2;
@property (nonatomic, readonly, getter=goodDayTo3_get)		NSString *goodDayTo3;
@property (nonatomic, readonly, getter=goodDayTo4_get)		NSString *goodDayTo4;
// Images names
@property (nonatomic, readonly, getter=imgNum_get)			NSString *imgNum;
@property (nonatomic, readonly, getter=imgNumSide_get)		NSString *imgNumSide;
@property (nonatomic, readonly, getter=imgNumGlyph_get)		NSString *imgNumGlyph;
@property (nonatomic, readonly, getter=imgGlyph_get)		NSString *imgGlyph;
@property (nonatomic, readonly, getter=imgNews_get)			NSString *imgNews;
@property (nonatomic, readonly, getter=imgThumb_get)		NSString *imgThumb;


- (id)init:(int)j;
- (void)updateWithJulian:(int)j;
// Constantes
+(NSString*) constDayName:(int)i;
+(NSString*) constDayMeaning:(int)i;
+(NSString*) constDayAnimal:(int)i;
+(NSString*) constDayEnergy:(int)i;
+(NSString*) constColorName:(int)i;
+(NSString*) constDirectionName:(int)i;
+(NSString*) constElementName:(int)i;
+(NSString*) constPersonality:(int)i;
+(NSString*) constGoodDayTo:(int)i :(int)n;


@end
