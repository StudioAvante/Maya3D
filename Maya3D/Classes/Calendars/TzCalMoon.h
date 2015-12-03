//
//  TzCalMoon.h
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"

@class TzCalGreg;

@interface TzCalMoon : NSObject {
	// Misc & data
	int firstkin;				// 13-Moon KIN on 0.0.0.0.0
	// Current Date
	int kin;					// 1-365
	int day;					// 1-28 (dia na lua)
	int plasma;					// 0-7
	int week;					// 1-4
	int moon;					// 1-14 (14 = Dia fora do tempo)
	int moonDay;				// 1-28 (1=FULL)
	int moonFase;				// 0-3 (0=FULL)
	bool doot;					// D.O.O.T. ?
	// Related kins
	int julianYearAdjusted;
	int julianYearGreg;
	int julianGreg;
	TzCalTzolkinMoon *tzYear;
	TzCalGreg *gregYear;
}

@property (nonatomic) int firstkin;
@property (nonatomic) int kin;
@property (nonatomic) int day;
@property (nonatomic) int plasma;
@property (nonatomic) int week;
@property (nonatomic) int moon;
@property (nonatomic) int moonDay;
@property (nonatomic) int moonFase;
@property (nonatomic) bool doot;
@property (nonatomic, readonly, getter=getTzYear)		TzCalTzolkinMoon *tzYear;
@property (nonatomic, readonly, getter=getGregYear)		TzCalGreg *gregYear;
// "method" properties
@property (nonatomic, readonly, getter=yearPeriod_get)			NSString *yearPeriod;
@property (nonatomic, readonly, getter=dayName_get)				NSString *dayName;
@property (nonatomic, readonly, getter=dayNameGear_get)			NSString *dayNameGear;
@property (nonatomic, readonly, getter=moonNumberLabel_get)		NSString *moonNumberLabel;
@property (nonatomic, readonly, getter=moonName_get)			NSString *moonName;
@property (nonatomic, readonly, getter=moonNameFull_get)		NSString *moonNameFull;
@property (nonatomic, readonly, getter=moonActionFull_get)		NSString *moonActionFull;
@property (nonatomic, readonly, getter=moonPowerFull_get)		NSString *moonPowerFull;
@property (nonatomic, readonly, getter=moonQuestion_get)		NSString *moonQuestion;
@property (nonatomic, readonly, getter=plasmaName_get)			NSString *plasmaName;
@property (nonatomic, readonly, getter=plasmaAffirmation_get)	NSString *plasmaAffirmation;
@property (nonatomic, readonly, getter=chakraName_get)			NSString *chakraName;
@property (nonatomic, readonly, getter=moonFaseName_get)		NSString *moonFaseName;
@property (nonatomic, readonly, getter=moonFaseDesc_get)		NSString *moonFaseDesc;
@property (nonatomic, readonly, getter=weekPurpose_get)			NSString *weekPurpose;
// images
@property (nonatomic, readonly, getter=imgNum_get)			NSString *imgNum;
@property (nonatomic, readonly, getter=imgMoonFase_get)		NSString *imgMoonFase;
@property (nonatomic, readonly, getter=imgPlasma_get)		NSString *imgPlasma;
@property (nonatomic, readonly, getter=imgChakra_get)		NSString *imgChakra;


- (id)init:(int)j;
- (id)init:(int)j  adjustedJulian:(int)jj;
- (void)updateWithJulian:(int)j;
- (void)updateWithJulian:(int)j adjustedJulian:(int)jj;
// Constantes
+(NSString*) constMoonNames:(int)i;
+(NSString*) constMoonQuestions:(int)i;
+(NSString*) constAnimalNames:(int)i;
+(NSString*) constPlasmaNames:(int)i;
+(NSString*) constPlasmaAffirmations:(int)i;
+(NSString*) constChakraNames:(int)i;
+(NSString*) constMoonFaseNames:(int)i;
+(NSString*) constMoonFaseDescs:(int)i;
+(NSString*) constWeekPurposes:(int)i;

@end
