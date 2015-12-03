//
//  TzCalTzolkinMoon.h
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"
#import "TzCalTzolkin.h"

@interface TzCalTzolkinMoon : TzCalTzolkin {
	// Current Date
	int tone;						// 1-13
	int seal;						// 1-19,0
	int timecell;					// 1-5 > 1-4, ..., 17-20 
	BOOL portal;					// portal de ativacao galactica (VERDES)
	// Related kins
	int julianGuide;
	int julianAntipode;
	int julianAnalog;
	int julianOccult;
	TzCalTzolkinMoon *tzGuide;
	TzCalTzolkinMoon *tzAntipode;
	TzCalTzolkinMoon *tzAnalog;
	TzCalTzolkinMoon *tzOccult;
}

@property (nonatomic) int tone;
@property (nonatomic) int seal;
@property (nonatomic) int timecell;
@property (nonatomic) BOOL portal;
@property (nonatomic, readonly, getter=getTzGuide)	  TzCalTzolkinMoon *tzGuide;
@property (nonatomic, readonly, getter=getTzAntipode) TzCalTzolkinMoon *tzAntipode;
@property (nonatomic, readonly, getter=getTzAnalog)	  TzCalTzolkinMoon *tzAnalog;
@property (nonatomic, readonly, getter=getTzOccult)   TzCalTzolkinMoon *tzOccult;
// "method" properties
@property (nonatomic, readonly, getter=toneName_get)		NSString *toneName;			// tone names
@property (nonatomic, readonly, getter=toneNameFull_get)	NSString *toneNameFull;		// tone names
@property (nonatomic, readonly, getter=toneEssence_get)		NSString *toneEssence;		// tone essence
@property (nonatomic, readonly, getter=toneDesc_get)		NSString *toneDesc;			// tone
@property (nonatomic, readonly, getter=sealLabel_get)		NSString *sealLabel;		// seal
@property (nonatomic, readonly, getter=sealName_get)		NSString *sealName;			// seal names
@property (nonatomic, readonly, getter=sealFrase_get)		NSString *sealFrase;		// seal
@property (nonatomic, readonly, getter=sealTags_get)		NSString *sealTags;			// seal
@property (nonatomic, readonly, getter=sealDesc_get)		NSString *sealDesc;			// seal
@property (nonatomic, readonly, getter=dayName_get)			NSString *dayName;			// Selo
@property (nonatomic, readonly, getter=dayNameMaya_get)		NSString *dayNameMaya;		// Selo
@property (nonatomic, readonly, getter=dayNameFull_get)		NSString *dayNameFull;		// "Lua Espectral Amarela"
@property (nonatomic, readonly, getter=dayName1_get)		NSString *dayName1;			// "Lua"
@property (nonatomic, readonly, getter=dayName2_get)		NSString *dayName2;			// "Espectral Amarela"
@property (nonatomic, readonly, getter=dayMeaning_get)		NSString *dayMeaning;		// significado do dia/selo
@property (nonatomic, readonly, getter=colorUIColor_get)	UIColor *colorUIColor;
@property (nonatomic, readonly, getter=colorName_get)		NSString *colorName;		// color name
@property (nonatomic, readonly, getter=colorFamily_get)		NSString *colorFamily;		// color family
@property (nonatomic, readonly, getter=colorPurpose_get)	NSString *colorPurpose;		// ripens...
@property (nonatomic, readonly, getter=colorTag_get)		NSString *colorTag;			// color tags
@property (nonatomic, readonly, getter=colorDesc_get)		NSString *colorDesc;		// color desc
@property (nonatomic, readonly, getter=affirmation1_get)	NSString *affirmation1;		// Affirmation 1/5
@property (nonatomic, readonly, getter=affirmation2_get)	NSString *affirmation2;		// Affirmation 2/5
@property (nonatomic, readonly, getter=affirmation3_get)	NSString *affirmation3;		// Affirmation 3/5
@property (nonatomic, readonly, getter=affirmation4_get)	NSString *affirmation4;		// Affirmation 4/5
@property (nonatomic, readonly, getter=affirmation5_get)	NSString *affirmation5;		// Affirmation 5/5
@property (nonatomic, readonly, getter=affirmation6_get)	NSString *affirmation6;		// Affirmation 6 - PORTAL
// images
@property (nonatomic, readonly, getter=imgNum_get)		NSString *imgNum;
@property (nonatomic, readonly, getter=imgGlyph_get)	NSString *imgGlyph;
@property (nonatomic, readonly, getter=imgPortal_get)	NSString *imgPortal;


- (id)init:(int)j;
- (id)init:(int)j adjusted:(BOOL)adjusted;
- (void)updateWithJulian:(int)j;
- (void)updateWithJulian:(int)j adjusted:(BOOL)adjusted;
- (int)kinOfSeal:(int)baseKin withTone:(int)targetTone;
// Constantes
+(NSString*) constDayName:(int)i;			// 1-20
+(NSString*) constDayMeaning:(int)i;		// 1-20
+(NSString*) constColorNames:(int)i;		// Nomes das cores (1-4)
+(NSString*) constColorNamesFemale:(int)i;	// Nomes das cores (1-4)
+(NSString*) constColorFamilies:(int)i;
+(NSString*) constColorPurposes:(int)i;
+(NSString*) constColorTags:(int)i;
+(NSString*) constColorDescs:(int)i;
+(NSString*) constDirectionName:(int)i;
+(NSString*) constElementName:(int)i;
+(NSString*) constSealNames:(int)i;			// 1-20
+(NSString*) constSealFrases:(int)i;		// 1-20
+(NSString*) constSealTags:(int)i;			// 1-20
+(NSString*) constSealDescs:(int)i;			// 1-20
+(NSString*) constSealActions:(int)i;		// 1-20
+(NSString*) constSealPowers:(int)i;		// 1-20
+(NSString*) constSealEssences:(int)i;		// 1-20
+(NSString*) constToneNames:(int)i;			// Nomes dos tons (1-13)
+(NSString*) constToneNamesFemale:(int)i;	// Nomes dos tons (1-13)
+(NSString*) constToneDescs:(int)i;			// 1-13
+(NSString*) constTonePowers:(int)i;		// 1-13
+(NSString*) constToneActions:(int)i;		// 1-13
+(NSString*) constToneEssences:(int)i;		// 1-13
+(NSString*) constToneEssencesOf:(int)i;	// 1-13
+(NSString*) constTimeCells:(int)i;			// 1-5
+(NSString*) constOracleDescs:(int)i;		// 1-5
+(NSString*) constOracleNavLabels:(int)i destinyKin:(int)dkin;	// 1-5

@end
