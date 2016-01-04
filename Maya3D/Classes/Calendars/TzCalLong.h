//
//  TzCalLong.h
//  Maya3D
//
//  Created by Roger on 01/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tzolkin.h"

// Definicao da classe
@interface TzCalLong : NSObject {
	int abskin;
	int baktun;		// 0-19
	int katun;		// 0-19
	int tun;			// 0-19
	int uinal;		// 0-17
	int kin;			// 0-19
}

@property (nonatomic) int abskin;
@property (nonatomic) int baktun;
@property (nonatomic) int katun;
@property (nonatomic) int tun;
@property (nonatomic) int uinal;
@property (nonatomic) int kin;
// METHOS GETTERS
@property (nonatomic, readonly, getter=nameBaktun_get)		NSString *nameBaktun;
@property (nonatomic, readonly, getter=nameKatun_get)		NSString *nameKatun;
@property (nonatomic, readonly, getter=nameTun_get)			NSString *nameTun;
@property (nonatomic, readonly, getter=nameUinal_get)		NSString *nameUinal;
@property (nonatomic, readonly, getter=nameKin_get)			NSString *nameKin;
// images - numbers
@property (nonatomic, readonly, getter=imgBaktunNum_get)	NSString *imgBaktunNum;
@property (nonatomic, readonly, getter=imgKatunNum_get)		NSString *imgKatunNum;
@property (nonatomic, readonly, getter=imgTunNum_get)		NSString *imgTunNum;
@property (nonatomic, readonly, getter=imgUinalNum_get)		NSString *imgUinalNum;
@property (nonatomic, readonly, getter=imgKinNum_get)		NSString *imgKinNum;
// images - glyphs
/*
 @property (nonatomic, readonly, getter=imgBaktunGlyph_get)	NSString *imgBaktunGlyph;
@property (nonatomic, readonly, getter=imgKatunGlyph_get)	NSString *imgKatunGlyph;
@property (nonatomic, readonly, getter=imgTunGlyph_get)		NSString *imgTunGlyph;
@property (nonatomic, readonly, getter=imgUinalGlyph_get)	NSString *imgUinalGlyph;
@property (nonatomic, readonly, getter=imgKinGlyph_get)		NSString *imgKinGlyph;
*/


- (id)init:(int)j;
- (void)updateWithJulian:(int)j;
// Conversores
- (int)convertMayaToJulian:(int)b :(int)k :(int)t :(int)u :(int)i;
- (int)convertKinToJulian:(int)k;
- (int)validateMayaKin:(int)k;

@end
