//
//  TzCalGreg.m
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzCalendar.h"
#import "TzGlobal.h"

@implementation TzCalGreg

@synthesize absday;
@synthesize day;
@synthesize month;
@synthesize year;
@synthesize bi;
@synthesize isLeapDay;
@synthesize weekDay;
@synthesize hour;
@synthesize minute;
@synthesize second;
// methos properties
@synthesize dayNameNum;
@synthesize dayNameShort;
@synthesize dayNameFull;
@synthesize hourName;
@synthesize weekDayName;
@synthesize weekDayNameShort;

- (void)dealloc
{
    [super dealloc];
}

// Inicializa calendario a partir de uma data JULIANA
- (id)init:(int)j
{
	return [self init:j secs:0];
}
- (id)init:(int)j secs:(int)s
{
	if ([super init] == nil)
		return nil;
	
	// Set maya date
	[self updateWithJulian:j secs:s];
	return self;
}

// Converte JULIAN DAY NUMBER em memoria para uma data GREGORIANA
//  Metodo 1: http://en.wikipedia.org/wiki/Julian_day
// *Metodo 2: http://www.hermetic.ch/cal_stud/jdn.htm
- (void)updateWithJulian:(int)j
{
	[self updateWithJulian:j secs:0];
}
- (void)updateWithJulian:(int)julian secs:(int)s
{
	// Calcula data gregoriana
	int l = julian + 68569;
	int n = floor( (4*l) / 146097 );
	l = l - floor( (146097 * n + 3) / 4 );
	int i = floor( (4000 * (l + 1) ) / 1461001 );
	l = l - floor( (1461 * i) / 4 ) + 31;
	int j = floor( (80 * l) / 2447 );
	day = l - floor( (2447 * j) / 80 );
	l = floor (j / 11);
	month = j + 2 - (12 * l);
	year = 100 * (n - 49) + i + l;

	// Hoje eh 29/fev?
	isLeapDay = ( (month == 2 && day == 29) ? TRUE : FALSE);
	
	// Dia da semana
	weekDay = ( julian % 7 );
	
	// Calcula Hora
	hour = ( s / (60*60) );
	s -= ( hour * (60*60) );
	minute = ( s / 60 );
	s -= ( minute * 60 );
	second = s;
	//AvLog(@"GREG j[%d] secs[%d] h[%hi] m[%hi] s[%hi] [%@][%@]",julian,s,hour,minute,second,nameShort,self.hourName);

	// Absolute day
	absday = 0;
	if (month > 1)		// jan
		absday += 31;
	if (month > 2)		// fev
	{
		if ( [TzCalGreg isLeapYear:year] )
			absday += 29;
		else
			absday += 28;
	}
	if (month > 3)		// mar
		absday += 31;
	if (month > 4)		// abr
		absday += 30;
	if (month > 5)		// mai
		absday += 31;
	if (month > 6)		// jun
		absday += 30;
	if (month > 7)		// jul
		absday += 31;
	if (month > 8)		// ago
		absday += 31;
	if (month > 9)		// set
		absday += 30;
	if (month > 10)	// out
		absday += 31;
	if (month > 11)	// nov
		absday += 30;
	absday += day;
	//AvLog(@"GREG abs[%d] day[%d] month[%d] year[%d]",absday,day,month,year);
	
	// Procura anos bisextos desde -3113
	// -3112 foi o primeiro ano multiplo de 4 desde -3113
	/*
	bi = 0;
	for ( int y = -3112 ; ( y < year ) ; y+=4 )
		if ( [TzCalGreg isLeapYear:y] )
			bi++;
	 // Verifica se ano atual ja passou de 29/02
	if ( [TzCalGreg isLeapYear:year] && absday >= (31+29) )
		bi++;
	AvLog(@"GREG BI-1 date[%02d-%02d-%02d] bi[%d]",day,month,year,bi);
	*/
	
	// Procura anos bisextos desde -3113
	// Inclui multiplos de 4
	// -3112 foi o primeiro ano multiplo de 4 desde -3113
	int anos;
	bi = 0;
	if (year >= -3112)
	{
		anos = 3112 + year;
		bi += (anos/4) + 1;		// +1 para incluir o corrente
	}
	// Exclui multiplos de 100
	// -3100 foi o primeiro ano multiplo de 100 desde -3113
	if (year >= -3100)
	{
		anos = 3100 + year;
		bi -= (anos/100) + 1;	// +1 para incluir o corrente
	}
	// Inclui novamente os multiplos de 400
	// -2800 foi o primeiro ano multiplo de 400 desde -3113
	if (year >= -2800)
	{
		anos = 2800 + year;
		bi += (anos/400) + 1;	// +1 para incluir o corrente
	}
	// Verifica se ano atual ja passou de 29/02
	if ( [TzCalGreg isLeapYear:year] && absday < (31+29) )
		bi--;
	//AvLog(@"GREG BI-2 date[%02d-%02d-%02d] bi[%d]",day,month,year,bi);
}

// SOU um ano bisexto?
- (BOOL)amILeapYear;
{
	return [TzCalGreg isLeapYear:year];
}

#pragma mark CONVERSORES

// Verifica se ano eh bisexto
+ (BOOL)isLeapYear:(int)y {
	if ( ( ( y % 4 == 0 ) && ( y % 100 != 0)) || ( y % 400 == 0) )
		return TRUE;
	else
		return FALSE;
}

// Converte data GREGORIANA em memoria para JULIAN DAY NUMBER
// http://en.wikipedia.org/wiki/Julian_date
+ (int)convertGregToJulian:(int)d :(int)m: (int)y {
	int aa = floor((14-m)/12);
	int yy = y + 4800 - aa;
	int mm = m + 12*aa - 3;
	return (d + floor((153*mm+2)/5) + 365*yy + floor(yy/4) - floor(yy/100) + floor(yy/400) - 32045);
}

// Validate Gregorian Date
+ (int)validateGreg:(int)d :(int)m: (int)y {
	
	CFGregorianDate gdate;
	gdate.day = d;
	gdate.month = m;
	gdate.year = y;
	// Gambiarra para anos negativos: Remove 400 anos
	while (gdate.year < 0)
		gdate.year -= 400;
	//CFOptionFlags unitFlags = (kCFGregorianUnitsDays|kCFGregorianUnitsMonths|kCFGregorianUnitsYears);
	CFOptionFlags unitFlags = (kCFGregorianUnitsDays|kCFGregorianUnitsMonths);
	BOOL valid = CFGregorianDateIsValid (gdate,unitFlags);
	if (valid == FALSE)
		return -2;
	else
		return 0;
}

#pragma mark PROPERTY GETTERS

//
// STRING GETTERS
//
-(NSString*)getDayNameFull {
	return [TzCalGreg makeDayNameFull:day:month:year];
}
-(NSString*)getDayNameShort {
	return [TzCalGreg makeDayNameShort:day:month:year];
}
-(NSString*)getDayNameNum {
	return [TzCalGreg makeDayNameNum:day:month:year];
}
-(NSString*)getDayNameHour {
	return [NSString stringWithFormat:@"%@ %@",self.dayNameNum,self.hourName];
}
-(NSString*)getHourName {
	return [TzCalGreg makeHourName:hour:minute:second];
}
-(NSString*)getWeekDayName {
	return [TzCalGreg constNameOfWeekDay:weekDay];
}
-(NSString*)getWeekDayNameShort {
	return [TzCalGreg constNameOfWeekDayShort:weekDay];
}


#pragma mark CLASS METHODS

//
// CLASS METHODS
//
// Make Gregorian Date: 21/march/2003
+(NSString*) makeDayNameFull:(int)d :(int)m: (int)y {
	if (global.prefDateFormat == GREG_MDY)
		return [NSString stringWithFormat:@"%@/%02d/%04d",
				[TzCalGreg constNameOfMonth:m], d, y];
	else
		return [NSString stringWithFormat:@"%02d/%@/%04d",
				d, [TzCalGreg constNameOfMonth:m], y];
}
// Make Gregorian Date: 21/mar/2003
+(NSString*) makeDayNameShort:(int)d :(int)m: (int)y {
	if (global.prefDateFormat == GREG_MDY)
		return [NSString stringWithFormat:@"%@/%02d/%04d",
				[self constNameOfMonthShort:m], d, y];
	else
		return [NSString stringWithFormat:@"%02d/%@/%04d",
				d, [self constNameOfMonthShort:m], y];
}
// Make Gregorian Date: 21/03/2003
+(NSString*) makeDayNameNum:(int)d :(int)m: (int)y {
	if (global.prefDateFormat == GREG_MDY)
		return [NSString stringWithFormat:@"%02d/%02d/%d", m, d, y];
	else
		return [NSString stringWithFormat:@"%02d/%02d/%d", d, m,y];
}
// Make Hour string: 12:17:56
+(NSString*) makeHourName:(int)h:(int)m:(int)s
{
	return [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
}



#pragma mark CONSTANTES

//
// CONSTANTES
//

static char *monthNames[] = {
"JANUARY",
"FEBRUARY",
"MARCH",
"APRIL",
"MAY",
"JUNE",
"JULY",
"AUGUST",
"SEPTEMBER",
"OCTOBER",
"NOVEMBER",
"DECEMBER"
};

static char *monthNamesShort[] = {
"JAN",
"FEB",
"MAR",
"APR",
"MAY_SHORT",
"JUN",
"JUL",
"AUG",
"SEP",
"OCT",
"NOV",
"DEC"};

static char *weekDayNames[] = {
"MONDAY",
"TUESDAY",
"WEDNESDAY",
"THURSDAY",
"FRIDAY",
"SATURDAY",
"SUNDAY"
};

static char *weekDayNamesShort[] = {
"MON",
"TUE",
"WED",
"THU",
"FRI",
"SAT",
"SUN"
};

+(NSString*) constNameOfMonth:(int)m
{
	if ( m < 1 || m > 12)
		return nil;
	return  LOCAL([NSString stringWithCString:monthNames[m-1] encoding:[NSString defaultCStringEncoding]]);
}
+(NSString*) constNameOfMonthShort:(int)m
{
	if ( m < 1 || m > 12)
		return nil;
	return  LOCAL([NSString stringWithCString:monthNamesShort[m-1] encoding:[NSString defaultCStringEncoding]]);
}
// Nome do dia da semana - 0 a 6
+(NSString*) constNameOfWeekDay:(int)d
{
	if ( d < 0 || d > 6)
		return nil;
	return  LOCAL([NSString stringWithCString:weekDayNames[d] encoding:[NSString defaultCStringEncoding]]);
}
+(NSString*) constNameOfWeekDayShort:(int)d
{
	if ( d < 0 || d > 6)
		return nil;
	return  LOCAL([NSString stringWithCString:weekDayNamesShort[d] encoding:[NSString defaultCStringEncoding]]);
}


@end
