//
//  TzCalendar.m
//  Maya3D
//
//  Created by Roger on 01/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzCalendar.h"
#import "TzDate.h"
#import "TzGlobal.h"


@implementation TzCalendar


// Julian
@synthesize julian;
@synthesize decSecs;
@synthesize secs;
@synthesize tick;
// Calendars
@synthesize greg;
@synthesize longCount;
@synthesize tzolkin;
@synthesize tzolkinMoon;
@synthesize haab;
@synthesize moon;

- (void)dealloc
{
	[greg release];
	[longCount release];
	[tzolkin release];
	[haab release];
	[tzolkinMoon release];
	[moon release];
    [super dealloc];
}


// CONSTRUCTOR
// Inicializa com a data de hoje
- (id)initWithToday
{
	TzDate *dt = [[TzDate alloc] init];
	return [self init:dt.julian secs:dt.secs];
}
// Se nao informar a hora, eh sempre meio-dia 12:00:00
- (id)init:(int)j
{
	return [self init:j secs:(SECONDS_PER_DAY/2)];
}
// Inicializa com hora correta
- (id)init:(int)j secs:(int)s
{
	if ([super init] == nil)
		return nil;

	// Aloca calendarios
	greg = [[TzCalGreg alloc] init:j secs:s];
	longCount = [[TzCalLong alloc] init:j];
	haab = [[TzCalHaab alloc] init:j];
	tzolkin = [[TzCalTzolkin alloc] init:j];
	tzolkinMoon = [[TzCalTzolkinMoon alloc] init:(j-greg.bi) adjusted:TRUE];
	moon = [[TzCalMoon alloc] init:j adjustedJulian:(j-greg.bi)];
	
	// Inicializa com a data inicial
	[self updateWithJulian:j secs:(double)s];
	
	// Retorna ponteiro de si mesmo
	return self;
}

// Go to TODAY
- (void) updateWithToday
{
	// Define Data inicial - TODAY
	TzDate *dt = [[TzDate alloc] init];
	[self updateWithJulian:dt.julian secs:dt.secs];
}
// Retorna validade da data  < 0 / 0 (ok) / > 0
- (int)updateWithJulian:(int)j {
	// Inicia as 12:00
	return [self updateWithJulian:j secs:(double)(SECONDS_PER_DAY/2)];
}
- (int)updateWithJulian:(int)j secs:(double)s {
	// Valida data JDN
	int valid;
	if ( (valid = [self validateJulian:j secs:(int)s]) != 0)
	{
		AvLog(@"CAL: Invalid[%d] JDN [%d] secs [%d][%f]",valid,j,(int)s,s);		
		return valid;
	}
	// Set julian
	julianLast = julian;
	decSecsLast = decSecs;
	// Set julian
	julian = j;
	secs = s;
	decSecs = (s / SECONDS_PER_DAY);
	
	// Alloc calendars
	[greg updateWithJulian:j secs:(int)s];
	[longCount updateWithJulian:j];
	[tzolkin updateWithJulian:j];
	[tzolkinMoon updateWithJulian:(j-greg.bi) adjusted:TRUE];
	[haab updateWithJulian:j];
	[moon updateWithJulian:j adjustedJulian:(j-greg.bi)];
	
	// Remove LEAP DAY se estiver no modo DREAMSPELL
	[self removeLeap];
	
	// TICK -- Meio-dia
	/*
	// Dia seguinte
	if (julian > julianLast && decSecs >= 0.5)
		tick = TRUE;
	// Dia anterior
	else if (julian < julianLast && decSecs <= 0.5)
		tick = TRUE;
	// Mesmo dia hora aumentando
	else if (julian == julianLast && decSecsLast < 0.5 && decSecs >= 0.5)
		tick = TRUE;
	// Mesmo dia hora diminuindo
	else if (julian == julianLast && decSecsLast > 0.5 && decSecs <= 0.5)
		tick = TRUE;
	*/

	// TICK -- Meia-noite
	if (julian < julianLast || julian > julianLast)
		tick = TRUE;
	
	// Ok!
	return 0;
}
// Valida data JDN: Verifica se esta no limite de 1 PIKTUN
- (int)validateJulian:(int)j
{
	return [self validateJulian:j secs:(SECONDS_PER_DAY/2)];
}
- (int)validateJulian:(int)j secs:(int)s
{
	if (s >= SECONDS_PER_DAY )
		return -2;
	else if (j < JULIAN_MIN)
		return -1;
	else if (j >= JULIAN_MAX)
		return 1;
	else
		return 0;
}

#pragma mark DATE CALCULATIONS

// Adiciona segundos a data corrente
// Retorna validade da data  < 0 / 0 (ok) / > 0
- (int)addSeconds:(double)s
{
	//AvLog(@"CAL addSeconds [%f] current > JDN [%d] secs [%f]",s,julian,secs);

	// Incrementa os segundos atuais
	int newJulian = julian;
	double newSecs = secs + s;
	// Mudou de dia?
	if (newSecs >= SECONDS_PER_DAY)
	{
		// Quantos dias temos a mais?
		int days = ( (int)(newSecs / SECONDS_PER_DAY) );
		// Incrementa os dias
		newJulian += days;
		// Remove os dias excedentes dos segundos
		newSecs -= (days * SECONDS_PER_DAY);
	}
	// Voltou dia?
	else if (newSecs < 0.0)
	{
		// Remove os dias excedentes
		while (newSecs < 0.0)
		{
			newJulian -= 1;
			newSecs += SECONDS_PER_DAY;
		}
		// Deixa o restante dos segundos
		//newSecs = SECONDS_PER_DAY - newSecs;
	}
	//AvLog(@"CAL addSeconds [%f] new     > JDN [%d] secs [%f]",s,newJulian,newSecs);
	
	// Atualiza data
	return [self updateWithJulian:newJulian secs:newSecs];
}

// Remove LEAP DAY se estiver no modo DREAMSPELL
- (void)removeLeap {
	// Se nao estiver no modo DREAMSPELL, deixa como esta
	if (global.prefMayaDreamspell != VIEW_MODE_DREAMSPELL)
		return;
	// Remove um dia se for LEAP DAY
	if (greg.isLeapDay)
		[self addSeconds: ( (julian > julianLast) ? SECONDS_PER_DAY : -SECONDS_PER_DAY )];
}


#pragma mark NEW DATE

// Inicializa calendario a partir de uma data GREGORIANA
- (int)updateWithGreg:(int)d:(int)m:(int)y {
	int valid;
	// Validate Gregorian date
	if ( (valid = [TzCalGreg validateGreg:d:m:y]) != 0)
		return valid;
	// Calcula JDN
	int j = [TzCalGreg convertGregToJulian:d:m:y];
	// Inicializa com Julian
	if ( (valid = [self updateWithJulian:j]) != 0)
		return valid;
	return 0;
}


// Inicializa calendario a partir de uma data MAYA
- (int)updateWithMaya:(int)b:(int)k:(int)t:(int)u:(int)i {
	// Calcula JDN
	int j = [longCount convertMayaToJulian:b:k:t:u:i];
	// Inicializa com Julian
	int valid;
	if ( (valid = [self updateWithJulian:j]) != 0)
		return valid;
	// ok!
	return 0;
}

// Inicializa calendario a partir de um KIN MAYA absoluto
- (int)updateWithMayaKin:(int)k {
	int valid;
	// Validate Maya kin
	if ( (valid = [longCount validateMayaKin:k]) != 0)
		return valid;
	// Calcula JDN
	int j = [longCount convertKinToJulian:k];
	// Inicializa com Julian
	if ( (valid = [self updateWithJulian:j]) != 0)
		return valid;
	// ok!
	return 0;
}


@end
