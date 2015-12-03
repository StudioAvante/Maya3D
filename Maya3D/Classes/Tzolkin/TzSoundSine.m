//
//  TzSoundSine.m
//  Maya3D
//
//  Created by Roger on 13/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "TzSoundSine.h"
#import "TzSoundManager.h"
#import "Tzolkin.h"


@implementation TzSoundSine


// destructor
- (void)dealloc {
	// super
	[super dealloc];
}



#pragma mark SINE HERTZ

// Init buffer
- (id)initWithHertz:(CGFloat)hz length:(CGFloat)s fade:(BOOL)fade
{
	// super init
	if ((self = [super initWithSecs:s]) == nil)
		return nil;
	
	// Make Sine Wave
	hertz = hz;
	[self makeSine:hertz fade:fade];
	//AvLog(@"MAKE SINE hz[%.1f] secs[%.2f]",hz,secs);
	
	//Ok!
	return self;
}

// Inicializa em uma oitava "oct", sua fracao "dec"
- (id)initWithOct:(int)oct dec:(CGFloat)dec length:(CGFloat)s fade:(BOOL)fade
{
	// super init
	if ((self = [super initWithSecs:s]) == nil)
		return nil;
	
	// Make Oct Sine Wave
	hertz = [self octToHertz:oct dec:dec];
	[self makeSine:hertz fade:fade];
	//AvLog(@"MAKE SINE hz[%.1f] secs[%.2f]",hz,secs);
	
	//Ok!
	return self;
}


#pragma mark GENERATORS

//
// Make SINE WAVE
//
- (void)makeSine:(CGFloat)hz fade:(BOOL)fade
{
	// Amplitude (valor maximo de 16 bits)
	short a = AMPLITUDE_16BIT;
	// SampleFreq
	CGFloat freq = ( (2 * PI * hz) / SAMPLE_RATE);
	
	// Cria frames
	for ( UInt32 f = 0 ; f < frames ; f++ )
	{
		// Lower amplitude?
		if (fade)
			a = ( AMPLITUDE_16BIT * ((CGFloat)(frames-f) / (CGFloat)frames) );
		// Calc frame
		buffer[f] = (UInt32)( a * sinf(f*freq) );
		// Copy channel
		buffer[f] += (UInt32)( buffer[f] << 16 );
	}
}


//
// Make Hertz from Octave + fraction
//
//	Oct		Notes		MIDI		'A' Freq
//	0		C-1 – B-1 	0 – 11		13.75
//	1		C0 – B0 	12 – 23 	27.5
//	2		C1 – B1 	24 – 35 	55
//	3		C2 – B2 	36 – 47 	110
//	4		C3 – B3 	48 – 59 	220
//	5		C4 – B4 	60 – 71 	440		< A4 = 69
//	6		C5 – B5 	72 – 83 	880
//	7		C6 – B6 	84 – 95 	1760
//	8		C7 – B7 	96 – 107 	3520
//	9		C8 – B8 	108 – 119 	7040
//	10		C9 – G9 	120 – 127 	14080
//
- (CGFloat)octToHertz:(int)oct dec:(CGFloat)dec
{
	// Find MIDI note
	CGFloat midi = (dec * 12) + (oct * 12.0);
	
	// Calc hz
	// f = 2^(n/12) × 440 Hz
	CGFloat hz = powf(2.0,((midi-69)/12)) * 440.0;
	//AvLog(@"OCT_2_HERTZ oct[%d] dec[%.2f] midi[%.2f] hx[%.2f]",oct,dec,midi,hz);
	
	// Return Hertz
	return hz;
}



@end
