//
//  Gl3DView.h
//  opengles
//
//  Created by Roger on 31/10/08.
//  Copyright Studio Avante 2008. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Tzolkin.h"

#define FPS_HIST	10

/*
This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
The view content is basically an EAGL surface you render your OpenGL scene into.
Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
*/
@interface Gl3DView : UIView {

@private
	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	// GL Context
	EAGLContext *context;
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
	// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
	GLuint depthRenderbuffer;
	
	// Constants
	CGFloat zNear;
	CGFloat zPlane;
	CGFloat zFar;
	
	// View
	CGFloat viewRatio;				// Largura / Altura da view
	// Camera Angles
	CGFloat cameraFocal;			// Abertura focal da camera
	CGFloat cameraRollDeg;			// Inclinacao da camera / wheel (eixo X) - em GRAUS
	CGFloat cameraPitchDeg;			// Inclinacao da camera / forwd (eixo Z) - em GRAUS
	// Camera Bounds
	UIEdgeInsets camInset;			// Camera limit: GL Pixels @ Z_NEAR
	CGFloat cameraWidth;			// GL pixels na horizontal @ Z_NEAR
	CGFloat cameraRatio;			// UIView > Z_NEAR
	CGFloat planeWidth;				// GL pixels na horizontal @ Z_PLANE
	CGFloat planeRatio;				// Z_NEAR > Z_PLANE
	CGFloat farRatio;				// Z_NEAR > Z_FAR
	CGPoint camOffset;				// Offset from center: GL pixels @ Z_PLANE
	CGFloat zoomSize;				// % de zoom (min=0.0, max=1.0)
	// FPS
	double fps;							// Last FPS
	int fpsCycles;						// Ciclos acumulados FPS
	CFAbsoluteTime fpsStart;			// Inicio do segundo
	// FPS History
	double fpsHist;						// History Average FPS
	int cycleCount;						// Contador de amostragem historico
	int histCycles[FPS_HIST];			// FPS das ultimas contagens
	CFAbsoluteTime histTime[FPS_HIST];	// Tempos das ultimas contagens
}

@property (nonatomic) CGFloat zNear;
@property (nonatomic) CGFloat zPlane;
@property (nonatomic) CGFloat zFar;
@property (nonatomic) CGFloat viewRatio;
@property (nonatomic) CGFloat cameraWidth;
@property (nonatomic) CGFloat cameraRatio;
@property (nonatomic) CGFloat planeRatio;
@property (nonatomic) CGFloat farRatio;
@property (nonatomic) CGFloat zoomSize;
@property (nonatomic) CGPoint camOffset;
@property (nonatomic) CGFloat cameraRollDeg;
@property (nonatomic) CGFloat cameraPitchDeg;


//- (id)initWithCoder:(NSCoder*)coder;
// OpenGL
- (void)initOpenGL;
- (void)drawView;
- (void)drawObjects;
- (void)calcFPS;
// Original
- (void)layoutSubviews;
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
// Camera
- (void)setCamera:(GLfloat)width;
- (GLfloat)convViewToNear:(GLfloat)dim;
- (GLfloat)convViewToPlane:(GLfloat)dim;
- (CGPoint)convViewPosToGL:(CGPoint)vpos;
- (void)addCameraSwipe:(GLfloat)x :(GLfloat)y;
- (void)addCameraZoom:(GLfloat)d;
- (void)addCameraPitch:(GLfloat)d;
- (void)addCameraRoll:(GLfloat)d;

@end


