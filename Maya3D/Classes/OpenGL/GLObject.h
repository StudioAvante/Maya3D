//
//  GLObject.h
//  Maya3D
//
//  Created by Roger on 11/02/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define NUM_VERTEX_COMP			3
#define NUM_TEXTURE_COMP		2
#define NUM_COLOR_COMP			4

#define SIZEOF_INDEX_DATA			(sizeof(GLushort))
#define SIZEOF_VERTEX_DATA			(NUM_VERTEX_COMP  * sizeof(GLfloat))
#define SIZEOF_TEXTURE_DATA			(NUM_TEXTURE_COMP * sizeof(GLfloat))
#define SIZEOF_COLOR_DATA			(NUM_COLOR_COMP   * sizeof(GLubyte))

typedef struct {
	GLfloat	x;
	GLfloat	y;
	GLfloat	z;
} glPoint3D;

typedef struct {
	glPoint3D center;
	glPoint3D rot;		// em graus
	glPoint3D dir;		// 1.0=Anti-Horario, -1.0=Horario
} glTransform;

@interface GLObject : NSObject {
	// Properties
	GLenum		primitiveType;			// GL Pimitive type. Default: GL_TRIANGLE_STRIP
	BOOL		highlight;
	BOOL		blending;
	BOOL		undoTransform;
	BOOL		status;					// Status do objecto: TRUE = bindado ok!
	// Object data
	GLsizei		numVertex;				// Quantidade de vertices total
	GLsizei		numVertexComponents;
	GLsizei		numColorComponents;
	GLsizei		numTexComponents;
	// Array Sizes (bytes)
	GLsizeiptr	sizeIndex;
	GLsizeiptr	sizeVertex;
	GLsizeiptr	sizeColor;
	GLsizeiptr	sizeTexture;
	GLsizeiptr	sizeBuffer;
	GLsizei		stride;				// Interleaved stride: full vertex data size
	// Arrays
	int			ixIndex;			// contadores...
	int			ixVertex;
	int			ixColor;
	int			ixTexture;
	BOOL		okVertex;			// vlaidacoes...
	BOOL		okColor;
	BOOL		okTexture;
	GLushort	*arrayIndex;		// Indices dos vertices do objeto inteiro
	GLfloat		*arrayVertex;		// Vertices
	GLubyte		*arrayColor;		// Cores
	GLfloat		*arrayTexture;		// Texturas (coordenadas)
	// VBOs
	GLuint		ibo;				// index Buffer
	GLuint		vbo;				// Vertex Buffer Object
	GLuint		tex;				// The Texture Buffer
	// Transformations
	glTransform transOffset;
	glTransform trans;
	// Material Light Emission
	GLfloat mat_null[4];
	GLfloat mat_highlight[4];
    GLfloat mat_emission[4];
    GLfloat mat_specular[4];
    GLfloat mat_diffuse[4];
}

@property (nonatomic) GLenum primitiveType;
@property (nonatomic) BOOL highlight;
@property (nonatomic) BOOL blending;
@property (nonatomic) BOOL undoTransform;
@property (nonatomic) BOOL status;
@property (nonatomic) GLsizei numVertex;
@property (nonatomic) glTransform transOffset;
@property (nonatomic) glTransform trans;
@property (nonatomic) GLuint tex;

- (id)initVertices:(GLsizei)nv;
- (void)addVertex:(GLfloat)x :(GLfloat)y;
- (void)addVertex:(GLfloat)x :(GLfloat)y :(GLfloat)z;
- (void)addColor:(GLubyte)r :(GLubyte)g :(GLubyte)b;
- (void)addColor:(GLubyte)r :(GLubyte)g :(GLubyte)b :(GLubyte)a;
- (void)setTexture:(NSString*)texname alpha:(BOOL)alpha;
- (void)addTextureVertex:(GLfloat)x :(GLfloat)y;
// Bind
- (void)bindData;
// Drawing
- (void)enable;
- (void)bindTexture;
- (void)bindTexture:(GLuint)tex;
- (void)drawObject;
- (void)transform:(glTransform)t;
- (void)transform:(glTransform)t repeat:(int)r;
- (void)disable;
- (BOOL)isVertexInsideInset:(CGFloat*)vertex:(UIEdgeInsets)inset;

@end
