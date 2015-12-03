//
//  GLElements.m
//  Maya3D
//
//  Created by Roger on 19/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "GLElements.h"
#import "Tzolkin.h"
#import "TzGlobal.h"
#import "GLTextureLib.h"

@implementation GLElements

- (void)dealloc {
	if(arrayTex)
		free(arrayTex);
	// Super
    [super dealloc];
}

// inicializa apenas com o numero de vertices
// nv: Numero de vertices de cada elemento
// el: Quantas repeticoes este objeto tera
- (id)initElements:(GLsizei)nv el:(int)el
{
	// super init
    if ((self = [super initVertices:(nv*el)]) == nil)
		return nil;
	
	// Elements
	numElements = el;
	numVertexElements = nv;
	
	// Array para a TEXTURAS
	// opcionais - sera usado apenas se diferente ce Zero
	size_t sz = ( numElements * sizeof(GLuint) );
	arrayTex = (GLuint*) malloc((size_t)sz);
	memset((void*)arrayTex, 0, (size_t)sz);
	
	// Finito!
	return self;
}

#pragma mark SETTINGS

//
// Set TEXTURE
//
- (void)setTexture:(NSString*)texname alpha:(BOOL)alpha toElement:(int)n
{
	// Get texture VBO
	arrayTex[n] = [global.texLib getVBO:texname alpha:alpha];
}



#pragma mark DRAWING

// Activate and DRAW
- (void)enable:(int)i :(int)q
{
	[self enable:i :q fade:0];
}
- (void)enable:(int)i :(int)q fade:(int)f
{
	ini = i;
	qtd = q;
	fade = f;
	// Chama rotina de desenho do GLObject
	// e aguarda para chamar o nosso drawObject
	[super enable];
}

//
// DRAW all elements!!!
//
- (void)drawObject
{
	// Draw Elements
	int i;
	for ( int n = ini ; n < (ini+qtd) ; n++ )
	{
		// Draw Arrays
		i = (n % numElements);
		[self drawElement:i];
	}
}

//
// DRAW one element
//
- (void)drawElement:(int)n
{
	// Bind texture?
	if (arrayTex[n])
		[super bindTexture:arrayTex[n]];
	
	// Draw!
	glDrawElements(primitiveType, numVertexElements, GL_UNSIGNED_SHORT, &arrayIndex[n*numVertexElements]);
}


@end
