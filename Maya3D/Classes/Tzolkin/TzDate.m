//
//  TzDate.m
//  Maya3D
//
//  Created by Roger on 04/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzDate.h"

@implementation TzDate

// Data
@synthesize julian;
@synthesize secs;
@synthesize greg;
@synthesize dateAdded;
@synthesize text;
@synthesize desc;
@synthesize visible;
@synthesize today;
@synthesize fixed;
@synthesize pickerView;

// DESTRUCTOR
- (void)dealloc {
	[desc release];
	[greg release];
	[pickerView release];
	[super dealloc];
}

// CONSTRUCTOR - TODAY
- (id)init{
	today = TRUE;
	// Get current date/time
	// Absolute time: seconds since Jan 1 2001 00:00:00 GMT.
	CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
	now += CFTimeZoneGetSecondsFromGMT (CFTimeZoneCopySystem(), now);
	// Dia Juliano
	int j = ABSTIMEJULIAN + (now/(24*60*60));
	// Seconds
	secs = ( ((int)now) % (24*60*60) );
	// Initialize with TODAY
	return [self initJulian:j:LOCAL(@"TODAY")];
}
// CONSTRUCTOR - JULIAN
- (id)initJulian:(int)j {
	return [self initJulian:(int)j:(NSString*)nil];
}
// CONSTRUCTOR - JULIAN
- (id)initJulian:(int)j :(NSString*)d {
	if ([super init] == nil)
		return nil;
	// Julian Day Number
	julian = j;
	// Data Gregoriana
	greg = [[TzCalGreg alloc] init:j];
	// Data de inclusao no DateBook
	dateAdded = j;
	// Visibilidade (DateBook)
	visible = TRUE;
	// Data fixa (usuario nao pode deletar!)
	fixed = FALSE;
	// Horario default = 12:00
	if (today == FALSE)	// Se nao recuperou hora de hoje, usa default
		secs = (SECONDS_PER_DAY/2);

	// Cria view para o picker
	pickerView = [[CustomPickerView alloc] init:(fixed)];
	pickerView.title = desc;
	//[pickerView release];

	// Data gregoriana por extenso, de acorco com Settings
	[self setDescription:d];

	//AvLog(@"TZOLKIN: TzDate=%d / %s / %s", julian, [gregName UTF8String], [desc UTF8String]);
	return self;
}

// Monta data gregoriana por extenso
- (void)setDescription:(NSString*)d {
	// Descricao
	if (d)
		text = [[NSString alloc] initWithString:d];
	desc = [[NSString alloc] initWithFormat:@"%@ : %@", greg.dayNameNum, d];
	// Atualiza view do Picker
	pickerView.title = desc;
	[pickerView setNeedsDisplay];
	//AvLog(@"TZOLKIN: SetDescription: %s", [desc UTF8String]);
}

@end
