//
//  Gl3DView.m
//  opengles
//
//  Created by Roger on 31/10/08.
//  Copyright Studio Avante 2008. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "Gl3DView.h"
#import "TzGlobal.h"

#define USE_DEPTH_BUFFER	1

@implementation Gl3DView

@synthesize zNear;
@synthesize zPlane;
@synthesize zFar;
@synthesize viewRatio;
@synthesize cameraWidth;
@synthesize cameraRatio;
@synthesize planeRatio;
@synthesize farRatio;
@synthesize zoomSize;
@synthesize camOffset;
@synthesize cameraRollDeg;
@synthesize cameraPitchDeg;

// destructor
- (void)dealloc {
	// ORIGINAL
	if ([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	
	[context release];  
	[super dealloc];
}


// ORIGINAL
// You must implement this method
+ (Class)layerClass {
	return [CAEAGLLayer class];
}

// FROM NIB
//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
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
	
	// Get the layer
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:NO], 
									kEAGLDrawablePropertyRetainedBacking, 
									kEAGLColorFormatRGBA8, 
									kEAGLDrawablePropertyColorFormat, nil];
	
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	
	if (!context || ![EAGLContext setCurrentContext:context]) {
		[self release];
		return nil;
	}
	
	// Enable Multi-touch
	[self setMultipleTouchEnabled:YES];
	
	// Contants
	zNear = Z_NEAR;
	zPlane = Z_PLANE;
	zFar = Z_FAR;
	
	// init OpenGL
	[self initOpenGL];
	
	// View ratio
	// Razao da ALTURA para a LARGURA da UIView
	viewRatio = (self.frame.size.height / self.frame.size.width);
	
	// Abertura focal da camera
	cameraFocal = atanf( CAMERA_WIDTH / zNear );
	AvLog(@"CAMERA FOCAL rad[%.3f] ang[%.3f]",cameraFocal,cameraFocal*RADIAN_ANGLES);
	[self setCamera:CAMERA_WIDTH];

	// Finito!
	return self;
}

//
// INIT 3D VIEW
//
- (void)initOpenGL
{
	// Looks like depth test is off by default on the SDK
	glEnable(GL_DEPTH_TEST);
	// specify the value used for depth buffer comparisons
	//glDepthFunc(GL_ALWAYS);
	//glDepthFunc(GL_EQUAL);
	glDepthFunc(GL_LEQUAL);
	//glDepthFunc(GL_LESS);
	//glDepthRangef(0.0,10.0);
	// This appears to already be off
	glDisable(GL_CULL_FACE);
	// Reset Depth Buffer
	glClearDepthf(1.0f);
	
	// Disable Blending - performance
	glDisable(GL_BLEND);
	
	// LIGHTNING
	{
		// Material properties
		const GLfloat matAmbient[]    = {0.3, 0.3, 0.3, 1.0};
		const GLfloat matDiffuse[]    = {1.0, 1.0, 1.0, 1.0};
		const GLfloat matSpecular[]   = {1.0, 1.0, 1.0, 1.0};
		// Light properties
		const GLfloat lightAmbient[]  = {1.0, 1.0, 1.0, 1.0};	// afeta tudo
		const GLfloat lightDiffuse[]  = {1.0, 0.75, 0.75, 1.0};	// "lampada", afeta toda a cena
		const GLfloat lightSpecular[]  = {1.0, 1.0, 1.0, 1.0};	// "spot"
		// Posicao da luz / O 4o valor (w) diz se é positional (w>0) ou directional (w==0)
		// Positional vem de um ponto, e directional vem de uma direcao (tipo o sol)
		const GLfloat lightPosition[] = {0.0, 0.0, 5.0, 1.0};
		// Posicao e direcao da luz: vetor
		const GLfloat lightDirection[] = {0.0, 0.0, -1.0};
		// Brilho da luz
		const GLfloat lightShininess = 100.0;
		
		// Enable Lightning and Light sources
		glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT0);
		
		// How polys will reflect each light type
		glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
		glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, matSpecular);
		glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, lightShininess);
		
		// Light properties
		glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
		glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
		glLightfv(GL_LIGHT0, GL_SPECULAR, lightSpecular);
		
		// Posicao da fonte de luz no ambiente 3D
		glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);
		
		// Directional / Spot Light
		glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, lightDirection);
		// "Cone": graus
		// 1.2  will create a cone with an angle of 2.4 degrees
		// 180 degrees will radiate light in all directions. 
		glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 60.0f);
		// "Foco" da luz: 0..128 / concentracao no centro da luz
		// 0.0 = afeta todo o cone por igual, quanto maior mais fechado fica
		glLightf(GL_LIGHT0, GL_SPOT_EXPONENT, 10.0f);
		
		// Attenuation (high cost!!!) - Dissipacao da luz
		//glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION,  1.0f);
		//glLightf(GL_LIGHT0, GL_LINEAR_ATTENUATION, 0.2f);
		//glLightf(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0.08f);
		
		
		// glShadeModel: SMOOTH (default): vertex colors are treated individually
		// FLAT: flatshading is turned on.
		glShadeModel(GL_SMOOTH);
		// color tracking: Usa ou nao as cores dos modelos
		// aparentemente isso deixa matAmbient sempre no maximo
		//glEnable(GL_COLOR_MATERIAL);
	}

	// fundo
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

//
// DRAW GEARS
//
- (void)drawView
{
	// ORIGINAL
	// PERFORMANCE: desabilitado
	//[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glViewport(0, 0, backingWidth, backingHeight);
	
	// Camera / Eye
	// voidglOrthof (GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat zNear, GLfloat zFar);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	if (PERSPECTIVE)
		glFrustumf(camInset.left, camInset.right, camInset.bottom, camInset.top, zNear, zFar);
	else
		glOrthof( camInset.left, camInset.right, camInset.bottom, camInset.top, -zNear, zFar);

	// Apaga tudo!
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// Translate global
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslatef(-camOffset.x, -camOffset.y, -zPlane);
	
	// Rotate
	if (ACCELEROMETER && !ALLOW_ROTATE)
	{
		// Pitch (frente/tras) - so ate o maximo
		if (SHOOTING)
		{
			// PITCH: table = up (inverted)
			cameraPitchDeg = (PITCH_MAX * global.accelZ );
		}
		else
		{
			// PITCH: table = table
			if (global.accelZ < 0.0)
				cameraPitchDeg = (PITCH_MAX * -(1.0 + global.accelZ) );
			else
				cameraPitchDeg = (PITCH_MAX * -(1.0 - global.accelZ) );
		}
		// Camera Roll (esq/dir)
		cameraRollDeg = -RAD2DEG(global.accelRollTable);
		// debug
		//AvLog(@"ROLL accX/Y/Z[%.2f/%.2f/%.2f] roll[%.2f] ACCpitch[%.2f] pitch[%.2f] prog[%.2f]",
		//	  global.accelX,global.accelY,global.accelZ,cameraRollDeg,RAD2DEG(global.accelPitch),cameraPitchDeg,prog);
	}
	glRotatef( cameraRollDeg  , 0.0, 0.0, 1.0 );
	glRotatef( cameraPitchDeg , 1.0, 0.0, 0.0 );
	
	// Enable arrays
    glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	// Enable Texturing
	glEnable(GL_TEXTURE_2D);
	
	// DRAW OBJECTS
	[self drawObjects];

	// ORIGINAL
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	// check for errors
	GLenum gl_error = glGetError();
	if(GL_NO_ERROR != gl_error)
	{
		AvLog(@"!!!!!!!  GL ERROR: [%d] !!!!!!!!", gl_error);
	}

	// Calc FPS
	[self calcFPS];
}

//
// DRAW OBJECTS - HERDAR ESTA CLASSE
//
- (void)drawObjects
{
}

// Calc FPS
- (void)calcFPS {
	// Calc FPS
	CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
	CFAbsoluteTime diff = (now - fpsStart);
	// Inicio
	if (fpsStart == 0)
		fpsStart = now;
	// Ciclo incompleto
	else if (diff < 1.0)
		fpsCycles++;
	// Ciclo completo
	else
	{
		fps = (fpsCycles / diff);
		// Calc Hist
		histCycles[cycleCount] = fps;
		histTime[cycleCount] = diff;
		cycleCount++;
		// Calcula quando completar uma amostragem completa e sempre depois
		if (cycleCount == FPS_HIST || fpsHist > 0.0)
		{
			double cyclesSum = 0.0;
			int timeSum = 0;
			for ( int n = 0 ; n < FPS_HIST ; n++ )
			{
				cyclesSum += histCycles[n];
				timeSum += histTime[n];
			}
			// Calc history fps
			fpsHist = (cyclesSum / timeSum);
			// Reset history counter
			cycleCount = (cycleCount%FPS_HIST);
		}
		//Reset
		fpsCycles=0;
		fpsStart = now;
		// Display FPS
		if (DISPLAY_FPS)
			AvLog(@"FPS: %ds[%.2f] 1s[%.2f]",FPS_HIST,fpsHist,fps);
	}
}

#pragma mark ORIGINAL FROM APPLE EXAMPLE

// ORIGINAL
- (void)layoutSubviews {
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	//[self drawView];
}

// ORIGINAL
- (BOOL)createFramebuffer {
	
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	if (USE_DEPTH_BUFFER) {
		glGenRenderbuffersOES(1, &depthRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	}
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		AvLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// ORIGINAL
- (void)destroyFramebuffer {
	
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

#pragma mark TOUCHES

// Ajusta camera
// Set camera bounds that fits width in the screen
// Centered on 0.0 x 0.0 x 0.0
- (void)setCamera:(GLfloat)width {
	// Largura da camera em zNear
	cameraWidth = width;
	// Razao da largura da camera para a largura da UIView
	cameraRatio = (cameraWidth / self.frame.size.width);
	//AvLog(@"CAMERA w[%.3f] ratio[%.3f]",cameraWidth,cameraRatio);
	
	// Largura de Z_PLANE
	planeWidth = ((zPlane * cameraWidth ) / zNear);
	// Razao de Z_NEAR para Z_PLANE
	planeRatio =  (planeWidth / cameraWidth);
	// Razao de Z_NEAR para Z_FAR
	farRatio =  (cameraWidth / cameraWidth);
	//AvLog(@"PLANE w[%.3f] planeRatio[%.3f] farRatio[%.3f]",planeWidth,planeRatio,farRatio);
	
	// Encaixa width na camera
	camInset.right = (cameraWidth / 2.0);
	camInset.left = (camInset.right * -1.0);
	
	// Faz top/bottom de acordo com tamanho do frame
	camInset.top = ((cameraWidth*viewRatio) / 2.0);
	camInset.bottom = (camInset.top * -1.0);
	
	// Calcula porcentagem de Zoom
	zoomSize = (cameraWidth - CAMERA_WIDTH_MIN) / (CAMERA_WIDTH_MAX - CAMERA_WIDTH_MIN);

	// Debug
	//AvLog(@"GL CAMERA w[%.2f] rat[%.2f] LR[%.2f/%.2f] TB[%.2f/%.2f] offXY[%.2f/%.2f] zoom%[%.2f]",
	//	  cameraWidth,cameraRatio,camInset.left,camInset.right,camInset.top,camInset.bottom,camOffset.x,camOffset.y,zoomSize);
}

// Converte uma dimensao UIView para GL @ Z_NEAR
- (GLfloat)convViewToNear:(GLfloat)dim
{
	return (dim * cameraRatio);
}

// Converte uma dimensao UIView para GL @ Z_PLANE
- (GLfloat)convViewToPlane:(GLfloat)dim
{
	return (dim * cameraRatio * planeRatio);
}

// Converte posicao na view por posicao OpenGL
- (CGPoint)convViewPosToGL:(CGPoint)viewPos
{
	//AvLog(@"POS ------------");
	CGPoint glPos;
	if (PERSPECTIVE)
	{
		// UIView to GL @ Z_NEAR - OK!
		//AvLog(@"POS viewXY[%.2f/%.2f] offsetXY[%.2f/%.2f]",viewPos.x,viewPos.y,camOffset.x,camOffset.y);
		glPos.x = (viewPos.x * cameraRatio) - camInset.right;
		glPos.y = (-viewPos.y * cameraRatio) - camInset.bottom;
		// GL @ Z_PLANE - OK!
		glPos.x *= planeRatio;
		glPos.y *= planeRatio;
		// Adjust Offset @ Z_PLANE - OK!
		glPos.x += camOffset.x;
		glPos.y += camOffset.y;
		
		// > Girar o ponto clicado de volta...
		// Encontra o raio do centro ate o ponto clicado
		GLfloat r = DISTANCE_BETWEEN(0.0,0.0,glPos.x,glPos.y);
		// Acha o angulo do click
		// sin(a) = (op/hip) >  a = asin(op/hip)
		GLfloat ang = asin(glPos.y/r);
		// Ajusta asin para termos um angulo de 0~360
		if (glPos.x < 0)
			ang = PI - ang;
		else if (glPos.y < 0)
			ang += 2.0*PI;
		// Remove angulo de rotacao do angulo clicado > Angulo na coordenada do objeto
		ang -= (cameraRollDeg / RADIAN_ANGLES);
		// Encontra X/Y a aprtir do raio
		glPos.x = (r * cos(ang));
		glPos.y = (r * sin(ang));
		//AvLog(@"GL  XY  [%.2f/%.2f]",glPos.x,glPos.y);

		// angulo de inclinacao frente/tras)
		//AvLog(@"POS pitch [%.2f] cos[%.2f] sin[%.2f]",cameraPitchDeg,cos(cameraPitchDeg/RADIAN_ANGLES),sin(cameraPitchDeg/RADIAN_ANGLES));
		//glPos.y -= ( glPos.y * sin( cameraPitchDeg / RADIAN_ANGLES ) );
		//AvLog(@"POS glXY  [%.2f/%.2f]",viewPos.x,viewPos.x,glPos.x,glPos.y);
	}
	else
	{
		// PRECISA DE REVISAO!!!
		// Ortho view (no perspective)
		glPos.x = (viewPos.x * cameraRatio) - camInset.right + camOffset.x;
		glPos.y = (-viewPos.y * cameraRatio) - camInset.bottom + camOffset.y;
		// Corrige o plano
		glPos.x *= planeRatio;
		glPos.y *= planeRatio;
	}
	return glPos;
}

// Desliza a camera no eixo X/Y
- (void)addCameraSwipe:(GLfloat)x :(GLfloat)y
{
	//AvLog(@"SWIPE offset x[%.3f] y[%.3f] planeRatio[%.3f]",x, y,planeRatio);
	camOffset.x += [self convViewToPlane:x];
	camOffset.y += [self convViewToPlane:y];
	AvLog(@"SWIPE offset x[%.3f] y[%.3f]",camOffset.x,camOffset.y);
}

// Aplica zoom a camera
- (void)addCameraZoom:(GLfloat)d
{
	// Calcula nova largura da tela
	CGFloat newWidth = ( cameraWidth - (d * cameraRatio) );
	
	// Verifica Limites
	if (CAMERA_SIZE_LOCK && !SHOOTING)
	{
		if (newWidth < CAMERA_WIDTH_MIN)
			newWidth = CAMERA_WIDTH_MIN;
		else if (newWidth > CAMERA_WIDTH_MAX)
			newWidth = CAMERA_WIDTH_MAX;
	}
	
	// Re-calcula camera
	[self setCamera:newWidth];
	//AvLog(@"touchesMoved: MULTI xy1[%.2f/%.2f] xy2[%.2f/%.2f] dist[%f] width[%.2f]",point1.x,point1.y,point2.x,point2.y,distanceCurrent,cameraWidth);
}

// Aplica Pitch = frente/tras
- (void)addCameraPitch:(GLfloat)d
{
	cameraPitchDeg -= d;
	if (cameraPitchDeg > PITCH_MAX)
		cameraPitchDeg = PITCH_MAX;
	else if (cameraPitchDeg < -PITCH_MAX)
		cameraPitchDeg = -PITCH_MAX;
}

// Aplica Roll = dir/esq
- (void)addCameraRoll:(GLfloat)d
{
	cameraRollDeg += d;
	// Deixa sempre entre 0  e 360.0
	while (cameraRollDeg >= 360.0)
		cameraRollDeg -= 360.0;
	while (cameraRollDeg < -0.0)
		cameraRollDeg += 360.0;
	//AvLog(@"ROLL d[%.3f] roll[%.3f]",d,cameraRollDeg);
}


@end
