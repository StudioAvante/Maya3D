//
//  TzCalMoon.m
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzCalendar.h"
#import "TzGlobal.h"


@implementation TzCalMoon

#define MOONFIRSTKIN	17		// 13-Moon KIN on 0.0.0.0.0

@synthesize firstkin;
@synthesize kin;
@synthesize day;
@synthesize plasma;
@synthesize week;
@synthesize moon;
@synthesize moonDay;
@synthesize moonFase;
@synthesize doot;

// destructor
- (void)dealloc {
    [super dealloc];
}

// init
- (id)init:(int)j
{
	return [self init:j adjustedJulian:0];
}
// init
- (id)init:(int)j  adjustedJulian:(int)jj
{
	if ([super init] == nil)
		return nil;
	
	// CONSTANTE: Haab KIN on 0.0.0.0.0
	firstkin = MOONFIRSTKIN;
	//AvLog(@"TzCalHaab: firstkin[%d]",firstkin);
	
	// Set maya date
	if (jj)
		[self updateWithJulian:j adjustedJulian:jj];
	else
		[self updateWithJulian:j];

	// Finito!
	return self;
}

// Atualiza a partir de JDN
- (void)updateWithJulian:(int)j {
	// AJUSTE DOS BISEXTOS
	TzCalGreg *greg = [[TzCalGreg alloc] init:j];
	[self updateWithJulian:j adjustedJulian:(j-greg.bi)];
}
// Atualiza a partir de JDN
- (void)updateWithJulian:(int)j adjustedJulian:(int)jj{
	// Calcula fase da lua em JDN 0
	// Foi lua CHEIA exatamente em: 1990 Oct  4 12:03 - JDN 2448169
	//double luas = (2448169.0 / LUNATION);
	//AvLog(@"MOON calc JDN-0 luas[%f]",luas);
	// Resultado: MOON calc JDN-0 luas[82902.816466]
	
	// Calcula fase da lua com JDN sem ajuste
	// Alinha JDN-0 com a lua CHEIA
	double jnova = ( j - (LUNATION_JDN0*LUNATION) );
	// Calcula a lunacao de hoje (0.0 - 1.0) pegando o resto da diferenca de hoje e JDN-0
	double lunacao = fmod ( (jnova/LUNATION), 1.0 );
	// Fase da lua (1-28) onde: 1 = Full
	moonDay = (int) (lunacao * 28.0) + 1;
	moonFase = ((moonFase-1)/7);	// 0-3
	//AvLog(@"MOON moonDay[%d] moonFase[%d] [%@]",moonDay,moonFase,moonFaseName);
	
	//
	// A PARTIR DAQUI USA JDN AJUSTADA
	//
	
	// 13-MOON DATE
	// Find Absolute Kin Number since 0.0.0.0.0
	int abskin = (jj - JULIAN_MIN);
	int hk = ((abskin+firstkin-1) % 365);	// 0-364
	kin = hk+1;
	day = (hk % 28) + 1;
	
	// Week 1=1-7 / 2=8-14 / 3=15-21 / 4=12-28
	week = ( (day-1) / 7) + 1;
	//AvLog(@"13-MOON day[%d] week[%d] [%@]",day,week,self.weekPurpose);
	
	// Current Moon
	moon = ((int)floor(hk/28) % 14) + 1;
	//AvLog(@"13-MOON kin[%d] day[%d] moon[%d][%@]",kin,day,moon,moonName);
	
	// DOOT
	doot = (moon == 14);
	
	// Plasma / Week day
	//plasma = ( (abskin+2) % 7) + 1;
	plasma = ( doot ? 0 : ((hk % 7) + 1) );
	//AvLog(@"13-MOON hk[%d] kin[%d] day[%d] moon[%d][%@]",hk,kin,day,plasma,plasmaName);
	
	//
	// RELATED DATES
	//
	// Ano (Kin do dia 26/07)
	int jy = (jj - kin + 1);
	if (julianYearAdjusted != jy)
	{
		julianYearAdjusted = jy;
		julianYearGreg = (j - kin + 1);
		if (tzYear)
			[tzYear release];
		if (gregYear)
			[gregYear release];
		tzYear = nil;
		gregYear = nil;
	}
}



#pragma mark PROPERTY GETTERS

// Inicializa datas relativas YEAR + ORACLE
// Separado porque so precisa na hora de desenhar os glifos
// ps: O resto está em TzCalTzolkinMoon
// YEAR no TZOLKIN
-(TzCalTzolkinMoon*) getTzYear {
	if (tzYear == nil)
		tzYear = [[TzCalTzolkinMoon alloc] init:julianYearAdjusted adjusted:TRUE];
	return tzYear;
}
-(TzCalGreg*) getGregYear {
	if (gregYear == nil)
	{
		// Verifica se o ano seguinte eh bisexto!
		gregYear = [[TzCalGreg alloc] init:(julianYearGreg+365)];
		if ([gregYear amILeapYear])
		{
			// Remove dia bisexto
			julianYearGreg -= 1;
			[gregYear release];
		}
		// Cria data!
		gregYear = [[TzCalGreg alloc] init:julianYearGreg];
	}
	return gregYear;
}



//
// STRING GETTERS
//
-(NSString*)yearPeriod_get {
	return [NSString stringWithFormat:LOCAL(@"%@ %@ %@"),
			self.gregYear.dayNameShort,
			LOCAL(@"UNTIL"),
			[TzCalGreg makeDayNameShort:(self.gregYear.day-1) :(self.gregYear.month) :(self.gregYear.year+1)] ];
}
-(NSString*)dayName_get {
	//return [NSString stringWithFormat:@"%@ %d %@",LOCAL(@"DAY"),day,[TzCalMoon constWeekPurposes:(week)]];
	if ( doot )	// dia-fora-do-tempo
		return @"";
	else
		return [NSString stringWithFormat:@"%@ %d / %@ %d",
				LOCAL(@"DAY"),
				day,
				LOCAL(@"WEEK"),
				week ];
}
-(NSString*)dayNameGear_get {
	//return [NSString stringWithFormat:@"%@ %d %@",LOCAL(@"DAY"),day,[TzCalMoon constWeekPurposes:(week)]];
	if ( doot )	// dia-fora-do-tempo
		return LOCAL(@"DAY_OUT_OF_TIME");
	else
		return  [NSString stringWithFormat:LOCAL(@"GEAR_NAME_DREAMSPELL_365_FORMAT"), 
				 moon, 
				 day ];
}
-(NSString*)moonNumberLabel_get {
	if ( doot )	// dia-fora-do-tempo
		return LOCAL(@"DREAMSPELL_MONTH");
	else
		// Ordem no formato eh igual para EN e PT
		return [NSString stringWithFormat:LOCAL(@"DREAMSPELL_MONTH+NUM"),moon];
}
-(NSString*)moonName_get {
	if ( doot )	// dia-fora-do-tempo
		return LOCAL(@"DAY_OUT_OF_TIME");
	else
		return [TzCalMoon constMoonNames:(moon)];
}
-(NSString*)moonNameFull_get {
	if ( doot )	// dia-fora-do-tempo
		return LOCAL(@"DAY_OUT_OF_TIME");
	else if (global.prefLang == LANG_PT || global.prefLang == LANG_ES)
		return [NSString stringWithFormat:@"%@ %@ %@ %d",
				LOCAL(@"MOON"), self.moonName, [TzCalMoon constAnimalNames:(moon)], day];
	else // en
		return [NSString stringWithFormat:@"%@ %@ %d %@",
				self.moonName, [TzCalMoon constAnimalNames:(moon)], day, LOCAL(@"MOON")];
}
-(NSString*)moonQuestion_get {
	if (doot)
		return [TzCalMoon constMoonQuestions:(moon)];
	else
		return [NSString stringWithFormat:@"%@: %@",
				[TzCalTzolkinMoon constToneEssences:(moon)],
				[TzCalMoon constMoonQuestions:(moon)] ];
}
-(NSString*)moonPowerFull_get {
	return [NSString stringWithFormat:LOCAL(@"%@: %@"),LOCAL(@"POWER"),[TzCalTzolkinMoon constTonePowers:(moon)]];
}
-(NSString*)moonActionFull_get {
	return [NSString stringWithFormat:LOCAL(@"%@: %@"),LOCAL(@"ACTION"),[TzCalTzolkinMoon constToneActions:(moon)]];
}
-(NSString*)plasmaName_get {
	return [TzCalMoon constPlasmaNames:(plasma)];
}
-(NSString*)plasmaAffirmation_get {
	NSString *name = [TzCalMoon constPlasmaAffirmations:(plasma)];
	return ( name.length ? [NSString stringWithFormat:LOCAL(@"\"%@\""),name] : @"" );
}
-(NSString*)chakraName_get {
	return [TzCalMoon constChakraNames:(plasma)];
}
-(NSString*)moonFaseName_get {
	return [TzCalMoon constMoonFaseNames:(moonFase)];
}
-(NSString*)moonFaseDesc_get {
	return [TzCalMoon constMoonFaseDescs:(moonFase)];
}
-(NSString*)weekPurpose_get {
	//return [TzCalMoon constWeekPurposes:(week)];
	return [TzCalMoon constMoonFaseDescs:(week)];
}
//
// IMAGES
//
-(NSString*) imgNum_get
{
	if (doot)
		//return [NSString stringWithFormat:@"numbig00i.png"];
		return @"dummy_trans.png";
	else
		return [NSString stringWithFormat:@"numside%02d.png",moon];
}
-(NSString*) imgPlasma_get
{
	return [NSString stringWithFormat:@"plasma%d.png",plasma];
}
-(NSString*) imgChakra_get	// alinhado com plasma
{
	return [NSString stringWithFormat:@"chakra%d.png",plasma];
}
-(NSString*) imgMoonFase_get
{
	short d = moonDay;
	if (global.prefHemisphere==HEMISPHERE_NORTH)
	{
		d = (30-moonDay);
		if (d > 28)
			d = 1;
	}
	return [NSString stringWithFormat:@"moon%02d.png",d];
}


#pragma mark CONSTANTES

//
// CONSTANTES
//

// Constantes
+(NSString*) constMoonNames:(int)i	// 1-14
{
	if ( i < 1 || i > 14)
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TONE_FEMALE_%02d",i]));
}
+(NSString*) constMoonQuestions:(int)i	// 1-14
{
	if ( i < 1 || i > 14)
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"MOON_QUESTION_%02d",i]));
}
+(NSString*) constAnimalNames:(int)i	// 1-14
{
	if ( i < 1 || i > 14)
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_ANIMAL_%02d",i]));
}
+(NSString*) constPlasmaNames:(int)i	// 1-7
{
	if ( i < 0 || i > 7)
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_PLASMA_%02d",i]));
}
+(NSString*) constPlasmaAffirmations:(int)i	// 1-7
{
	if ( i < 0 || i > 7)
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_PLASMA_AFFIRM_%02d",i]));
}
+(NSString*) constChakraNames:(int)i	// 1-7
{
	if ( i < 1 || i > 7)
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_CHAKRA_%02d",i]));
}
+(NSString*) constMoonFaseNames:(int)i	// 0-3
{
	if ( i < 0 || i > 3)
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"MOON_FASE_%02d",i]));
}
+(NSString*) constMoonFaseDescs:(int)i	// 0-4
{
	if ( i < 0 || i > 4)
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"MOON_FASE_DESC_%02d",i]));
}
+(NSString*) constWeekPurposes:(int)i	// 1-4
{
	if ( i < 1 || i > 4)
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_WEEK_%02d",i]));
}

@end
