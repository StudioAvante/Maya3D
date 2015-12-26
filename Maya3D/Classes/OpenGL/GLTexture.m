//
//  GLTexture.m
//  Maya3D
//
//  Created by Roger on 17/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "GLTexture.h"
#import "Tzolkin.h"


@implementation GLTexture

@synthesize texname;
@synthesize vbo;
@synthesize size;

// Destructor
- (void)dealloc
{
	[texname release];
    [super dealloc];
}

// init
- (id)initWithName:(NSString*)name alpha:(BOOL)alpha
{
	// super init
    if ((self = [super init]) == nil)
		return nil;
	
	// make VBO
	[self makeVBO:(NSString*)name alpha:alpha];

	// Finito
	return self;
}


// Make new Texture VBO
- (BOOL)makeVBO:(NSString*)name alpha:(BOOL)alpha
{
	CGImageRef texImage;
	CGContextRef texContext;
	GLubyte *texData;
	size_t	width, height;
	
	// Save texture name
	texname = [[NSString alloc] initWithString:name];

	// Creates a Core Graphics image from an image file
	UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:texname ofType:@"png"]];
	texImage = img.CGImage;
	if(texImage == NULL)
	{
		AvLog(@"GLTexture ERROR: [%@] NOT FOUND!!!",texname);
		vbo = -1;
		return FALSE;
	}
	width = CGImageGetWidth(texImage);
	height = CGImageGetHeight(texImage);
	
	// Allocated memory needed for the bitmap context
	texData = (GLubyte *) malloc(width * height * 4);
    memset(texData, 0, width*height*4); 
	// Uses the bitmatp creation function provided by the Core Graphics framework. 
	texContext = CGBitmapContextCreate(texData, width, height, 8, width * 4, CGImageGetColorSpace(texImage), kCGImageAlphaPremultipliedLast);
	// After you create the context, you can draw the sprite image to the context.
	CGContextDrawImage(texContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), texImage);
	// You don't need the context at this point, so you need to release it to avoid memory leaks.
	CGContextRelease(texContext);
	
	// Use OpenGL ES to generate a name for the texture.
	glGenTextures(1, &vbo);
	// Bind the texture name. 
	glBindTexture(GL_TEXTURE_2D, vbo);
	// Specify a 2D texture image, providing the a pointer to the image data in memory
	// void glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels);
	if (1)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texData);
	else
	{
		// Remove alpha data
		GLubyte *rgbData = malloc (width * height * 3);
		for (int n = 0 ; n < (width * height) ; n++)
			memcpy(&rgbData[n*3], &texData[n*4], 3);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, rgbData);
		free(rgbData);
	}
	// Release the image data
	free(texData);
	
	// Save texture data
	size.width = width;
	size.height = height;

	//AvLog(@"GLTextureLib ADD [%d/%d] [%@]",numVBO,maxVBO,texname);
	return TRUE;
}



@end
