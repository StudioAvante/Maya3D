//
//  TzCalTzolkin.m
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzCalendar.h"
#import "TzGlobal.h"


@implementation TzCalTzolkin

const char goodBad[] = {
'G', 'G', 'G', 'G', 'G', 'G', 'B', 'B', 'B', 'G', 'G', 'G', 'G', 'B', 'B', 'G', 'G', 'G', 'G', 'G', 
'B', 'B', 'B', 'G', 'B', 'G', 'G', 'B', 'B', 'G', 'B', 'G', 'B', 'B', 'B', 'B', 'G', 'B', 'G', 'B', 
'B', 'B', 'B', 'B', 'B', 'G', 'G', 'B', 'B', 'G', 'G', 'B', 'B', 'B', 'G', 'B', 'B', 'B', 'B', 'B', 
'B', 'B', 'G', 'B', 'B', 'B', 'B', 'B', 'G', 'B', 'B', 'B', 'B', 'B', 'G', 'B', 'B', 'G', 'B', 'B', 
'B', 'B', 'B', 'G', 'G', 'G', 'B', 'B', 'G', 'B', 'B', 'B', 'B', 'B', 'G', 'G', 'G', 'G', 'G', 'G', 
'B', 'G', 'G', 'B', 'G', 'G', 'G', 'G', 'B', 'B', 'B', 'G', 'G', 'G', 'G', 'G', 'G', 'B', 'B', 'G', 
'B', 'B', 'B', 'B', 'B', 'G', 'B', 'B', 'B', 'G', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'G', 'B', 
'B', 'B', 'B', 'B', 'B', 'B', 'G', 'G', 'G', 'B', 'B', 'B', 'G', 'B', 'B', 'G', 'G', 'G', 'G', 'B', 
'B', 'B', 'B', 'B', 'G', 'G', 'B', 'B', 'G', 'G', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'G', 'G', 'G', 
'G', 'B', 'B', 'B', 'G', 'G', 'G', 'B', 'B', 'G', 'B', 'B', 'B', 'G', 'G', 'B', 'B', 'G', 'G', 'G', 
'G', 'B', 'B', 'G', 'G', 'G', 'G', 'B', 'G', 'G', 'G', 'G', 'G', 'B', 'G', 'G', 'G', 'G', 'B', 'G', 
'G', 'G', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'G', 'B', 'B', 'B', 'B', 
'B', 'B', 'B', 'B', 'G', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'B', 'G', 'G', 'G', 'G', 'G'
};


@synthesize kin;
@synthesize number;
@synthesize day;
@synthesize calendarRound;
@synthesize calendarRoundKin;
@synthesize color;
@synthesize angleNumber;
@synthesize angleDay;

#define TZFIRSTKIN		160				// Tzolkin KIN on 0.0.0.0.0
#define TZFIRSTCR		12062			// 1st Calendar Round from 0.0.0.0.0 = JDN 596345
//#define TZFIRSTCR		(12062+CALENDAR_ROUND_DAYS)	// para testes negativos

- (void)dealloc {
    [super dealloc];
}


// init "PUBLICO"
- (id)init:(int)j {
	// CONSTANTE: Tzolkin KIN on 0.0.0.0.0
	firstKin = TZFIRSTKIN;
	firstCR = TZFIRSTCR;

	// Set maya date
	[self updateWithJulian:j];
	return self;
}

// Inicializa calendario a partir de uma data JULIANA
- (void)updateWithJulian:(int)j {
	// Find Absolute Kin Number
	int abskin = (j - CORRELATION);
	kin = ((abskin+firstKin-1) % 260)+1;
	number = ((abskin+firstKin-1) % 13)+1;
	day = ((abskin+firstKin-1) % 20)+1;
	
	// Calendar Round
	// >> MAYA
	// ref (data diverge da minha): http://www.pauahtun.org/Calendar/calround.html
	// 2010-03-18 00:56:32.094 Maya3D[38328:20b] CR jdn[596344] Tzolkin[1/1 Imix] Haab[365/4 Wayeb]	delta=12061 = FIM
	// 2010-03-18 00:56:05.384 Maya3D[38308:20b] CR jdn[596345] Tzolkin[2/2 Ik'] Haab[1/0 Pop]      delta=12062 = INICIO
	// >> DREAMSPELL
	// 2010-03-19 16:20:46.571 Kin3DFull[42205:20b] CR DR jdn[2447003] Tzolkin[34/Mago] Moon[1/Dia 1 / semana 1] days from corr[1862720] = INICIO
	// TODO: Dreamspell: Considerar a diferenca de 13 dias pelos dias bisextos pulados!!!
	calendarRoundKin = ((abskin-firstCR) % CALENDAR_ROUND_DAYS)+1;
	calendarRound = (int) ((abskin-firstCR) / (CALENDAR_ROUND_DAYS));
	if (abskin < firstCR)
	{
		calendarRoundKin = (CALENDAR_ROUND_DAYS - (abs(abskin-firstCR+1)% CALENDAR_ROUND_DAYS));
		calendarRound = (int) ((abskin-firstCR+1) / (CALENDAR_ROUND_DAYS))-1;
	}
	//AvLog(@"TZOLKIN julian[%d] first[%d] abs[%d] kin[%d] number[%d] day[%d] cr[%d] crkin[%d]",j,firstKin,abskin,kin,number,day,calendarRound,calendarRoundKin);
	
	// Good or bad day?
	good = ( goodBad[kin-1] == 'G' ? YES : NO );
	
	// color & direction
	// 1-4
	color = ( (day-1) % 4)+1;
	//AvLog(@"TZOLKIN day[%d] color[%d/%@] dir[%@] el[%@]",day,color,self.colorName,self.directionName,self.elementName);
}

#pragma mark PROPERTY GETTERS

//
// STRING GETTERS
//
-(NSString*)dayName_get
{
	return [TzCalTzolkin constDayName:(day)];
}
-(NSString*)dayNameFull_get
{
	return [NSString stringWithFormat:@"%d %@",number,self.dayName];
}
-(NSString*)dayMeaning_get
{
	return [TzCalTzolkin constDayMeaning:(day)];
}
-(NSString*)dayAnimal_get
{
	return [TzCalTzolkin constDayAnimal:(day)];
}
-(NSString*)dayEnergy_get
{
	return [TzCalTzolkin constDayEnergy:(day)];
}
-(NSString*)colorName_get
{
	return [TzCalTzolkin constColorName:(color)];
}
-(NSString*)directionName_get
{
	return [TzCalTzolkin constDirectionName:(color)];
}
-(NSString*)elementName_get
{
	return [TzCalTzolkin constElementName:(color)];
}
-(NSString*)personality_get
{
	return [TzCalTzolkin constPersonality:(day)];
}
-(NSString*)goodDayTo1_get
{
	return [TzCalTzolkin constGoodDayTo:(day):1];
}
-(NSString*)goodDayTo2_get
{
	return [TzCalTzolkin constGoodDayTo:(day):2];
}
-(NSString*)goodDayTo3_get
{
	return [TzCalTzolkin constGoodDayTo:(day):3];
}
-(NSString*)goodDayTo4_get
{
	return [TzCalTzolkin constGoodDayTo:(day):4];
}
// IMAGES
-(NSString*)imgNum_get
{
	return [NSString stringWithFormat:@"num%02d.png", number];
}
-(NSString*)imgNumSide_get
{
	return [NSString stringWithFormat:@"numside%02d.png", number];
}
-(NSString*)imgNumGlyph_get
{
	return [NSString stringWithFormat:@"numglyph%02d.png", number];
}
-(NSString*)imgGlyph_get
{
	return [NSString stringWithFormat:@"tzday%02d.png", day];
}
-(NSString*)imgNews_get
{
	if (color == DIR_NORTH)
		return @"news_maya_N.png";
	else if (color == DIR_SOUTH)
		return @"news_maya_S.png";
	else if (color == DIR_EAST)
	{
		if (global.prefLang == LANG_PT)
			return @"news_maya_L.png";
		else	// en / es
			return @"news_maya_E.png";
	}
	else if (color == DIR_WEST)
	{
		if (global.prefLang == LANG_EN)
			return @"news_maya_W.png";
		else	// pt / es
			return @"news_maya_O.png";
	}
	// nao vai chegar aqui, mas...
	else
		return nil;
}
-(NSString*)imgThumb_get
{
	if (good)
		return @"thumbs_up.png";
	else
		return @"thumbs_down.png";
}



#pragma mark CONSTANTES

//
// CONSTANTES
//

+(NSString*) constDayName:(int)i;
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TZDAY_%02d",i]));
}
+(NSString*) constDayMeaning:(int)i
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TZDAY_MEANING_%02d",i]));
}
+(NSString*) constDayAnimal:(int)i
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TZDAY_ANIMAL_%02d",i]));
}
+(NSString*) constDayEnergy:(int)i
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TZDAY_ENERGY_%02d",i]));
}
+(NSString*) constColorName:(int)i
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TZDAY_COLOR_%02d",i]));
}
+(NSString*) constDirectionName:(int)i;
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TZDAY_DIRECTION_%02d",i]));
}
+(NSString*) constElementName:(int)i;
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TZDAY_ELEMENT_%02d",i]));
}
+(NSString*) constPersonality:(int)i;
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TZDAY_PERSONALITY_%02d",i]));
}
+(NSString*) constGoodDayTo:(int)i :(int)n;
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"GOOD_DAY_TO_%02d_%d",i,n]));
}

@end
