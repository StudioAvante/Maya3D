//
//  TzDatebook.m
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzDatebook.h"


@implementation TzDatebook

- (id)init
{
	// "O" Datebook
	theDatebook = [[NSMutableArray alloc] init];

	// Datebook > Fixed dates
	NSMutableArray *datebookFixedDates = [[NSMutableArray alloc] init];
	// TODAY
	TzDate *dt = [[TzDate alloc] init];
	[datebookFixedDates addObject:dt];
	[dt release];
	// 0.0.0.0.0
	dt = [[TzDate alloc] initJulian:(CORRELATION):LOCAL(@"MAYAN_ERA_START")];
	[datebookFixedDates addObject:dt];
	[dt release];
	// 13.0.0.0.0
	dt = [[TzDate alloc] initJulian:(CORRELATION+MAYANERAKINS):LOCAL(@"MAYAN_ERA_END")];
	[datebookFixedDates addObject:dt];
	[dt release];
	// 20.0.0.0
	dt = [[TzDate alloc] initJulian:(CORRELATION+PIKTUNKINS-1):LOCAL(@"PIKTUN_END")];
	[datebookFixedDates addObject:dt];
	[dt release];
	// Gregorian Calendar Reform (papal bull)   - 24/02/1582 - 2298928
	// Gregorian Calendar Reform (efetivamente) - 15/10/1582 - 2299161
	dt = [[TzDate alloc] initJulian:2299161:LOCAL(@"GREGORIAN_REFORM")];
	[datebookFixedDates addObject:dt];
	[dt release];
	// Colombo - 12/10/1492
	//dt = [[TzDate alloc] initJulian:2266287:LOCAL(@"COLUMBUS_AMERICA")];
	//[datebookFixedDates addObject:dt];
	
	// DREAMSPELL ONLY
	if (ENABLE_DREAMSPELL)
	{
		// Pacal Votan BIRTH - 9.8.9.13.0 - 8 Ahau 13 Pop -	March 24, 603 AD - 1941383 JD
		// Pacal Votan KING - July 27, 615 AD - 5 Lamat 1 Mol - 9.9.2..4.8 - 1945891 JD
		// Pacal Votan DEATH - 9.12.11.5.18 - 29 August 683 - 1970761 JD
		// Pacal Votan BURIAL - 9.13.0.0.0 - 16/03/692 - 1973883 JD
		dt = [[TzDate alloc] initJulian:1973883:LOCAL(@"PACAL_BURIAL")];
		[datebookFixedDates addObject:dt];
		[dt release];
		// Pacal Votan OPENING - June 15 1952
		dt = [[TzDate alloc] initJulian:2434179:LOCAL(@"PACAL_OPENING")];
		[datebookFixedDates addObject:dt];
		[dt release];
		// 13-moon Dreamspell init - 26/07/1987
		dt = [[TzDate alloc] initJulian:(DREAMSPELL_JULIAN):LOCAL(@"DREAMSPELL_INIT")];
		[datebookFixedDates addObject:dt];
		[dt release];
	}
	
	// Datas fixas
	//AvLog(@"DATEBOOOK: popula lista fixa...");
	for (int n = 0 ; n < [datebookFixedDates count] ; n++)
	{
		// Cria array de TzDate
		//TzDate *fix = (TzDate*)[datebookFixedDates objectAtIndex:n];
		TzDate *dt =  (TzDate*)[datebookFixedDates objectAtIndex:n];
		dt.fixed = TRUE;
		dt.pickerView.highlighted = FALSE;
		//AvLog(@"TZOLKIN: add to picker: date[%d] *[%d] = %d %s (vis=%d) (fix=%d)", n, dt, dt.julian, [dt.desc UTF8String], dt.visible, dt.fixed);
		//[dateList addObject:(id)dt];
		[self addDate:dt];
	}
    [datebookFixedDates release];
	
	// Datas doDATEBOOOKUsuario
	//AvLog(@"DATEBOOOK: popula lista do usuario...");
	[self readFromXML];
	
	// Ok
	//[self debugList];
	return self;	
}

// Add dates to rows at the right position (cronologicamente)
- (void)debugList
{
	//debug
	AvLog(@"DATEBOOK has [%d] TzDate", [theDatebook count]);
	for (int n = 0 ; n < [theDatebook count] ; n++)
	{
		TzDate *dt =  (TzDate*)[theDatebook objectAtIndex:n];
		AvLog(@"DATEBOOK: DATELIST[%d] *[%d] j[%d] [%s]", n, dt, dt.julian, [dt.desc UTF8String]);
	}
}

// ADD: Inclui datas cronologicamente
- (void)addDate:(TzDate*)dt
{
	// inicio ao fim
	for (int n = 0 ; n < ([theDatebook count]) ; n++)
	{
		if (dt.julian < ((TzDate*)[theDatebook objectAtIndex:n]).julian)
		{
			[theDatebook insertObject:(id)dt atIndex:n];
			return;
		}
	}
	[theDatebook addObject:(id)dt];
    
}

// EDIT: Atualiza uma data (descricao)
- (void)updateDate:(int)i :(NSString*)desc
{
	TzDate *dt =  (TzDate*)[theDatebook objectAtIndex:i];
	[dt setDescription:desc];
}

// REMOVE: Remove uma Data
- (BOOL)removeDate:(int)j
{
	// inicio ao fim
	for (int n = 0 ; n < ([theDatebook count]) ; n++)
	{
		if (j == ((TzDate*)[theDatebook objectAtIndex:n]).julian)
		{
			[theDatebook removeObjectAtIndex:n];
			return TRUE;
		}
	}
	return FALSE;
}
- (BOOL)removeItem:(int)i
{
	// Verifica se o item existe
	if ([theDatebook count] < (i+1))
		return FALSE;
	// Remove!
	[theDatebook removeObjectAtIndex:i];
	return TRUE;
}

// EXISTS: Verifica se uma data NAO FIXA ja esta no datebook
- (BOOL)dateExists:(int)j
{
	// inicio ao fim
	for (int n = 0 ; n < ([theDatebook count]) ; n++)
	{
		TzDate *dt = (TzDate*)[theDatebook objectAtIndex:n];
		if (j == dt.julian && dt.fixed == FALSE)
			return TRUE;
	}
	return FALSE;
}

#pragma mark Serialization

// Recupera nome do arquivo XML
- (NSString*)getXMLFilename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask, YES);
	NSString *path = [NSString stringWithFormat:@"%@/userdates.xml",[paths objectAtIndex:0]];
	//AvLog(@"XML PATH: [%@]", path);
	//NSString *path = nil;
	return path;
}
// Le todas as datas do usuario de um arquivo XML
- (BOOL)readFromXML {
	NSString *path = [self getXMLFilename];
	NSDictionary *dict = nil;
	NSData *xmlData = nil;
	NSString *error = nil;
	NSPropertyListFormat format;
	// Recupera arquivo XML
	xmlData = [NSData dataWithContentsOfFile:path];
	dict = (NSDictionary*) [NSPropertyListSerialization
							propertyListFromData:(id)xmlData
							mutabilityOption:NSPropertyListImmutable
							format:&format
							errorDescription:&error];
	
	// Empty!?
	if(!dict)
	{
		AvLog(@"XML ERROR... %@", error);
		[error release];
		return FALSE;
	}
	
	// Popula Datebook
	NSString *key;
	NSString *value;
	for (id key in dict)
	{
		value =  [dict objectForKey:key];
		//AvLog(@"READ XML: key[%@] value[%@]", key, value);
		TzDate *dt =  (TzDate*)[[TzDate alloc] initJulian:(int)[key integerValue]:value];
		dt.fixed = FALSE;
		dt.pickerView.highlighted = TRUE;
		[self addDate:dt];
		[dt release];
	}
	key = @"dummy"; // so pra evitar warning
	//[dict release];
	//AvLog(@"XML READ OK!!!!");
	return TRUE;
}

// SALVA todas as datas do usuario de um arquivo XML
- (BOOL)saveToXML {
	NSString *path = [self getXMLFilename];
	NSDictionary *dict = [self makeXMLDictionary];
	NSData *xmlData = nil;
	NSString *error = nil;
	// Grava arquivo XML
	xmlData = [NSPropertyListSerialization
			   dataFromPropertyList:(id)dict
			   format:NSPropertyListXMLFormat_v1_0
			   errorDescription:&error];
	if(xmlData)
	{
		AvLog(@"SAVING XML....");
		[xmlData writeToFile:path atomically:YES];
		//[dict release];
		AvLog(@"XML SAVE OK!!!");
		return TRUE;
	}
	else
	{
		AvLog(@"XML ERROR... %@", error);
		[error release];
		return FALSE;
	}
	[dict release];
}
// Retorna um dictionary com todas as datas do usuario para gravar em XML
- (NSDictionary*)makeXMLDictionary {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	// inicio ao fim
	for (int n = 0 ; n < ([theDatebook count]) ; n++)
	{
		TzDate *dt = (TzDate*)[theDatebook objectAtIndex:n];
		if (dt.fixed)
			continue;
		NSString *key = [NSString stringWithFormat:@"%d",dt.julian];
		NSString *value = dt.text;
		//AvLog(@"DICT key[%@] value[%@]", key, value);
		[dict setValue:value forKey:key];
	}
	[self debugDatebookDict:dict];
	return dict;
}
// DEBUG
- (void)debugDatebookDict:(NSMutableDictionary*)dict {
	NSString *key;
	NSString *value;
	for (id key in dict)
	{
		value =  [dict objectForKey:key];
		AvLog(@"DICT: key[%@] value[%@]", key, value);
	}
	key = @"dummy";		// so pra evitar warning
}


#pragma mark NSMutableArray primitive methods

- (unsigned)count {
	return (unsigned)[theDatebook count];
}
- (id)objectAtIndex:(unsigned)index {
	return [theDatebook objectAtIndex:index];
}



#pragma mark DESTRUCTION

- (void)dealloc {
    [theDatebook release];
    [super dealloc];
}


@end
