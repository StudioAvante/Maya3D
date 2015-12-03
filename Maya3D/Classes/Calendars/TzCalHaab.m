//
//  TzCalHaab.m
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzCalendar.h"
#import "TzCalTzolkin.h"


@implementation TzCalHaab

#define HAAB_FIRSTKIN	349				// Haab KIN on 0.0.0.0.0

@synthesize kin;
@synthesize day;
@synthesize uinal;
@synthesize lord;


- (void)dealloc {
    [super dealloc];
}


// init "PUBLICO"
- (id)init:(int)j {
	if ([super init] == nil)
		return nil;
	
	// Set maya date
	[self updateWithJulian:j];
	return self;
}

// Converte JULIAN DAY NUMBER em memoria para uma data MAYA
- (void)updateWithJulian:(int)j {
	// Find Absolute Kin Number
	int abskin = (j - JULIAN_MIN);
	// HAAB
	int hk = ((abskin+HAAB_FIRSTKIN-1) % 365);
	kin = hk+1;
	day = (hk % 20);
	uinal = ((int)floor(hk/20) % 19);
	// Lord of the night
	lord = ((abskin-1) % 9) + 1;
	
	//
	// RELATED DATES
	//
	// Ano (Kin do dia 1/1)
	julianYear = j - kin + 1;
	
	// libera o ultimo ano
	if (tzYear)
		[tzYear release];
	tzYear = nil;	
}


// Inicializa datas relativas YEAR + ORACLE
// Separado porque so precisa na hora de desenhar os glifos
-(TzCalTzolkin*) getTzYear {
	if (tzYear == nil)
		tzYear = [[TzCalTzolkin alloc] init:julianYear];
	return tzYear;
}


#pragma mark PROPERTY GETTERS

//
// STRING GETTERS
//
-(NSString*)dayNameFull_get
{
	return [NSString stringWithFormat:@"%d %@",day,self.uinalName];
}
-(NSString*)uinalName_get
{
	return [TzCalHaab constUinalName:(uinal)];
}
-(NSString*)lordName_get
{
	return [NSString stringWithFormat:@"G%d",lord];
}
-(NSString*)lordNameFull_get
{
	return [NSString stringWithFormat:@"%@ G%d",LOCAL(@"N_LORD"),lord];
}
-(NSString*)uinalDesc_get
{
	return [TzCalHaab constUinalDesc:(uinal)];
}
-(NSString*)yearDesc_get
{
	return [TzCalHaab constYearDesc:(tzYear.day)];
}
// IMAGES
-(NSString*)imgNum_get
{
	return [NSString stringWithFormat:@"num%02d.png", day];
}
-(NSString*)imgNumSide_get
{
	return [NSString stringWithFormat:@"numside%02d.png", day];
}
-(NSString*)imgNumGlyph_get
{
	return [NSString stringWithFormat:@"numglyph%02d.png", day];
}
-(NSString*)imgGlyph_get
{
	return [NSString stringWithFormat:@"uinal%02d.png", uinal];
}
-(NSString*)imgLordGlyph_get
{
	return [NSString stringWithFormat:@"lord_G%d.png", lord];
}
-(NSString*)imgIsigGlyph_get
{
	return [NSString stringWithFormat:@"isig%02d.png", uinal];
}



#pragma mark CONSTANTES

//
// CONSTANTES
//

+(NSString*) constUinalName:(int)i;
{
	if ( i < 0 || i > 18 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"UINAL_%02d",i]));
}
+(NSString*) constUinalDesc:(int)i;
{
	if ( i < 0 || i > 18 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"UINAL_DESC_%02d",i]));
}
+(NSString*) constYearDesc:(int)i;
{
	if ( i < 0 || i > 18 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"YEAR_BEARER_DESC_%02d",i]));
}

@end
