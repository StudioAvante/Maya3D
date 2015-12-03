//
//  GLGear.h
//  Maya3D
//
//  Created by Roger on 11/02/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define DENTE_WIDTH			0.4

#define ROTATE_CW			-1.0	// roda em sentido horario
#define ROTATE_CCW			1.0		// roda em sentido anti-horario

#define TYPE_WHEEL			0		// disco vazado / roda
#define TYPE_PIZZA			1		// disco em pizza

#define TEXTURE_RADIAL		0		// disco vazado / roda
#define TEXTURE_STRIP		1		// disco em pizza

#define DENTE_NOT			0		// Nao tem dentes
#define DENTE_UP			1		// O buraco do dente eh para fora
#define DENTE_DOWN			2		// O buraco do dente eh para dentro

#define LABEL_ALIGN_ROW		0		// Alinha label no centro da sua coluna
#define LABEL_ALIGN_CENTER	1		// Alinha label no centro da roda

#define GOMO_LEN			PI
#define GOMO_WIDTH			2.5
#define GOMO_DEPTH			1.5
#define LABEL_WIDTH			2.0
#define LABEL_GAP			0.35
#define	LABEL_DEPTH			0.1
#define	DISPLAY_SIZE_MIN	12
#define STRIP_LIMIT			20

// Quantos gomos formam uma divisao do disco tipo STRIP
// Deve ser multiplo de todos os discos do tipo STRIP - 365, 260
#define STRIP_SIZE			5

#define DENTE_WIDTH			0.4
#define DENTE_DEPTH			(GOMO_DEPTH)



@class GLObject;
@class GLElements;
@class TzSoundBuffer;
@class TzSoundSine;

@interface GLGear : NSObject {
	BOOL isEnabled;
	NSString *name;
	// Given data
	char type;				// Strip / Pizza
	char typeDenteIn;		// Tipo do dente de dentro
	char typeDenteOut;		// Tipo do dente de fora
	char typeTexture;		// Tipo do textura da roda
	int gomos;
	int strips;				// Grupos de gomos
	int rows;
	int rotation;
	CGFloat gomoLen;
	CGFloat gomoWidth;
	// Calc data
	int gomoArcs;
	int arcs;
	int vertices;
	int verticesStrip;
	CGFloat centerX;
	CGFloat centerY;
	CGFloat labelWidth;
	CGFloat labelHeight;
	// Vertices dos lados
	int denteUpVertex;
	int denteUpSideVertex;
	int denteDownVertex;
	int denteDownSideVertex;
	// Circle
	GLfloat	gomoAng;		// em radianos
	GLfloat	arcAng;			// em radianos
	GLfloat	arcOut;
	GLfloat	arcIn;
	GLfloat	circOut;
	GLfloat	circIn;
	GLfloat	diamOut;
	GLfloat	diamIn;
	GLfloat	radiusOut;
	GLfloat	radiusIn;
	GLfloat	radiusCenter;
	GLfloat	radiusRow[2];
	// GL Objects
	GLObject *glObject;
	GLElements *glSideOut;
	GLElements *glSideIn;
	GLElements *glDenteOut;
	GLElements *glDenteIn;
	GLElements *glLabels[2];
	// Current data
	int currentGomo;			// Gomo corrente (no centro)
	GLfloat currentAng;			// Angulo corrente (no centro)
	int displaySizeMin;			// Quantos gomos na tela (minimo)
	int displaySizeMax;			// Quantos gomos na tela (maximo)
	int displaySize;			// Quantos gomos na tela (atual)
	int displaySideIn;			// Quantos de sides na tela (atual)
	int displaySideOut;			// Quantos de sides na tela (atual)
	int gomoIni;				// gomo inicial a ser mostrado
	int sideIniIn;				// SIDE inicial a ser mostrado
	int sideIniOut;				// SIDE inicial a ser mostrado
	// Sound Buffers
	TzSoundSine **sines;		// Sound buffer de cada gomo
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) GLfloat gomoWidth;
@property (nonatomic) GLfloat gomoAng;
@property (nonatomic) GLfloat gomoLen;
@property (nonatomic) GLfloat labelWidth;
@property (nonatomic) GLfloat labelHeight;
@property (nonatomic) GLfloat arcOut;
@property (nonatomic) GLfloat arcIn;
@property (nonatomic) GLfloat radiusOut;
@property (nonatomic) GLfloat radiusIn;
@property (nonatomic, setter=setDisplaySizeMax:) int displaySizeMax;


- (id)init:(int)g type:(char)t denteOut:(char)dout denteIn:(char)din rot:(int)r;
- (id)init:(int)g type:(char)t denteOut:(char)dout denteIn:(char)din rot:(int)r gomol:(CGFloat)gl gomow:(CGFloat)gw rows:(int)r;
- (BOOL)isStrip;
- (void)makeDisplayArray;
- (void)setDisplaySizeMax:(int)s;
- (void)setDisplayZoom:(CGFloat)z;
// GL Objects
- (void)createObject;
- (void)createMeshWheel;
- (void)createMeshPizza;
- (void)createSidesOut;
- (void)createSidesIn;
- (void)createMeshSideOut2;
- (void)createMeshSideIn2;
- (void)createMeshSideOut3;
- (void)createMeshSideIn3;
// Labels
- (void)addLabelNew:(int)row pos:(int)n align:(int)align texname:(NSString*)texname map:(int)map;
- (CGPoint)rotateXY:(GLfloat)x :(GLfloat)y ang:(GLfloat)ang;
// Translations
- (void)setTranslate:(GLfloat)cx :(GLfloat)cy :(GLfloat)cz;
- (void)setRotate:(int)g:(GLfloat)dec;
// Bind Data
- (void)bindData;
// Enable/Disable
- (void)enable;
- (void)disable;
- (void)highlight:(BOOL)h;
// Sound Buffers
- (void)makeSoundBuffers:(int)oct;
-(TzSoundBuffer*) currentSoundBuffer;
// Math
- (GLfloat)angInit:(int)n;
- (BOOL)isInside:(CGFloat)x:(CGFloat)y;
- (BOOL)isAround:(CGFloat)x:(CGFloat)y;
- (CGFloat)angTo:(CGFloat)x:(CGFloat)y;
- (CGFloat)angDiff:(CGFloat)ang1:(CGFloat)ang2;


@end
