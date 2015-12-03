//
//  TzCalTzolkinMoon.m
//  Maya3D
//
//  Created by Roger on 22/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "TzCalendar.h"
#import "TzGlobal.h"


@implementation TzCalTzolkinMoon

// Distancia do selo guia para o selo destino
// Tabelinha em 13_moon_2008-2009_ElectricStorm.pdf
const int guideOffset[] = {0, 12, 4, -4, 8, 0, 12, 4, -4, 8, 0, 12, 4};

// Genero dos selos
const int sealGender[] = {
MALE, MALE, FEMALE, FEMALE,
FEMALE, MALE, FEMALE, FEMALE,
FEMALE, MALE, MALE, MALE,
MALE, MALE, FEMALE, MALE,
FEMALE, MALE, FEMALE, MALE
};

// Kins que sao portais de ativacao galactica
const char portals[] = {
'x', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 
' ', 'x', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', ' ', 
' ', ' ', 'x', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x', ' ', ' ', ' ', ' ', ' ', ' ', 'x', ' ', ' ', 
' ', ' ', ' ', 'x', ' ', ' ', ' ', ' ', 'x', ' ', ' ', 'x', ' ', ' ', ' ', ' ', 'x', ' ', ' ', ' ', 
' ', ' ', ' ', ' ', 'x', ' ', ' ', 'x', ' ', ' ', ' ', ' ', 'x', ' ', ' ', 'x', ' ', ' ', ' ', ' ', 
' ', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', ' ', ' ', 
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 
' ', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' ', ' ', ' ', 
' ', ' ', ' ', ' ', 'x', ' ', ' ', 'x', ' ', ' ', ' ', ' ', 'x', ' ', ' ', 'x', ' ', ' ', ' ', ' ', 
' ', ' ', ' ', 'x', ' ', ' ', ' ', ' ', 'x', ' ', ' ', 'x', ' ', ' ', ' ', ' ', 'x', ' ', ' ', ' ', 
' ', ' ', 'x', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x', ' ', ' ', ' ', ' ', ' ', ' ', 'x', ' ', ' ', 
' ', 'x', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', ' ', 
'x', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x'
};


#define TZFIRSTKIN		150			// Tzolkin KIN on 0.0.0.0.0
#define TZFIRSTCR		(1862720-1236)	// Calendar Round kin on 1987

@synthesize tone;
@synthesize seal;
@synthesize timecell;
@synthesize portal;
// Related
@synthesize tzGuide;
@synthesize tzAntipode;
@synthesize tzAnalog;
@synthesize tzOccult;

- (void)dealloc {
	if (tzGuide)
		[tzGuide release];
	if (tzAntipode)
		[tzAntipode release];
	if (tzAnalog)
		[tzAnalog release];
	if (tzOccult)
		[tzOccult release];
	
    [super dealloc];
}

// init "PUBLICO"
- (id)init:(int)j {
	return [self init:j adjusted:FALSE];
}
- (id)init:(int)j adjusted:(BOOL)adjusted {
	// Inicializa constantes
	
	// CONSTANTE: Tzolkin KIN on 0.0.0.0.0
	firstKin = TZFIRSTKIN;
	firstCR = TZFIRSTCR;
	
	// Set maya date
	[self updateWithJulian:j adjusted:adjusted];
	
	// Finito!
	return self;
}

// Inicializa com data JULIANA
- (void)updateWithJulian:(int)j {
	[self updateWithJulian:j adjusted:FALSE];
}
// Inicializa com data JULIANA já ajustada (BISEXTOS) ou nao
- (void)updateWithJulian:(int)j adjusted:(BOOL)adjusted {
	// Adjust BISEXTOS?
	if (adjusted == FALSE)
	{
		// AJUSTE DOS ANOS BISEXTOS
		// Ajusta data removendo um dia para cada ano bisexto desde 1987
		TzCalGreg *greg = [[TzCalGreg alloc] init:j];
		j -= greg.bi;
		//AvLog(@"TZOLKIN BI date[%02d-%02d-%02d] bi[%d]",greg.day,greg.month,greg.year,greg.bi);
	}
	
	//
	// SUPER INIT
	//
	[super updateWithJulian:j];
	
	// Tone / 1-13
	//tone = ( (kin+12) % 13 ) + 1;			// +12 para alinhar com 0.0.0.0.0
	self.tone = self.number;
	
	// Seal / 1-19,0
	// O dia, mas com valores diferentes
	// dragon=1 ... storm=19 e sun=0
	self.seal = (self.day % 20);
	
	// Timecell - 5 Grupos de 4 em 4
	self.timecell = ( (self.day-1) / 4 ) + 1;
	
	// Portal de ativacao galactica (VERDES no tzolkin)
	self.portal = ( portals[kin-1] != ' ' ? YES : NO );

	//
	// RELATED DATES : ORACLE
	//
	int kk;
	
	//
	// Oracle: GUIDE
	//
	// Acha SELO relativo ao kin
	kk = kin + guideOffset[tone-1];
	// Acha Kin com SELO encontrado e TOM do self
	kk = [self kinOfSeal:kk withTone:self.tone];
	julianGuide = j - kin + kk;

	//
	// Oracle: ANTIPODE
	//
	// +- 10 from the number of the signature
	// http://forums.tortuga.com/viewtopic.php?p=1596&sid=cb2ad9aa24fbd2a9dcd1719b3f1c27a4
	// 10 a frente
	julianAntipode = j+10;
	// TON: The Antipode Partner always has the same Tone as the day or Destiny Kin
	// Isso sempre acontece 6 colunas além
	julianAntipode += (6*20);
	// >> TOM JA FICA OK!
	
	//
	// Oracle: ANALOG
	//
	// signature # + analog # = 19
	// A soma do SEAL ser 19
	if (seal == 19)		// day 19, analog = 20/0, posterior
		kk = kin+1;
	else if (seal == 0)	// day 0/20, seal = 19, anterior
		kk = kin-1;
	else
	{
		int a = (19 - seal);
		kk = kin + (a - seal);
	}
	// Acha Kin com SELO encontrado e TOM do self
	kk = [self kinOfSeal:kk withTone:self.tone];
	julianAnalog = j - kin + kk;

	//
	// Oracle: OCCULT
	//
	// signature # + Occult # = 21
	// A soma do DIA ser 21
	int o = (21 - day);
	kk = kin + (o - day);
	// Acha Kin com SELO encontrado e TOM...
	// TOM OCULTO + TOM DESTINO = 14
	kk = [self kinOfSeal:kk withTone:(14-self.tone)];
	julianOccult = j - kin + kk;

	// Libera anteriores
	if (tzGuide)
		[tzGuide release];
	if (tzAntipode)
		[tzAntipode release];
	if (tzAnalog)
		[tzAnalog release];
	if (tzOccult)
		[tzOccult release];
	tzGuide = nil;
	tzAntipode = nil;
	tzAnalog = nil;
	tzOccult = nil;

	//AvLog(@"TZOLKIN MOON jAdj[%d] kin[%d] number[%d] tone[%d] day[%d] seal[%d]",j,kin,number,tone,day,seal);
}

// Retorna o numero de dias a frente se encontra o Kin
// j: JDN base
// t:
// com o selo de j
- (int)kinOfSeal:(int)baseKin withTone:(int)targetTone
{
	// Normaliza kin
	if (baseKin < 1)
		baseKin += 260;
	else if (baseKin > 260)
		baseKin -= 260;
	// Selo do meu kin
	int ss = ((baseKin-1)%20)+1;
	// Tom deste selo na 1a coluna
	int tt = ((ss-1)%13)+1;
	// quantas colunas devo adiantar para chegar ao tom desejado?
	// 1 tom = 2 colunas ou 40 kins
	if (tt > targetTone)
		targetTone += 13;
	int cc = (targetTone - tt) * 40;
	// Calcula e normaliza novo Kin
	int newKin = ss + cc;
	while (newKin > 260)
		newKin -= 260;
	// Ok!
	return newKin;
}


#pragma mark PROPERTY GETTERS

// Guia, antipoda, etc...
// ps: O Ano está no TzCalMoon
-(TzCalTzolkinMoon*) getTzGuide {
	if (tzGuide == nil)
	{
		tzGuide = [[TzCalTzolkinMoon alloc] init:julianGuide adjusted:TRUE];
		//AvLog(@"GUIDE    SELF [%d] [%d] [%d] >> [%d] [%d] [%d]",kin,day,number,tzGuide.kin,tzGuide.day,tzGuide.number);
	}
	return tzGuide;
}
-(TzCalTzolkinMoon*) getTzAntipode {
	if (tzAntipode == nil)
	{
		tzAntipode = [[TzCalTzolkinMoon alloc] init:julianAntipode adjusted:TRUE];
		//AvLog(@"ANTIPODE SELF [%d] [%d] [%d] >> [%d] [%d] [%d]",kin,day,number,tzAntipode.kin,tzAntipode.day,tzAntipode.number);
	}
	return tzAntipode;
}
-(TzCalTzolkinMoon*) getTzAnalog {
	if (tzAnalog == nil)
	{
		tzAnalog = [[TzCalTzolkinMoon alloc] init:julianAnalog adjusted:TRUE];
		//AvLog(@"ANALOG   SELF [%d] [%d] [%d] >> [%d] [%d] [%d]",kin,day,number,tzAnalog.kin,tzAnalog.day,tzAnalog.number);
	}
	return tzAnalog;
}
-(TzCalTzolkinMoon*) getTzOccult {
	if (tzOccult == nil)
	{
		tzOccult = [[TzCalTzolkinMoon alloc] init:julianOccult adjusted:TRUE];
		//AvLog(@"OCCULT   SELF [%d] [%d] [%d] >> [%d] [%d] [%d]",kin,day,number,tzOccult.kin,tzOccult.day,tzOccult.number);
	}
	return tzOccult;
}


//
// STRING GETTERS
//
-(NSString*) toneName_get
{
	return [TzCalTzolkinMoon constToneNames:(self.tone)];
}
-(NSString*) toneNameFull_get
{
	if (global.prefLang == LANG_EN)
		return [NSString stringWithFormat:@"%@ Tone of %@",
				self.toneName,
				[TzCalTzolkinMoon constToneEssencesOf:(self.tone)]];
	else // pt / es
		return [NSString stringWithFormat:@"%@ %@ %@",	
				LOCAL(@"TONE"),
				self.toneName,
				[TzCalTzolkinMoon constToneEssencesOf:(self.tone)]];
}
-(NSString*) toneDesc_get
{
	return [TzCalTzolkinMoon constToneDescs:(self.tone)];
}
-(NSString*) toneEssence_get
{
	return [TzCalTzolkinMoon constToneEssences:(self.tone)];
}
-(NSString*) sealLabel_get
{
	return [NSString stringWithFormat:@"%@ %d:",LOCAL(@"SOLAR_SEAL"),self.day];
}
-(NSString*) sealName_get
{
	return [TzCalTzolkinMoon constSealNames:(self.day)];
}
-(NSString*) sealFrase_get
{
	return [NSString stringWithFormat:@"\"%@\"",[TzCalTzolkinMoon constSealFrases:(self.day)]];
}
-(NSString*) sealTags_get
{
	return [TzCalTzolkinMoon constSealTags:(self.day)];
}
-(NSString*) sealDesc_get
{
	return [TzCalTzolkinMoon constSealDescs:(self.day)];
}
-(NSString*)dayName_get
{
	return [TzCalTzolkinMoon constDayName:(self.day)];
}
-(NSString*)dayNameMaya_get
{
	return [TzCalTzolkin constDayName:(self.day)];
}
-(NSString*) dayNameFull_get
{
	return [NSString stringWithFormat:@"%@ %@",self.dayName1,self.dayName2];
}
-(NSString*) dayName1_get
{
	if (global.prefLang == LANG_EN)		// en
		return [NSString stringWithFormat:@"%@ %@",self.colorName,self.toneName];
	else	// pt / es
		return self.dayName;
}
-(NSString*) dayName2_get
{
	// Ful Day name
	if (global.prefLang == LANG_EN)		// en
		return self.dayName;
	else	// pt / es
	{
		// gender
		if (sealGender[self.day-1] == FEMALE)
			return [NSString stringWithFormat:@"%@ %@",
					[TzCalTzolkinMoon constToneNamesFemale:(self.number)],
					[TzCalTzolkinMoon constColorNamesFemale:(self.color)] ];
		else
			return [NSString stringWithFormat:@"%@ %@",self.toneName,self.colorName];
	}
}
-(NSString*) dayMeaning_get
{
	return [TzCalTzolkinMoon constDayMeaning:(self.day)];
}
-(UIColor*)colorUIColor_get
{
	switch (self.color) {
		case 1: return [UIColor redColor];
		case 2: return [UIColor whiteColor];
		case 3: return [UIColor blueColor];
		case 4: return [UIColor yellowColor];
		default: return nil;
	};
}
-(NSString*) colorName_get
{
	return [TzCalTzolkinMoon constColorNames:(self.color)];
}
-(NSString*) colorFamily_get
{
	return [TzCalTzolkinMoon constColorFamilies:(self.color)];
}
-(NSString*) colorPurpose_get
{
	return [TzCalTzolkinMoon constColorPurposes:(self.color)];
}
-(NSString*) colorTag_get
{
	return [TzCalTzolkinMoon constColorTags:(self.color)];
}
-(NSString*) colorDesc_get
{
	return [TzCalTzolkinMoon constColorDescs:(self.color)];
}
-(NSString*) affirmation1_get
{
	return [NSString stringWithFormat:LOCAL(@"AFFIRM1_FORMAT"),
			[TzCalTzolkinMoon constTonePowers:(self.tone)],
			[TzCalTzolkinMoon constSealActions:(self.day)] ];
}
-(NSString*) affirmation2_get
{
	return [NSString stringWithFormat:LOCAL(@"AFFIRM2_FORMAT"),
			[TzCalTzolkinMoon constToneActions:(self.tone)],
			[TzCalTzolkinMoon constSealEssences:(self.day)] ];
}
-(NSString*) affirmation3_get
{
	return [NSString stringWithFormat:LOCAL(@"AFFIRM3_FORMAT"),
			[TzCalTzolkinMoon constTimeCells:(self.timecell)],
			[TzCalTzolkinMoon constSealPowers:(self.day)] ];
}
-(NSString*) affirmation4_get
{
	return [NSString stringWithFormat:LOCAL(@"AFFIRM4_FORMAT"),
			[TzCalTzolkinMoon constToneNames:(self.tone)],
			[TzCalTzolkinMoon constToneEssencesOf:(self.tone)] ];
}
-(NSString*) affirmation5_get
{
	// Se for igual ao GUIA, poder dobrado
	if (self.tzGuide.kin == kin)
		return LOCAL(@"AFFIRM5_DOUBLED");
	else
		return [NSString stringWithFormat:LOCAL(@"AFFIRM5_FORMAT"),
				[TzCalTzolkinMoon constSealPowers:(self.tzGuide.day)] ];
}
-(NSString*) affirmation6_get
{
	if (portal)
		return LOCAL(@"AFFIRM6");
	else
		return @"";
}
//
// IMAGES
//
-(NSString*) imgNum_get
{
	return [NSString stringWithFormat:@"numside%02d.png", self.tone];
}
-(NSString*) imgGlyph_get
{
	return [NSString stringWithFormat:@"seal%02d.png", self.day];
}
-(NSString*) imgPortal_get
{
	if (portal)
		return @"portal_on.png";
	else
		return @"portal_off.png";
}
-(NSString*)imgNews_get
{
	if (self.color == DIR_NORTH)
		return @"news_dreamspell_N.png";
	else if (self.color == DIR_SOUTH)
		return @"news_dreamspell_S.png";
	else if (self.color == DIR_EAST)
	{
		if (global.prefLang == LANG_PT)
			return @"news_dreamspell_L.png";
		else	// en / es
			return @"news_dreamspell_E.png";
	}
	else if (self.color == DIR_WEST)
	{
		if (global.prefLang == LANG_EN)
			return @"news_dreamspell_W.png";
		else	// pt / es
			return @"news_dreamspell_O.png";
	}
	// nao vai chegar aqui, mas...
	else
		return nil;
}


#pragma mark CONSTANTES

//
// CONSTANTES
//
+(NSString*) constDayName:(int)i;		// 1-20
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"SEAL_%02d",i]));
}
+(NSString*) constDayMeaning:(int)i;		// 1-20
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_DAY_MEANING_%02d",i]));
}
+(NSString*) constColorNames:(int)i		// Nomes das cores (1-4)
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_COLOR_%02d",i]));
}
+(NSString*) constColorNamesFemale:(int)i		// Nomes das cores (1-4)
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_COLOR_FEMALE_%02d",i]));
}
+(NSString*) constColorFamilies:(int)i
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_FAMILY_%02d",i]));
}
+(NSString*) constColorPurposes:(int)i
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_COLOR_PURPOSE_%02d",i]));
}
+(NSString*) constColorTags:(int)i
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_COLOR_TAGS_%02d",i]));
}
+(NSString*) constColorDescs:(int)i
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_COLOR_DESC_%02d",i]));
}
+(NSString*) constDirectionName:(int)i;
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_DIRECTION_%02d",i]));
}
+(NSString*) constElementName:(int)i;
{
	if ( i < 1 || i > 4 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_ELEMENT_%02d",i]));
}
+(NSString*) constSealNames:(int)i	// 1-20
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"SEAL_%02d",i]));
}
+(NSString*) constSealFrases:(int)i	// 1-20
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"SEAL_FRASE_%02d",i]));
}
+(NSString*) constSealTags:(int)i	// 1-20
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"SEAL_TAGS_%02d",i]));
}
+(NSString*) constSealDescs:(int)i	// 1-20
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"SEAL_DESC_%02d",i]));
}
+(NSString*) constSealActions:(int)i	// 1-20
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"SEAL_ACTION_%02d",i]));
}
+(NSString*) constSealPowers:(int)i		// 1-20
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"SEAL_POWER_%02d",i]));
}
+(NSString*) constSealEssences:(int)i	// 1-20
{
	if ( i < 1 || i > 20 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"SEAL_ESSENCE_%02d",i]));
}
+(NSString*) constToneNames:(int)i		// Nomes dos tons (1-13)
{
	if ( i < 1 || i > 13 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TONE_%02d",i]));
}
+(NSString*) constToneNamesFemale:(int)i		// Nomes dos tons (1-13)
{
	if ( i < 1 || i > 13 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TONE_FEMALE_%02d",i]));
}
+(NSString*) constToneDescs:(int)i		// Nomes dos tons (1-13)
{
	if ( i < 1 || i > 13 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TONE_DESC_%02d",i]));
}
+(NSString*) constTonePowers:(int)i		// 1-13
{
	if ( i < 1 || i > 13 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TONE_POWER_%02d",i]));
}
+(NSString*) constToneActions:(int)i	// 1-13
{
	if ( i < 1 || i > 13 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TONE_ACTION_%02d",i]));
}
+(NSString*) constToneEssences:(int)i	// 1-13
{
	if ( i < 1 || i > 13 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TONE_ESSENCE_%02d",i]));
}
+(NSString*) constToneEssencesOf:(int)i	// 1-13
{
	if ( i < 1 || i > 13 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"TONE_ESSENCE_OF_%02d",i]));
}
+(NSString*) constTimeCells:(int)i		// 1-5
{
	if ( i < 1 || i > 5 )
		return nil;
	return  LOCAL(([NSString stringWithFormat:@"DREAMSPELL_TIMECELL_%02d",i]));
}
+(NSString*) constOracleDescs:(int)i		// 1-5
{
	switch (i)
	{
		case ORACLE_GUIDE:
			return LOCAL(@"ORACLE_DESC_GUIDE");
		case ORACLE_ANTIPODE:
			return LOCAL(@"ORACLE_DESC_ANTIPODE");
		case ORACLE_DESTINY:
			return LOCAL(@"ORACLE_DESC_DESTINY");
		case ORACLE_ANALOG:
			return LOCAL(@"ORACLE_DESC_ANALOG");
		case ORACLE_OCCULT:
			return LOCAL(@"ORACLE_DESC_OCCULT");
		default:
			return nil;
	}
}
+(NSString*) constOracleNavLabels:(int)i destinyKin:(int)dkin		// 1-5
{
	switch (i)
	{
		case ORACLE_GUIDE:
			return [NSString stringWithFormat:@"%@ %@ %d",LOCAL(@"ORACLE_SELO_GUIDE"),LOCAL(@"FOR_KIN"),dkin];
		case ORACLE_ANTIPODE:
			return [NSString stringWithFormat:@"%@ %@ %d",LOCAL(@"ORACLE_SELO_ANTIPODE"),LOCAL(@"FOR_KIN"),dkin];
		case ORACLE_DESTINY:
			return nil;
		case ORACLE_ANALOG:
			return [NSString stringWithFormat:@"%@ %@ %d",LOCAL(@"ORACLE_SELO_ANALOG"),LOCAL(@"FOR_KIN"),dkin];
		case ORACLE_OCCULT:
			return [NSString stringWithFormat:@"%@ %@ %d",LOCAL(@"ORACLE_SELO_OCCULT"),LOCAL(@"FOR_KIN"),dkin];
		default:
			return nil;
	}
}


@end
