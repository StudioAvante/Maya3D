//
//  GLElements.h
//  Maya3D
//
//  Created by Roger on 19/03/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLObject.h"


@interface GLElements : GLObject {
	// Elements data
	GLsizei		numElements;			// Quantidade de elementos dentro deste objeto   // the number of elements.
	GLsizei		numVertexElements;		// Quantidade de vertices de cada elemento   // the number of vertices of each element.
	// Array de texturas - OPCIONAL - usado apenas se preenchido
	GLuint		*arrayTex;				// textura de cada elemento
	// Draw
	int		ini;	// Elemento inicial
	int		qtd;	// Quantidade de elementos a desenhar
	int		fade;	// Quantidade de elemntos que terao fade, comecando do 1o
}

- (id)initElements:(GLsizei)nv el:(int)el;
- (void)setTexture:(NSString*)texname alpha:(BOOL)alpha toElement:(int)e;
- (void)enable:(int)i :(int)q;
- (void)enable:(int)i :(int)q fade:(int)f;
- (void)drawObject;
- (void)drawElement:(int)n;

@end
