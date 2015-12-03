//
//  GLEngine.m
//  Maya3D
//
//  Created by Roger on 02/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "GLEngine.h"
#import "Maya3DVC.h"
#import "TzClock.h"
#import "TzGlobal.h"
#import "TzCalendar.h"
#import "TzSoundManager.h"
#import "GLObject.h"


@implementation GLEngine

@synthesize myVC;

- (void)dealloc {
	//Splash
	if (MAKE_SPLASH)
	{
		[splash13 release];
		[splash33a release];
		[splash33b release];
	}
	else
	{
		// Maya
		if (ENABLE_MAYA)
		{
			[maya20 release];
			[maya13 release];
			[maya9 release];
			[maya365 release];
		}
		// Dreamspell
		if (ENABLE_DREAMSPELL)
		{
			[dreamspell260 release];
			[dreamspell20 release];
			[dreamspell13 release];
			[dreamspell365 release];
			[dreamspell7 release];
		}
	}

	// super...
	[super dealloc];
}


// FROM NIB
// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
/*
 - (id)initWithCoder:(NSCoder*)coder {
	// super init
    if ((self = [super initWithCoder:coder]) == nil)
		return nil;
	return self;
}
*/

// Roger
- (id)initWithFrame:(CGRect)frame {
	// super init
    if ((self = [super initWithFrame:frame]) == nil)
		return nil;
	
	// Create GL Objects
	if (MAKE_SPLASH)
		[self setupGearsSplash];
	else
	{
		if (ENABLE_MAYA)
			[self setupGearsMaya];
		if (ENABLE_DREAMSPELL)
			[self setupGearsDreamspell];
	}
	
	// Start thread
	//[NSThread detachNewThreadSelector:@selector(draw3DView:) toTarget:self withObject:nil];
	
	// Start Auto Zoom
	[self startAutoZoom:CAMERA_WIDTH_MAX :CAMERA_WIDTH];

	// Finito!
	return self;
}

//
// SETUP GEARS
//
- (void)setupGearsMaya {
	CGFloat x;
	
	// Window Offset
	mayaOffsetX = -1.0;
	
	//
	// MAYA TZOLKN 20
	//
	maya20 = [[GLGear alloc] init:20 
								type:TYPE_WHEEL
							denteOut:DENTE_DOWN 
							 denteIn:DENTE_DOWN
								 rot:ROTATE_CCW];
	x = -( 0.2 + maya20.radiusOut );
	[maya20 setTranslate:x :0.0 :0.0];
	maya20.name = LOCAL(@"GEAR_NAME_MAYA_20");
	//[maya20 makeSoundBuffers:5];
	// Labels
	for (int n = 0 ; n < 20 ; n++ )
		[maya20 addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:@"tzday_map" map:n];
	// Bind!
	[maya20 bindData];

	//
	// MAYA TZOLKN 13
	//
	maya13 = [[GLGear alloc] init:13 
								type:TYPE_WHEEL
							denteOut:DENTE_UP
							 denteIn:DENTE_NOT
								 rot:ROTATE_CCW 
							   gomol:maya20.arcIn 
							   gomow:2.0
								rows:1 ];
	x = -( 0.2 + maya20.gomoWidth + 0.4 + maya13.radiusOut );
	[maya13 setTranslate:x :0.0 :0.0];
	maya13.name = LOCAL(@"GEAR_NAME_MAYA_13");
	//[maya13 makeSoundBuffers:6];
	// Labels
	for (int n = 0 ; n < 13 ; n++ )
		[maya13 addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:@"num_map" map:(n+1)];
	// Bind!
	[maya13 bindData];

	//
	// MAYA HAAB 365 - CCW
	//
	maya365 = [[GLGear alloc] init:365 
							  type:TYPE_WHEEL
						  denteOut:DENTE_UP
						   denteIn:DENTE_UP
							   rot:ROTATE_CW 
							 gomol:maya20.arcOut 
							 gomow:(maya20.gomoWidth+maya20.labelWidth)
							  rows:2 ];
	x = ( 0.2 + maya365.radiusOut);
	[maya365 setTranslate:x :0.0 :0.0];
	maya365.displaySizeMax = 20;
	[maya365 setDisplayZoom:super.zoomSize];
	maya365.name = LOCAL(@"GEAR_NAME_MAYA_365");
	//[maya365 makeSoundBuffers:4];
	// Labels Row 1
	for (int n = 0 ; n < 365 ; n++ )
		[maya365 addLabelNew:1 pos:n align:LABEL_ALIGN_ROW texname:@"uinal_map" map:(n/20)];
	// Labels Row 0
	maya365.labelWidth = maya13.labelWidth;
	maya365.labelHeight = maya13.labelHeight;
	for (int n = 0 ; n < 365 ; n++ )
		[maya365 addLabelNew:0 pos:n align:LABEL_ALIGN_ROW texname:@"num_map" map:(n%20)];
	// Bind!
	[maya365 bindData];
	
	//
	// MAYA 9 - LORDS
	//
	maya9 = [[GLGear alloc] init:9 
							type:TYPE_WHEEL
						denteOut:DENTE_DOWN
						 denteIn:DENTE_NOT
							 rot:ROTATE_CW
						   gomol:maya20.gomoLen
						   gomow:maya20.gomoWidth
							rows:1 ];
	x = ( 0.2 + maya365.gomoWidth + 0.4 + maya9.radiusOut);
	[maya9 setTranslate:x :0.0 :0.0];
	maya9.name = LOCAL(@"GEAR_NAME_MAYA_9");
	//[maya9 makeSoundBuffers:3];
	// Labels
	maya9.labelWidth *= 0.9;
	maya9.labelHeight *= 0.9;
	for (int n = 0 ; n < 9 ; n++ )
		[maya9 addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:@"lords_map" map:n];
	// Bind!
	[maya9 bindData];
}



//
// SETUP GEARS
//
- (void)setupGearsDreamspell {
	CGFloat x;
	
	// Window Offset
	dreamspellOffsetX = 0.65;
	
	//
	// DREAMSPELL TZOLKN 260
	//
	dreamspell260 = [[GLGear alloc] init:260 
									type:TYPE_WHEEL
								denteOut:DENTE_UP
								 denteIn:DENTE_UP
									 rot:ROTATE_CCW ];
	x = -( 0.2 + dreamspell260.radiusOut );
	[dreamspell260 setTranslate:x :0.0 :0.0];
	dreamspell260.displaySizeMax = 20;
	[dreamspell260 setDisplayZoom:super.zoomSize];
	dreamspell260.name = LOCAL(@"GEAR_NAME_DREAMSPELL_260");
	// Labels
	for (int n = 0 ; n < 260 ; n++ )
		[dreamspell260 addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:(n<255?@"kin_map1":@"kin_map2") map:((n+1)%256)];
	// Bind!
	[dreamspell260 bindData];

	//
	// DREAMSPELL TZOLKN 20
	//
	dreamspell20 = [[GLGear alloc] init:20 
								   type:TYPE_WHEEL
							   denteOut:DENTE_DOWN
								denteIn:DENTE_DOWN
									rot:ROTATE_CCW ];
	x = -( 0.2 + dreamspell20.radiusOut +0.4 + dreamspell260.gomoWidth);
	[dreamspell20 setTranslate:x :0.0 :0.0];
	dreamspell20.name = LOCAL(@"GEAR_NAME_DREAMSPELL_20");
	// Labels
	for (int n = 0 ; n < 20 ; n++ )
		[dreamspell20 addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:@"seal_map" map:n];
	// Bind!
	[dreamspell20 bindData];

	//
	// DREAMSPELL TZOLKN 13
	//
	dreamspell13 = [[GLGear alloc] init:13 
								   type:TYPE_WHEEL
							   denteOut:DENTE_UP
								denteIn:DENTE_NOT
									rot:ROTATE_CCW
								  gomol:dreamspell20.arcIn 
								  gomow:2.0
								   rows:1 ];
	x = -( 0.2 + dreamspell260.gomoWidth + 0.4 + dreamspell20.gomoWidth + 0.4 + dreamspell13.radiusOut );
	[dreamspell13 setTranslate:x :0.0 :0.0];
	dreamspell13.name = LOCAL(@"GEAR_NAME_DREAMSPELL_13");
	// Labels
	for (int n = 0 ; n < 13 ; n++ )
		[dreamspell13 addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:@"num_map" map:(n+1)];
	// Bind!
	[dreamspell13 bindData];

	//
	// DREAMSPELL MOON 365
	//
	dreamspell365 = [[GLGear alloc] init:365 
							  type:TYPE_WHEEL
						  denteOut:DENTE_DOWN
						   denteIn:DENTE_DOWN
							   rot:ROTATE_CW 
							 gomol:dreamspell20.arcOut 
							 gomow:(dreamspell20.gomoWidth+dreamspell20.labelWidth)
							  rows:2 ];
	x = ( 0.2 + dreamspell365.radiusOut );
	[dreamspell365 setTranslate:x :0.0 :0.0];
	dreamspell365.displaySizeMax = 20;
	[dreamspell365 setDisplayZoom:super.zoomSize];
	dreamspell365.name = LOCAL(@"GEAR_NAME_DREAMSPELL_365");
	// Labels Row 0
	for (int n = 0 ; n < 364 ; n++ )
		[dreamspell365 addLabelNew:0 pos:n align:LABEL_ALIGN_ROW texname:@"number_map" map:((n%28)+1)];
	// Labels Row 1
	dreamspell365.labelWidth = dreamspell13.labelWidth;
	dreamspell365.labelHeight = dreamspell13.labelHeight;
	for (int n = 0 ; n < 364 ; n++ )
		[dreamspell365 addLabelNew:1 pos:n align:LABEL_ALIGN_ROW texname:@"num_map" map:((n/28)+1)];
	// Labels DOOT
	dreamspell365.labelWidth = (dreamspell20.labelWidth*2.0) ;
	dreamspell365.labelHeight = dreamspell20.labelHeight;
	[dreamspell365 addLabelNew:0 pos:364 align:LABEL_ALIGN_CENTER texname:[NSString stringWithFormat:@"doot-%@",global.prefLangSuffix] map:0];
	[dreamspell365 addLabelNew:1 pos:364 align:LABEL_ALIGN_CENTER texname:@"dummy_trans" map:0];
	// Bind!
	[dreamspell365 bindData];

	//
	// DREAMSPELL WEEKDAY 7
	//
	dreamspell7 = [[GLGear alloc] init:7 
								  type:TYPE_WHEEL
							  denteOut:DENTE_UP
							   denteIn:DENTE_NOT
								   rot:ROTATE_CW
								 gomol:dreamspell20.gomoLen
								 gomow:2.0
								  rows:1 ];
	x = ( 0.2 + dreamspell365.gomoWidth + 0.4 + dreamspell7.radiusOut);
	[dreamspell7 setTranslate:x :0.0 :0.0];
	dreamspell7.name = LOCAL(@"GEAR_NAME_DREAMSPELL_7");
	// Labels
	for (int n = 0 ; n < 7 ; n++ )
		[dreamspell7 addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:@"plasma_map" map:n];
	// Bind!
	[dreamspell7 bindData];
}



//
// SETUP GEARS
//
- (void)setupGearsSplash {
	CGFloat x;
	CGFloat z = -10.0;
	
	//
	// SPLASH SCREEN
	//
	splash13 = [[GLGear alloc] init:22 
							   type:TYPE_WHEEL
						   denteOut:DENTE_NOT
							denteIn:DENTE_NOT
								rot:ROTATE_CCW 
							  gomol:(GOMO_LEN*0.8)
							  gomow:4.0
							   rows:1 ];
	splash13.name = LOCAL(@"22");
	[splash13 setTranslate:0.0 :0.0 :z];
	splash13.gomoWidth = 5.0;
	// Labels
	for (int n = 0 ; n < 22 ; n++ )
		[splash13 addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:@"splash_map" map:n];
	// Bind!
	[splash13 bindData];
	
	// SPLASH
	splash33a = [[GLGear alloc] init:33 
								type:TYPE_WHEEL
							denteOut:DENTE_UP
							 denteIn:DENTE_NOT
								 rot:ROTATE_CW
							   gomol:GOMO_LEN 
							   gomow:4.0
								rows:1  ];
	z -= 5.0;
	x = ( splash33a.radiusOut + 0.2 );
	[splash33a setTranslate:x :0.0 :z];
	splash33a.name = LOCAL(@"13");
	// Labels
	//for (int n = 0 ; n < 33 ; n++ )
	//	[splash33a addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:@"dummy" map:(n+1)];
	// Bind!
	[splash33a bindData];
	
	// SPLASH
	splash33b = [[GLGear alloc] init:33 
								type:TYPE_WHEEL
							denteOut:DENTE_DOWN
							 denteIn:DENTE_NOT
								 rot:ROTATE_CCW
							   gomol:GOMO_LEN 
							   gomow:4.0
								rows:1  ];
	x = -( splash33b.radiusOut + 0.2 );
	[splash33b setTranslate:x :0.0 :z];
	splash33b.name = LOCAL(@"13");
	// Labels
	//for (int n = 0 ; n < 33 ; n++ )
	//	[splash33b addLabelNew:0 pos:n align:LABEL_ALIGN_CENTER texname:@"dummy" map:(n+1)];
	// Bind!
	[splash33b bindData];
}





#pragma mark DRAWING

// Thread infinite loop
- (void)draw3DView:(void*)o
{
	AvLog(@"THREAD START");
	while (1)
	{
		AvLog(@"THREAD LOOP");
		[self draw3DView];

	}
}
// Draw 3D view
- (void)draw3DView {
	// Esta fazendo auto-zoom?
	if (autoZoom)
		[self applyAutoZoom];
	// Atualiza 3D View
	[super drawView];
}


//
// DRAW OBJECTS
//
- (void)drawObjects
{
	// SPLASH
	if (MAKE_SPLASH)
	{
		// Splash SCreen
		[splash13 setRotate:(global.cal.tzolkin.number-1) :global.cal.decSecs];
		[splash13 enable];
		[splash33a setRotate:(global.cal.tzolkin.number-1) :global.cal.decSecs];
		[splash33a enable];
		[splash33b setRotate:(global.cal.tzolkin.number-1) :global.cal.decSecs];
		[splash33b enable];
	}else
	{
		// MAYA
		if (ENABLE_MAYA && global.prefMayaDreamspell == VIEW_MODE_MAYA)
		{
			// Window Offset - FOI PRO 3D VIEW
			//glMatrixMode(GL_MODELVIEW);
			glTranslatef(mayaOffsetX, 0.0, 0.0);
			
			// MAYA GEARS
			[maya13 setRotate:(global.cal.tzolkin.number-1) :global.cal.decSecs];
			[maya13 enable];
			[maya20 setRotate:(global.cal.tzolkin.day-1) :global.cal.decSecs];
			[maya20 enable];
			[maya365 setRotate:(global.cal.haab.kin-1) :global.cal.decSecs];
			[maya365 enable];
			[maya9 setRotate:(global.cal.haab.lord-1) :global.cal.decSecs];
			[maya9 enable];
			
			// Disable others
			[dreamspell13 disable];
			[dreamspell20 disable];
			[dreamspell260 disable];
			[dreamspell365 disable];
			[dreamspell7 disable];
		}
		// DREAMSPELL gears
		if (ENABLE_DREAMSPELL && global.prefMayaDreamspell == VIEW_MODE_DREAMSPELL)
		{
			// Window Offset - FOI PRO 3D VIEW
			//glMatrixMode(GL_MODELVIEW);
			glTranslatef(dreamspellOffsetX, 0.0, 0.0);
			
			// DREAMSPELL GEARS
			[dreamspell13 setRotate:(global.cal.tzolkinMoon.number-1) :global.cal.decSecs];
			[dreamspell13 enable];
			[dreamspell20 setRotate:(global.cal.tzolkinMoon.day-1) :global.cal.decSecs];
			[dreamspell20 enable];
			[dreamspell260 setRotate:(global.cal.tzolkinMoon.kin-1) :global.cal.decSecs];
			[dreamspell260 enable];
			[dreamspell365 setRotate:(global.cal.moon.kin-1) :global.cal.decSecs];
			[dreamspell365 enable];
			[dreamspell7 setRotate:(global.cal.moon.plasma-1) :global.cal.decSecs];
			if (global.cal.moon.doot)
				[dreamspell7 disable];
			else
				[dreamspell7 enable];
			// Disable others
			[maya13 disable];
			[maya20 disable];
			[maya365 disable];
			[maya9 disable];
		}
	}
}


#pragma mark TOUCHES

// Correcao de Offset
- (CGPoint)convViewPosToGL:(CGPoint)vpos
{
	CGPoint glPos = [super convViewPosToGL:vpos];
	// Correcao
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
		glPos.x -= mayaOffsetX;
	else
		glPos.x -= dreamspellOffsetX;
	// ok!
	return glPos;
}

// TOUCH BEGIN
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//AvLog(@"ENGINE touchesBegan...");
	NSArray *allTouches = [[event allTouches] allObjects];
	
	// SINGLE Touch
	if (allTouches.count == 1)
	{
		// Recupera Touch
		UITouch *touch = [allTouches objectAtIndex:0];
		touchLast = [touch locationInView:self];
		// Calcula ponto tocado em coordenadas OpenGL
		CGPoint glPos = [self convViewPosToGL:touchLast];
		//AvLog(@"touchesBegan: TOUCH glX[%f] glY[%f]",glPos.x,glPos.y);
		
		// inside gear...
		touchGear = NULL;
		// SPLASH
		if (MAKE_SPLASH)
		{
			if (splash13.isEnabled && [splash13 isInside:glPos.x:glPos.y])
				touchGear = splash13;
			else if (splash33a.isEnabled && [splash33a isInside:glPos.x:glPos.y])
				touchGear = splash33a;
			else if (splash33b.isEnabled && [splash33b isInside:glPos.x:glPos.y])
				touchGear = splash33b;
		}
		else
		{
			// MAYA
			if (ENABLE_MAYA && global.prefMayaDreamspell == VIEW_MODE_MAYA)
			{
				if (maya20.isEnabled && [maya20 isInside:glPos.x:glPos.y])
					touchGear = maya20;
				else if (maya365.isEnabled && [maya365 isInside:glPos.x:glPos.y])
					touchGear = maya365;
				else if (maya13.isEnabled && [maya13 isInside:glPos.x:glPos.y])
					touchGear = maya13;
				else if (maya9.isEnabled && [maya9 isInside:glPos.x:glPos.y])
					touchGear = maya9;
			}
			// DREAMSPELL
			else
			{
				if (ENABLE_DREAMSPELL && dreamspell260.isEnabled && [dreamspell260 isInside:glPos.x:glPos.y])
					touchGear = dreamspell260;
				else if (dreamspell365.isEnabled && [dreamspell365 isInside:glPos.x:glPos.y])
					touchGear = dreamspell365;
				else if (dreamspell20.isEnabled && [dreamspell20 isInside:glPos.x:glPos.y])
					touchGear = dreamspell20;
				else if (dreamspell13.isEnabled && [dreamspell13 isInside:glPos.x:glPos.y])
					touchGear = dreamspell13;
				else if (dreamspell7.isEnabled && [dreamspell7 isInside:glPos.x:glPos.y])
					touchGear = dreamspell7;
			}
		}
		
		// Pegou nova engrenagem
		if (touchGear)
		{
#ifdef OLDLITE
			touchGear = NULL;
			[global alertLite:LOCAL(@"LITE_ALERT_3D")];
			return;
#endif
			// Stop acceleration?
			[global.theClock stopAcceleration];
			
			// Pause clock?
			clockWasPlaying = global.theClock.playing;
			if (clockWasPlaying)
			{
				[global.theClock pause];
				[myVC updateClockIcon];
			}
			
			// Salva posicao atual e acende o disco
			angLast = [touchGear angTo:glPos.x:glPos.y];
			[touchGear highlight:TRUE];
			[myVC touchBegin:touchLast:touchGear.name];
			//AvLog(@"touchesBegan: TOUCH >> ang[%.3f]",angLast);
		}
	}
}

// TOUCHED MOVED
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//AvLog(@"ENGINE touchesMoved...");
	NSArray *allTouches = [[event allTouches] allObjects];
	
	// SINGLE Touch
	if (allTouches.count == 1)
	{
		// Recupera ponto atual
		UITouch *touch = [allTouches objectAtIndex:0];
		CGPoint touchCurrent = [touch locationInView:self];
		CGPoint glPos = [self convViewPosToGL:touchCurrent];
		//AvLog(@"touchesMoved: TOUCH glX[%f] glY[%f]",glPos.x,glPos.y);
		
		// TURN GEAR
		if (touchGear)
		{
			// Saiu da engrenagem?
			if ([touchGear isAround:glPos.x:glPos.y] == FALSE)
			{
				[self endRoll];
				[myVC touchEnd];
				return;
			}
			
			// Move name
			[myVC touchMove:touchCurrent:touchGear.name];

			// Calcula ponto tocado em coordenadas OpenGL
			CGFloat angCurrent = [touchGear angTo:glPos.x:glPos.y];
			// Calcula a diferenca de angulos
			CGFloat diff = [touchGear angDiff:angCurrent:angLast];
			// Calcula quantos segundos andou de acordo com variacao de angulo
			secsLast = -(double)((diff/(touchGear.gomoAng*RADIAN_ANGLES)) * SECONDS_PER_DAY);
			//AvLog(@"touchesMoved: GEAR angCurr[%.3f] diff[%.3f] secs[%.3f]",angCurrent,diff,secs);
			
			// Avanca o relogio
			int valid;
			if ((valid = [global.cal addSeconds:secsLast]) != 0)
			{
				// data invalida (maior que o piktun)
				if (valid < 0)
					[global alertSimple:LOCAL(@"DATE_TOO_LOW")];
				else
					[global alertSimple:LOCAL(@"DATE_TOO_HIGH")];
			}
			
			// Substitui last
			touchLast = touchCurrent;
			angLast = angCurrent;
			timeLast = CFAbsoluteTimeGetCurrent();
		}
		// SWIPE
		else if (ALLOW_SWIPE)
		{
			// SWIPE
			[super addCameraSwipe:(touchLast.x - touchCurrent.x): (touchCurrent.y - touchLast.y)];
			// Substitui last
			touchLast = touchCurrent;
		}
	}
	// MULTI Touch
	else if (allTouches.count == 2)
	{
		UITouch *touch1 = [allTouches objectAtIndex:0];
		UITouch *touch2 = [allTouches objectAtIndex:1];
		CGPoint point1 = [touch1 locationInView:self];
		CGPoint point2 = [touch2 locationInView:self];
		CGFloat distanceCurrent = DISTANCE_BETWEEN(point1.x,point1.y,point2.x,point2.y);
		// Segundo toque...
		if (distanceLast > 0.0)
		{
			// Zoom!
			if (distanceLast != distanceCurrent)
			{
				// Para qualquer auto-zoom
				autoZoom = NO;
				// Splica Zoom
				[super addCameraZoom:(distanceCurrent - distanceLast)];
				[maya365 setDisplayZoom:super.zoomSize];
				[dreamspell260 setDisplayZoom:super.zoomSize];
				[dreamspell365 setDisplayZoom:super.zoomSize];
			}
			// Camera Angle
			else if (ALLOW_ROTATE)
			{
				// Pitch (frente/tras)
				[super addCameraPitch:(point1.y - touchLast.y)];
				// Roll (left/right)
				[super addCameraRoll:(point1.x - touchLast.x)];
				AvLog(@"CAMERA ROTATE cameraRollDeg[%.2f] cameraPitchDeg[%.3f]",super.cameraRollDeg,super.cameraPitchDeg);
			}
		}
		// substitui last
		touchLast = point1;
		distanceLast = distanceCurrent;
	}
}

// TOUCHES ENDED
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//AvLog(@"ENGINE touchesEnded...");
	
	// Restart clock?
	if (clockWasPlaying)
	{
		[global.theClock play];
		[myVC updateClockIcon];
	}

	// hide name
	[myVC touchEnd];

	// Accelerate gears?
	if (touchGear)
		[self endRoll];
	
	//
	// RESETS
	//
	angLast = 0.0;
	// Ultimo acrescimo de segundos
	secsLast = 0.0;
	timeLast = 0.0;
	// MULTI - distance between fingers
	distanceLast = 0.0;
	//touchLast = NULL;
}


// End Gear Rolling - Should accelerate?
- (void)endRoll
{
	// Un-touch gear
	[touchGear highlight:FALSE];
	touchGear = NULL;
	
	// Accelerate!
	CFAbsoluteTime diff = (CFAbsoluteTimeGetCurrent() - timeLast);
	if (diff <= 0.05)
		[global.theClock startAcceleration:secsLast];
}

// Update gear names
- (void)updateNames
{
	// DREAMSPELL gears
	if (ENABLE_DREAMSPELL && global.prefMayaDreamspell == VIEW_MODE_DREAMSPELL)
	{
		// DREAMSPELL GEARS
		dreamspell13.name = global.cal.tzolkinMoon.toneName;
		dreamspell20.name = global.cal.tzolkinMoon.sealName;
		dreamspell260.name = [NSString stringWithFormat:@"Kin %d", global.cal.tzolkinMoon.kin];
		dreamspell365.name = global.cal.moon.dayNameGear;
		dreamspell7.name = global.cal.moon.plasmaName;
	}
}


#pragma mark AUTO ZOOM

#define AUTO_ZOOM_DURATION	4.0

- (void)startAutoZoom:(CGFloat)i :(CGFloat)f
{
	autoZoom = YES;
	autoZoomIni = i;
	autoZoomFim = f;
	autoZoomStart = CFAbsoluteTimeGetCurrent();
	[super setCamera:autoZoomIni];
}
- (void)stopAutoZoom
{
	autoZoom = NO;
}
- (void)applyAutoZoom
{
	// Terminou?
	CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
	CFAbsoluteTime diff = (now - autoZoomStart);
	// Aplica auto zoom
	CGFloat d = ( (autoZoomFim - autoZoomIni) * sin((diff/AUTO_ZOOM_DURATION)*(PI/2.0)) );
	CGFloat w = ( autoZoomIni + d );
	[super setCamera:w];

	// Chegou no fim?
	if ( diff >= AUTO_ZOOM_DURATION )
	{
		autoZoom = NO;
		return;
	}
}

#pragma mark SOUNDS

- (void)playChord
{
	if (global.prefMayaDreamspell == VIEW_MODE_MAYA)
	{
		//[global.soundLib addToPlaybackBuffer:(TzSoundBuffer*)([maya13 currentSoundBuffer])];
		//[global.soundLib addToPlaybackBuffer:(TzSoundBuffer*)([maya20 currentSoundBuffer])];
		//[global.soundLib addToPlaybackBuffer:(TzSoundBuffer*)([maya365 currentSoundBuffer])];
		//[global.soundLib addToPlaybackBuffer:(TzSoundBuffer*)([maya9 currentSoundBuffer])];
	}
	// Dreamspell
	else
	{
	}
}

@end
