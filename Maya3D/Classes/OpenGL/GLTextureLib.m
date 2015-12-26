//
//  GLTextureLib.m
//  Maya3D
//
//  Created by Roger on 24/02/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "GLTextureLib.h"
#import "GLTexture.h"
#import "Tzolkin.h"


@implementation GLTextureLib

@synthesize vbos;
// Destructor
- (void)dealloc
{
	[vbos release];
    [super dealloc];
}

// init
- (id)initWithCapacity:(NSUInteger)i
{
	// super init
    if ((self = [super init]) == nil)
		return nil;
	
	// Alloc dictionary
	maxVBO = i;
	numVBO = 0;
	vbos = [[NSMutableDictionary alloc] initWithCapacity:i];
	
	// Finito
	return self;
}

// Create Texture VBO or get from Dictionary
- (GLuint)getVBO:(NSString*)name alpha:(BOOL)alpha
{
	// Find in Dictionary
	GLTexture *tex;
	tex = [vbos objectForKey:name];  
	if (tex)
		return tex.vbo;
	
	// Dictionary Full?
	if (numVBO == maxVBO)
	{
		AvLog(@"!!!!!!!!! GLTextureLib FULL [%d] !!!!!!!!!!!!!!",numVBO);
		return 0;
	}
	
	// Make new Texture VBO
	tex = [[GLTexture alloc] initWithName:name alpha:alpha];
	if ( (int)tex.vbo < 0 )
		return -1;
	
	// Add VBO to dictionary
	[vbos setObject:tex forKey:name];
	numVBO++;
	
	// Return the vbo
	//AvLog(@"GLTextureLib ADD [%d/%d] [%@]",numVBO,maxVBO,filename);
	return tex.vbo;
}


// Create Texture VBO or get from Dictionary
- (CGSize)getSize:(NSString*)name
{
	// Find in Dictionary
	GLTexture *tex;
	tex = [vbos objectForKey:name];
    GLuint ii = tex.vbo;
    
    CGSize size;// = CGSizeMake(0.0,0.0);
    size.width = 0;
    size.height = 0;
	if (tex)
    {
        
        size.width = tex.size.width;
        size.height = tex.size.height;
    }
    
    return size;
}


@end
