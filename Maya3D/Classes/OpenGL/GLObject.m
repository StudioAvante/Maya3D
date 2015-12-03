//
//  GLObject.m
//  Maya3D
//
//  Created by Roger on 11/02/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <OpenGLES/EAGLDrawable.h>
#import "GLObject.h"
#import "Tzolkin.h"
#import "TzGlobal.h"
#import "GLTextureLib.h"


#define USE_IBO		0

@implementation GLObject

@synthesize primitiveType;
@synthesize highlight;
@synthesize blending;
@synthesize undoTransform;
@synthesize status;
@synthesize numVertex;
@synthesize transOffset;
@synthesize trans;
@synthesize tex;

- (void)dealloc {
	// Delete Buffers
	if (vbo)
		glDeleteBuffers(1, &vbo);
	if (ibo)
		glDeleteBuffers(1, &ibo);
	// Free arrays
	if (arrayIndex)
		free(arrayIndex);
	if (arrayVertex)
		free(arrayVertex);
	if (arrayColor)
		free(arrayColor);
	if (arrayTexture)
		free(arrayTexture);
	// Super
    [super dealloc];
}

// inicializa apenas com o numero de vertices
- (id)initVertices:(GLsizei)nv;
{
	// super init
    if ((self = [super init]) == nil)
		return nil;
	
	// Primitive type
	primitiveType = GL_TRIANGLE_STRIP;

	// set object data
	undoTransform = TRUE;
	numVertex = nv;
	numVertexComponents = NUM_VERTEX_COMP;
	numTexComponents    = NUM_TEXTURE_COMP;
	numColorComponents  = NUM_COLOR_COMP;
	
	// Calc sizes
	sizeIndex   = ( numVertex * SIZEOF_INDEX_DATA );
	sizeVertex  = ( numVertex * SIZEOF_VERTEX_DATA );
	sizeTexture = ( numVertex * SIZEOF_TEXTURE_DATA );
	sizeColor   = ( numVertex * SIZEOF_COLOR_DATA );
	//AvLog(@"GLObject nv[%d] nvc[%d] sizeof[%d] size[%d]",numVertex,numVertexComponents, sizeof(GLfloat),sizeVertex);
	//AvLog(@"GLObject nc[%d] ncc[%d] sizeof[%d] size[%d]",numVertex,numVertexComponents,sizeof(GLubyte),sizeColor);
	
	// Alloc arrays
	arrayIndex     = (GLushort*) malloc((size_t)sizeIndex);
	memset((void*)arrayIndex, 0, (size_t)sizeIndex);
	arrayVertex    = (GLfloat*) malloc((size_t)sizeVertex);
	memset((void*)arrayVertex, 0, (size_t)sizeVertex);
	arrayTexture = (GLfloat*) malloc((size_t)sizeTexture);
	memset((void*)arrayTexture, 0, (size_t)sizeTexture);
	/* COLORS DISABLED
	arrayColor     = (GLubyte*) malloc((size_t)sizeColor);
	memset((void*)arrayColor, 0, (size_t)sizeColor);
	 */
	
	//AvLog(@"GLObject sizeof(arrayVertex)[%p-%p]",arrayVertex,(arrayVertex+sizeVertex));
	//AvLog(@"GLObject sizeof(arrayColor) [%p-%p]",arrayColor,(arrayColor+sizeColor));
	
	// Reset Array Index
	ixIndex = ixVertex = ixColor = ixTexture = 0;
	
	// Material Emission
	mat_null[0] = 0.0f;
	mat_null[1] = 0.0f;
	mat_null[2] = 0.0f;
	mat_null[3] = 0.0f;
	mat_highlight[0] = 1.0f;
	mat_highlight[1] = 0.3f;
	mat_highlight[2] = 0.0f;
	mat_highlight[3] = 0.0f;
	
	// finito!
	return self;
}


//
// Add VERTEX to array
//
- (void)addVertex:(GLfloat)x :(GLfloat)y
{
	[self addVertex:x:y:0.0];
}
- (void)addVertex:(GLfloat)x :(GLfloat)y :(GLfloat)z
{
	// Check end
	if (okVertex)
	{
		AvLog(@"addVertex: !!!!!!!!! arrayVertex FULL [%d] !!!!!!!!!!!",ixVertex);
		return;
	}
	// Add Index
	//GLushort ix = (GLushort)(ixVertex/NUM_VERTEX_COMP);
	arrayIndex[ixIndex] = ixIndex++;
	// Add Vertex
	arrayVertex[ixVertex++] = x;
	arrayVertex[ixVertex++] = y;
	arrayVertex[ixVertex++] = z;
	// Check end
	if (ixVertex == (numVertex*numVertexComponents))
		okVertex = TRUE;
	//AvLog(@"addVertex: ixIndex[%d/%d] v[%d] xyz[%f/%f/%f] OK[%d]",ixIndex,numVertex,ixVertex,x,y,z,okVertex);
}


//
// Add COLOR to array
//
- (void)addColor:(GLubyte)r :(GLubyte)g :(GLubyte)b
{
	[self addColor:r:g:b:255];
}
- (void)addColor:(GLubyte)r :(GLubyte)g :(GLubyte)b :(GLubyte)a
{
	// Check end
	if (okColor)
	{
		AvLog(@"addColor: arrayColor [%d] FULL!!!",ixColor);
		return;
	}
	// Add Color
	arrayColor[ixColor++] = r;
	arrayColor[ixColor++] = g;
	arrayColor[ixColor++] = b;
	arrayColor[ixColor++] = a;
	// Check end
	if (ixColor == (numVertex*numColorComponents))
		okColor= TRUE;
}

//
// Set TEXTURE
//
- (void)setTexture:(NSString*)texname alpha:(BOOL)alpha
{
	// Get texture VBO
	tex = [global.texLib getVBO:texname alpha:alpha];
}

// Add TEXTURE VERTEX to array
- (void)addTextureVertex:(GLfloat)x :(GLfloat)y
{
	// Check end
	if (okTexture)
	{
		AvLog(@"addVertex: addTextureVertex [%d] FULL!!!",ixTexture);
		return;
	}
	// Add Vertex
	arrayTexture[ixTexture++] = x;
	arrayTexture[ixTexture++] = y;
	// Check end
	if (ixTexture == (numVertex*numTexComponents))
		okTexture = TRUE;
	//AvLog(@"addTextureVertex: i[%d] xyz[%f/%f] OK[%d]",ixTexture,x,y,okTexture);
}


#pragma mark BIND

//
// Check Data
//
- (BOOL)checkData
{
	// Check arrays
	short errors = 0;
	// Check vertex
	if (!okVertex)
	{
		AvLog(@"bindData WARNING: !!!!!!!! arrayVertex NOT FULL ix[%d/%d] vertex[%d/%d] !!!!!!",
			  ixIndex,numVertex,
			  ixVertex,(numVertex*numVertexComponents));
		errors++;
	}
	// Check texture
	if (!okTexture)
	{
		AvLog(@"bindData WARNING: !!!!!!!! arrayTexture NOT FULL [%d/%d] !!!!!!",
			  ixTexture,(numVertex*numTexComponents));
		errors++;
	}
	/* COLORS DISABLED
	 if (!okColor)
	 {
	 AvLog(@"bindData WARNING: arrayColors NOT FULL!!!");
	 errors++;
	 }
	 */
	
	// Return errors
	if (errors)
		return status = FALSE;
	else
		return status = TRUE;
}

//
// BIND Data
//
- (void)bindData
{
	// Check data
	[self checkData];
	if (!status)
	{
		AvLog(@"bindData WARNING: !!!!!!!! OBJECT NOT BINDED !!!!!!");
		return;
	}
	
	// Set Buffer Size
	sizeBuffer = sizeVertex;
	sizeBuffer += sizeTexture;
	/* COLORS DISABLED
	sizeBuffer += sizeColor;
	 */
	
	// stride: One full vertex data size (vertex + color + texture)
	stride = (int)(sizeBuffer / numVertex);

	// allocate a new vertex buffer
	glGenBuffers(1, &vbo);
	// bind the buffer object to use
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	// allocate enough space for the VBO
	glBufferData(GL_ARRAY_BUFFER, sizeBuffer, 0, GL_STATIC_DRAW);
	//AvLog(@"GL_OBJECT vbo[%d] nv[%d]",vbo,numVertex);

	// Get allocated buffer to copy data
	GLvoid *vbo_buffer = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
	// transfer data - INTERLEAVED!
	for ( int n = 0 ; n < numVertex ; n++ )
	{
		// Vertex Buffer
		memcpy(vbo_buffer, &arrayVertex[n*NUM_VERTEX_COMP], SIZEOF_VERTEX_DATA);
		vbo_buffer += SIZEOF_VERTEX_DATA;
		
		// Texture Buffer
		memcpy(vbo_buffer, &arrayTexture[n*NUM_TEXTURE_COMP], SIZEOF_TEXTURE_DATA);
		vbo_buffer += SIZEOF_TEXTURE_DATA;
		
		/* COLORS DISABLED
		// Color Buffer
		memcpy(vbo_buffer, &arrayColor[n*NUM_COLOR_COMP], SIZEOF_COLOR_DATA);
		vbo_buffer += SIZEOF_COLOR_DATA;
		 */
	}
	//AvLog(@"INTERLEAVE buffer[%d] vbo[%d] stride[%d]",sizeBuffer,numVertex*stride,stride);
	// Close allocated buffer
	glUnmapBufferOES(GL_ARRAY_BUFFER);
	
	// create index buffer
	if (USE_IBO)
	{
		glGenBuffers(1, &ibo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
		// -- metodo 1
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeIndex, arrayIndex, GL_STATIC_DRAW);
		// -- metodo 2
		//glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeIndex, 0, GL_STATIC_DRAW);
		//glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeIndex, arrayIndex);
		// -- metodo 3
		//vbo_buffer = glMapBufferOES(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
		//memcpy(vbo_buffer, arrayIndex, sizeIndex);
		//glUnmapBufferOES(GL_ELEMENT_ARRAY_BUFFER);
		
		// Free client array
		//free(arrayIndex);
	}

	// Free client arrays
	free(arrayVertex);
	free(arrayTexture);
	/* COLORS DISABLED
	free(arrayColor);
	*/
}


#pragma mark DRAWING

// Check if vertex is inside a inset
- (BOOL)isVertexInsideInset:(CGFloat*)vertex :(UIEdgeInsets)inset;
{
	return (vertex[0] >= inset.left && vertex[0] <= inset.right && vertex[1] >= inset.bottom && vertex[1] <= inset.top);
}

// Activate and DRAW
- (void)enable
{
	// If not ready, dont draw!!!
	if (status == FALSE)
		return;
	
	// Activate the VBOs to draw
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	// Enable Vertex array - FOI PRO 3D_VIEW
    //glEnableClientState(GL_VERTEX_ARRAY);
	
	// Describe to OpenGL where each data is in the buffer
	// INTERLEAVED
	GLvoid *ptr = (GLvoid*)((char*)NULL);
	glVertexPointer(numVertexComponents, GL_FLOAT, stride, ptr);
	ptr += SIZEOF_VERTEX_DATA;
	glTexCoordPointer(numTexComponents, GL_FLOAT, stride, ptr);
	ptr += SIZEOF_TEXTURE_DATA;	
	/* COLORS DISABLED
	glColorPointer(numColorComponents, GL_UNSIGNED_BYTE, stride, ptr);
	ptr += SIZEOF_COLOR_DATA;
	 */
	
	// Bind Texture if needed!
	[self bindTexture];
	
	/* COLORS DISABLED
	// Enable Color array
	glEnableClientState(GL_COLOR_ARRAY);
	// Disable Texture array
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	// Disable texturing
	glBindTexture(GL_TEXTURE_2D, 0);
	glDisable(GL_TEXTURE_2D);
	global.texBound = 0;
	 */
	
	// Enable Alpha blending?
	if (blending && !global.blendingEnabled)
	{
		global.blendingEnabled = TRUE;
		glEnable(GL_BLEND);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);	// Pure alpha blending
		//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		//glBlendFunc(GL_SRC_COLOR, GL_ZERO);
	}
	else if (!blending && global.blendingEnabled)
	{
		global.blendingEnabled = FALSE;
		glDisable(GL_BLEND);
	}
	
	// Enable model highlight
	// Solucao alternativa pata glPushAttrib() do OpenGL
	if (highlight)
	{
		// Save current material settings
		glGetMaterialfv(GL_FRONT, GL_DIFFUSE, mat_diffuse);
		glGetMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
		glGetMaterialfv(GL_FRONT, GL_EMISSION, mat_emission);
		// Turn on model Light Emission
		glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, mat_null);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_null);
		glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, mat_highlight);
	}

	// Enable Vertex matrix - FOI PRO 3D VIEW
	//glMatrixMode(GL_MODELVIEW);
	
	// save current transformations?
	if (undoTransform)
		glPushMatrix();
	
	// Do object transformation
	[self transform:trans];
	[self transform:transOffset];
	
	// Draw!
	[self drawObject];
	
	// UNDO transformations
	if (undoTransform)
		glPopMatrix();

	// Disable model highlight
	if (highlight)
	{
		glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, mat_diffuse);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
		glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, mat_emission);
	}
}

//
// Bind Texture
//
- (void)bindTexture
{
	[self bindTexture:tex];
}
- (void)bindTexture:(GLuint)texvbo
{
	// Not a vbo?
	// Already binded?
	if (texvbo == 0 || global.texBound == texvbo)
		return;
	
	// Disable Color Array - FOI PRO 3D VIEW
	//glDisableClientState(GL_COLOR_ARRAY);
	// Enable Texture Array - FOI PRO 3D VIEW
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// Bind Texture!
	glBindTexture(GL_TEXTURE_2D, texvbo);
	// Set currently bound texture
	global.texBound = texvbo;
	
	// Enable Texturing - FOI PRO 3D VIEW
	//glEnable(GL_TEXTURE_2D);
	
	// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	// PERFORMANCE SUGGESTION by Apple - mas fica tudo zoado!
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	// Repeat texture
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
}

// Draw!
- (void)drawObject
{
	// Draw Arrays
	//glDrawArrays(primitiveType, 0, numVertex);
	
	if (ibo)
	{
		// Draw Elements - SERVER
		// ???: Bind ibo > perde 8 fps!
		// ???: Elements em Client > perde 1 fps!
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
		glDrawElements(primitiveType, numVertex, GL_UNSIGNED_SHORT, (GLvoid*)((char*)NULL));
	}
	else
	{
		// Draw Elements - CLIENT
		glDrawElements(primitiveType, numVertex, GL_UNSIGNED_SHORT, arrayIndex);
	}
}

// Deactivate for drawing
- (void)disable
{
	// Activate the VBOs to draw
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	// This could actually be moved into the setup since we never disable it
    glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_2D);
}


// Do transformations
// PERFORMANCE: Transformar apenas se preciso: 6.0 fps!
- (void)transform:(glTransform)t
{
	[self transform:t repeat:1];
}
- (void)transform:(glTransform)t repeat:(int)r
{
	// Translate global
	if (t.center.x || t.center.y || t.center.z)
		glTranslatef(t.center.x, t.center.y, t.center.z);
	if (t.rot.x)
		glRotatef( ( r * t.rot.x * (t.dir.x == -1.0 ? -1.0 : 1.0) ), 1.0, 0.0, 0.0 );
	if (t.rot.y)
		glRotatef( ( r * t.rot.y * (t.dir.y == -1.0 ? -1.0 : 1.0) ), 0.0, 1.0, 0.0 );
	if (t.rot.z)
		glRotatef( ( r * t.rot.z * (t.dir.z == -1.0 ? -1.0 : 1.0) ), 0.0, 0.0, 1.0 );
}


@end
