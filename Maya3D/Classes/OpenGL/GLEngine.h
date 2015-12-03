//
//  GLEngine.h
//  Maya3D
//
//  Created by Roger on 02/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gl3DView.h"
#import "GLGear.h"

@class Maya3DVC;
@class GLObject;

@interface GLEngine : Gl3DView {
	Maya3DVC *myVC;
	// Maya Gears
	GLGear *maya20;
	GLGear *maya13;
	GLGear *maya365;
	GLGear *maya9;
	CGFloat mayaOffsetX;
	// Dreamspell Gears
	GLGear *dreamspell20;
	GLGear *dreamspell13;
	GLGear *dreamspell260;
	GLGear *dreamspell7;
	GLGear *dreamspell365;
	CGFloat dreamspellOffsetX;
	// Splash screen
	GLGear *splash13;
	GLGear *splash33a;
	GLGear *splash33b;
	// Touches
	CGPoint touchLast;				// Ultimo ponto do toque
	CGFloat angLast;				// Ultimo angulo da engrenagem tocada
	GLGear *touchGear;				// Engrenagem sendo tocada
	double secsLast;				// Quantos segundos o ultimo toque incrementou no relogio
	CFAbsoluteTime timeLast;		// Data do ultimo toque
	CGFloat distanceLast;			// MULTI - Ultima distancia entre dedos
	BOOL clockWasPlaying;			// Estado do Clock no inicio dos toques
	// Auto Zoom
	BOOL autoZoom;					// Está aplicando auto Zoom?
	CGFloat autoZoomIni;			// Auto zoom: Largura inicial
	CGFloat autoZoomFim;			// Auto zoom: Largura final da tela
	CFAbsoluteTime autoZoomStart;	// Auto zoom: Data de inicio
}

@property (nonatomic, assign) Maya3DVC *myVC;


// Maya Engine
- (void)setupGearsMaya;
- (void)setupGearsDreamspell;
- (void)setupGearsSplash;
// GL3DView
- (void)draw3DView:(void*)o;
- (void)draw3DView;
- (void)drawObjects;
// pos TO GL correction
- (CGPoint)convViewPosToGL:(CGPoint)vpos;
// Touches
- (void)endRoll;
- (void)updateNames;
// Auto Zoom
- (void)startAutoZoom:(CGFloat)i:(CGFloat)f;
- (void)applyAutoZoom;
- (void)stopAutoZoom;
// Sounds
- (void)playChord;


@end
