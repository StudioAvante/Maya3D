//
//  TzCalLong.m
//  Maya3D
//
//  Created by Roger on 01/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzCalendar.h"

@implementation TzCalLong


// Data
@synthesize baktun;
@synthesize abskin;
@synthesize katun;
@synthesize tun;
@synthesize uinal;
@synthesize kin;

// Inicializa calendario a partir de uma data JULIANA
- (id)init:(int)j {
	if ([super init] == nil)
		return nil;
	// Set maya date
	[self updateWithJulian:j];
	return self;
}

// Inicializa calendario a partir de uma data JULIANA
- (void)updateWithJulian:(int)j {
	// Find Absolute Kin Number
	abskin = (j - JULIAN_MIN);
	// LONG COUNT
	baktun = floor((abskin/(20*18*20*20))%20);
	katun = floor((abskin/(20*18*20))%20);
	tun = floor((abskin/(20*18))%20);
	uinal = floor((abskin/20)%18);
	kin = (abskin % 20);
}

#pragma mark CONVERSORES

// Converte data MAYA em memoria para JULIAN DAY NUMBER
- (int)convertMayaToJulian:(int)b :(int)k :(int)t :(int)u :(int)i {
	return JULIAN_MIN + i + (u*20) + (t*20*18) + (k*20*18*20) + (b*20*18*20*20);
}
// Inicializa calendario a partir de um KIN MAYA absoluto
- (int)convertKinToJulian:(int)k {
	// Calcula JDN
	return (k +  JULIAN_MIN);
}

// Valida kin maya: Verifica se esta no limite de 1 PIKTUN
- (int)validateMayaKin:(int)k
{
	if (k < 0)
		return -1;
	else if (k >= PIKTUNKINS)
		return 1;
	else
		return 0;
}


#pragma mark METHOD GETTERS

// METHOS GETTERS
-(NSString*)nameBaktun_get
{
	return [NSString stringWithFormat:@"%d %@",baktun,LOCAL(@"LONG_BAKTUN")];
}
-(NSString*)nameKatun_get
{
	return [NSString stringWithFormat:@"%d %@",katun,LOCAL(@"LONG_KATUN")];
}
-(NSString*)nameTun_get
{
	return [NSString stringWithFormat:@"%d %@",tun,LOCAL(@"LONG_TUN")];
}
-(NSString*)nameUinal_get
{
	return [NSString stringWithFormat:@"%d %@",uinal,LOCAL(@"LONG_UINAL")];
}
-(NSString*)nameKin_get
{
	return [NSString stringWithFormat:@"%d %@",kin,LOCAL(@"LONG_KIN")];
}
// Images - NUMBERS
-(NSString*)imgBaktunNum_get
{
	return [NSString stringWithFormat:@"numglyph%02d.png", baktun];
}
-(NSString*)imgKatunNum_get
{
	return [NSString stringWithFormat:@"numglyph%02d.png", katun];
}
-(NSString*)imgTunNum_get
{
	return [NSString stringWithFormat:@"numglyph%02d.png", tun];
}
-(NSString*)imgUinalNum_get
{
	return [NSString stringWithFormat:@"numglyph%02d.png", uinal];
}
-(NSString*)imgKinNum_get
{
	return [NSString stringWithFormat:@"numglyph%02d.png", kin];
}
// images - GLYPHS
/*
-(NSString*)imgBaktunGlyph_get
{
	return @"long_baktun.png";
}
-(NSString*)imgKatunGlyph_get
{
	return @"long_katun.png";
}
-(NSString*)imgTunGlyph_get
{
	return @"long_tun.png";
}
-(NSString*)imgUinalGlyph_get
{
	return @"long_uinal.png";
}
-(NSString*)imgKinGlyph_get
{
	return @"long_kin.png";
}
*/



@end
