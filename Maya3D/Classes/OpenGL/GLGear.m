//
//  GLGear.m
//  Maya3D
//
//  Created by Roger on 11/02/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "GLGear.h"
#import "GLObject.h"
#import "GLElements.h"
#import "GLTextureLib.h"
#import "Tzolkin.h"
#import "TzGlobal.h"
#import "TzSoundSine.h"
#import "GLTexture.h"

@implementation GLGear

@synthesize name;
@synthesize gomoWidth;
@synthesize gomoAng;
@synthesize gomoLen;
@synthesize labelWidth;
@synthesize labelHeight;
@synthesize arcOut;
@synthesize arcIn;
@synthesize radiusOut;
@synthesize radiusIn;
@synthesize isEnabled;
@synthesize displaySizeMax;

- (void)dealloc {
	// name
	if (name)
		[name release];
	
	// GL Objects
	[glObject release];
	[glSideIn release];
	[glSideOut release];
	// Free arrays
	if (glDenteIn)
		[glDenteIn release];
	if (glDenteOut)
		[glDenteOut release];
	// Free Labels
	for (int n = 0 ; n < rows ; n++)
		if (glLabels[n])
			free (glLabels[n]);
	// Sound Buffers
	if (sines)
	{
		for (int n = 0 ; n < gomos ; n++)
			[sines[n] release];
		free(sines);
	}
	
	// super
	[super dealloc];
}


// Init Gear
-(id) init:(int)g 
	  type:(char)t 
  denteOut:(char)dout 
   denteIn:(char)din 
	   rot:(int)rot
{
	return [self init:g
				 type:t
			 denteOut:dout
			  denteIn:din
				  rot:rot
				gomol:GOMO_LEN 
				gomow:GOMO_WIDTH
				 rows:1 ];
}
// Init Gear
-(id) init:(int)g
	  type:(char)t 
  denteOut:(char)dout
   denteIn:(char)din 
	   rot:(int)rot
	 gomol:(CGFloat)gl
	 gomow:(CGFloat)gw 
	  rows:(int)r
{
	// super init
    if ((self = [super init]) == nil)
		return nil;
	
	// Given data
	gomos = g;					// Gomos ou Dentes da roda
	type = t;					// Tipo do disco
	typeDenteIn = din;			// Tipo do dente de dentro
	typeDenteOut = dout;		// Tipo do dente de fora
	rotation = rot;				// Tipo de rotacao: CW / CCW
	gomoLen = gl;				// Comprimento do arco do Gomo
	gomoWidth = gw;				// Largura do Gomo
	rows = r;					// Rows of labels
	name = @"";
	
	// ARCOS por gomo
	if (gomos < 10)
	{
		// 3 Arcos por Gomo
		gomoArcs = 3;
        denteUpVertex = 6;
		denteUpSideVertex = (5*2);
		denteDownVertex = 5;
		denteDownSideVertex = (4*2);
//        denteDownSideVertex = (5*2);

	}
	else
	{
		// 2 Arcos por Gomo
		gomoArcs = 2;
		denteUpVertex = 5;
		denteUpSideVertex = (5*2);
		denteDownVertex = 5;
		denteDownSideVertex = (5*2);
	}
	
	// GOMOs
	gomoAng = ( (2.0*PI) / ((GLfloat)gomos) );	// Em radianos
	arcs = ( ((GLfloat)gomos) * gomoArcs);		// Arcos geometricos do gomo
	arcAng = ( (2.0*PI) / arcs);				// Em radianos
	
	// vertices do disco +2 para fechar no inicio
	if ([self isStrip])
		vertices = (gomos * 2) + 2;		
	else
		vertices = (arcs * 2) + 2;
	
	AvLog(@"GLGear[%d]gomos ang[%.3f] width[%.3f] arcs[%d] arcAng[%.3f]",gomos,gomoAng,gomoWidth,arcs,arcAng);
	
	// OUT circle
	arcOut = gomoLen;
	circOut = ( ((GLfloat)gomos) * arcOut );
	diamOut = (circOut / PI);
	radiusOut = (diamOut / 2.0);
	AvLog(@"GLGear[%d] OUT circ[%.3f] arc[%.3f] diam[%.3f] rad[%.3f]",gomos,circOut,arcOut,diamOut,radiusOut);
	
	// IN circle
	radiusIn = (radiusOut - gomoWidth);
	diamIn = (radiusIn * 2.0);
	circIn = (diamIn * PI);
	arcIn = (radiusIn * gomoAng);		// a = r*ang
	AvLog(@"GLGear[%d] IN  circ[%.3f] arc[%.3f] diam[%.3f] rad[%.3f]",gomos,circIn,arcIn,diamIn,radiusIn);
	
	// Posicao dos labels
	labelWidth = labelHeight = ( (gomoWidth - (LABEL_GAP*2.0) ) / rows );
	radiusCenter = (radiusOut - (gomoWidth / 2.0) );
	radiusRow[0] = (radiusOut - LABEL_GAP - ( labelWidth * 0.5f ) );
	radiusRow[1] = (radiusOut - LABEL_GAP - ( labelWidth * 1.5f ) );
	
	// Display Array dos dentes e lados - liga todos
	displaySizeMin = DISPLAY_SIZE_MIN;
	displaySizeMax = gomos;
	// Display all
	gomoIni = 0;
	displaySize = gomos;

	// Create mesh
	[self createObject];
	[self createSidesOut];
	[self createSidesIn];
	
	// Finito!
	return self;
}

// Eh um disco do tipo STRIP?
// Ou seja, ele eh grande e sua textura comprida?
- (BOOL)isStrip
{
	return ( gomos > STRIP_LIMIT ? TRUE : FALSE );
}

// Define quais gomos devem ser apresentados
- (void)makeDisplayArray
{
	// se mostra todos, nao precisa montar displayArray
	if ( displaySizeMax == gomos )
		return;
	
	// STRIPs
	// Limita o numero de gomos desenhados
	// 60% para cima,  40% para baixo
	gomoIni = ( (currentGomo - (int)(displaySize*0.6) ) % gomos );
	if (gomoIni < 0)
		gomoIni += gomos;
	//AvLog(@"DISPLAY ARRAY g[%02d/%02d] ini[%d] size[%d] ",currentGomo,gomos,gomoIni,displaySize);
	
	// Mostra mesmos lados dos gomos
	sideIniIn = sideIniOut = gomoIni;
	displaySideIn = displaySideOut = displaySize;
}

// Sobrecarrega o setter original
- (void)setDisplaySizeMax:(int)s
{
	displaySizeMax = s;
	displaySize = s;
	[self makeDisplayArray];
}

// Ajusta o munero de gomos visiveis
// Calcula displaySize a partir do zoom (0.0 - 1.0)
- (void)setDisplayZoom:(CGFloat)z
{
	// Ajusta o munero de gomos visiveis
	//displaySize = displaySizeMin + (int)( (CGFloat)(displaySizeMax - displaySizeMin) * z );
	[self makeDisplayArray];
	//AvLog(@"setDisplayZoom min[%d] max[%d] zoom[%.2f] displaySize[%d]",displaySizeMin,displaySizeMax,z,displaySize);
}




#pragma mark OBJECT

//
// GEAR MESH
//
- (void)createObject
{
	NSString *texname;
	glTransform trans;
	
	// CREATE OBJECT
	//glObject = [[GLObject alloc] initVertices:(vertices)];
    glObject = [[GLObject alloc] initVertices:(vertices) :1];
	glObject.undoTransform = FALSE;
	
	// Se anti-horario, vira 180 graus
	if (rotation == ROTATE_CW)
	{
		trans = glObject.transOffset;
		trans.rot.z = 180.0;
		glObject.transOffset = trans;
	}

	// Rotacao de acordo com tipo
	trans = glObject.trans;
	trans.dir.z = rotation;
	glObject.trans = trans;
	
	// Add Texture
	// Define o tipo de textura: STRIP (comprida) ou RADIAL (cobre todo o disco)
	if (gomos == 7 || gomos == 9 || gomos == 13 || gomos == 20 )
	{
		typeTexture = TEXTURE_RADIAL;
		texname = [NSString stringWithFormat:@"gear%d",gomos];
	}
	else
	{
		typeTexture = TEXTURE_STRIP;
		texname = @"gear_strip";
	}
	[glObject setTexture:texname alpha:NO];
	
	// Create Gear mesh
	if (type == TYPE_WHEEL)
		[self createMeshWheel];
//	else
		[self createMeshPizza];

	// Cria lados
//	[self createSidesOut];
//	[self createSidesIn];

	// Init Label Rows
	for (int n = 0 ; n < rows ; n++)
		glLabels[n] = nil;
}

//
// GEAR MESH - WHEEL
//
- (void)createMeshWheel
{
	GLfloat ang, x, y;
	GLfloat z = -LABEL_DEPTH;
	GLfloat xd;			// Extensao da textura STRIP
	int wheelArcs;		// Arcos por gomo
	CGFloat wheelAng;	// Angulo de cada arco
	int i;
	
	// Define tamanho dos gomos
	if ([self isStrip])
	{
		// 1 arco por gomo
		wheelArcs = gomos;
		wheelAng = gomoAng;
	}
	else
	{
		// 2 arcos por gomo
		wheelArcs = arcs;
		wheelAng = arcAng;
	}
	// 1 textura a cada 8 gomos
	xd = (1.0 / 8.0);
	
	// Desenha mesh
	for ( int n = 0 ; n <= wheelArcs ; n++ )
	{
		// Se for anti-horario, inverte
		if (rotation == ROTATE_CCW)
			i = n;
		else
			i = (wheelArcs - n);
		
		// Angulo
		ang = ( wheelAng * i );
		
		// VERTICE IN
		x = radiusIn * cos(ang);
		y = radiusIn * sin(ang);
		[glObject addVertex:x :y :z];
		if (typeTexture == TEXTURE_STRIP)
			[glObject addTextureVertex:(xd*i) :1.0];
		else
			[glObject addTextureVertex:(radiusOut+x)/diamOut:(radiusOut+y)/diamOut];
		
		// VERTICE OUT
		x = radiusOut * cos(ang);
		y = radiusOut * sin(ang);
		[glObject addVertex:x :y :z];
		if (typeTexture == TEXTURE_STRIP)
			[glObject addTextureVertex:(xd*i) :0.0];
		else
			[glObject addTextureVertex:(radiusOut+x)/diamOut:(radiusOut+y)/diamOut];
		//AvLog(@"MESH[%02d] ang[%f] 2PI[%f] x[%f]y[%f]",n,ang,(2.0*PI),x,y);
	}
}

//
// GEAR MESH - PIZZA
//
- (void)createMeshPizza
{
}



#pragma mark SIDES

//
// GEAR SIDES
//
- (void)createSidesOut
{
	int sideVertices;

	// NO DENTES
	if (typeDenteOut == DENTE_NOT)
		sideVertices = ((vertices - 2) / gomos) + 2;	// Numero de arcos do disco / gomos + 2
	// YES DENTES
	else
	{
		// Alloc GL Objects
		if (typeDenteOut == DENTE_UP)
		{
			glDenteOut = [[GLElements alloc] initElements:denteUpVertex el:gomos];
			sideVertices = (denteUpSideVertex + 2);		// + 2 para fechar
		}
		else
		{
			glDenteOut = [[GLElements alloc] initElements:denteDownVertex el:gomos];
			sideVertices = (denteDownSideVertex + 2);	// + 2 para fechar
		}
		
		// Set Textures
		[glDenteOut setTexture:@"gear_dente_top" alpha:NO];
	}
	// Alloc SIDE
	glSideOut = [[GLElements alloc] initElements:sideVertices el:gomos];

	// Side Textures
	[glSideOut setTexture:@"gear_side" alpha:NO];

	// Cria Meshes lados
	if (gomoArcs == 2)
		[self createMeshSideOut2];
	else
		[self createMeshSideOut3];
	
	// Map side vertices
	// 1 textura para cada gomo
	int sidePoints = (sideVertices / 2);
	CGFloat dx = 1.0 / (sidePoints-1);
	for ( int n = 0 ; n < gomos ; n++ )
	{
		for ( int f = 0 ; f < sidePoints ; f++ )
		{
			//AvLog(@"SIDE VERTICES g[%d] fr[%d] x[%f]",(f / pointsPorGomo),(f % pointsPorGomo),x);
			[glSideOut addTextureVertex:(0.0+(f*dx)) :1.0];
			[glSideOut addTextureVertex:(0.0+(f*dx)) :0.0];
		}
	}
}


//
// GEAR SIDES
//
- (void)createSidesIn
{
	int sideVertices;

	// NO DENTES
	if (typeDenteIn == DENTE_NOT)
		sideVertices = ((vertices - 2) / gomos) + 2;	// Numero de arcos do disco / gomos + 2
	// YES DENTES
	else
	{
		// Alloc GL Objects
		if (typeDenteIn == DENTE_UP)
		{
			glDenteIn = [[GLElements alloc] initElements:denteUpVertex el:gomos];
			sideVertices = (denteUpSideVertex + 2);		// + 2 para fechar
		}
		else
		{
			glDenteIn = [[GLElements alloc] initElements:denteDownVertex el:gomos];
			sideVertices = (denteDownSideVertex + 2);	// + 2 para fechar
		}
		
		// Set Textures
		[glDenteIn setTexture:@"gear_dente_top" alpha:NO];
	}
	//AvLog(@"SIDE IN vertices[%d] sideVertices[%d]",vertices,sideVertices);

	// Alloc SIDE
	glSideIn = [[GLElements alloc] initElements:sideVertices el:gomos];
	
	// Side Textures
	[glSideIn setTexture:@"gear_side" alpha:NO];
	
	// Cria Meshes lados
	if (gomoArcs == 2)
		[self createMeshSideIn2];
	else
		[self createMeshSideIn3];
	
	// Map side vertices
	// 1 textura para cada gomo
	int sidePoints = (sideVertices / 2);
	CGFloat dx = 1.0 / (sidePoints-1);
	for ( int n = 0 ; n < gomos ; n++ )
	{
		for ( int f = 0 ; f < sidePoints ; f++ )
		{
			//AvLog(@"SIDE VERTICES g[%d] fr[%d] x[%f]",(f / pointsPorGomo),(f % pointsPorGomo),x);
			[glSideIn addTextureVertex:(0.0+(f*dx)) :1.0];
			[glSideIn addTextureVertex:(0.0+(f*dx)) :0.0];
		}
	}
}

#pragma mark SIDES ARC 2

//
// GEAR SIDE + DENTE  ( OUT ) - ARC 2
//
// 2 faces no gomo - Cria a partir da metade da 2a a cima, para encaixar os dentes
//
// A3		< arcAng * 3 (termina no arcAng do gomo seguinte)
//  \			< Dente IN
//   A2		< arcAng * 2 (fim deste gomo)
// /  \			< Dente IN
//  ---A1	< arcAng
// \  /
//   A0		< 0.0 (NAO DESENHA)
//
- (void)createMeshSideOut2
{
	// Create vertices
	GLfloat ang, ang0;
	GLfloat x, y, x0, y0, x1, y1;
	GLfloat z1  = -LABEL_DEPTH;
	GLfloat z11 = z1 - (DENTE_DEPTH*0.15);
	GLfloat z2  = (z1 - DENTE_DEPTH);
	GLfloat z22 = z2 + (DENTE_DEPTH*0.15);
	
	// Cria side para todos os gomos
	// Cria dentes somente no primeiro gomo (os outros serao repetidos)
	// ps: AGORA CRIA UM SO PARA OS LADOS TAMBEM
	for ( int n = 0 ; n < gomos ; n++)
	{
		// Angulo deste gomo
		//ang0 = (gomoAng * n);
		ang0 = [self angInit:n];

		// DENTE NOT - APENAS LADO
		if (typeDenteOut == DENTE_NOT)
		{
			// A0
			ang = ang0 + 0.0;
			x = (radiusOut * cos(ang));
			y = (radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			// A1
			ang += arcAng;
			if (![self isStrip])
			{
				x = (radiusOut * cos(ang));
				y = (radiusOut * sin(ang));
				[glSideOut addVertex:x :y :z1];
				[glSideOut addVertex:x :y :z2];
			}
			// A2
			ang += arcAng;
			x = (radiusOut * cos(ang));
			y = (radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
		}
		//
		// DENTE OUT / UP
		// Desenha de A0 ate A2
		//
		// A2			< arcAng * 2
		//  |
		//  |-- v5		< arcAng * 2 + 1/2
		//  |   \
		//  |---  v4	< arcAng * 2 + 1/3
		//  |    /
		// A1 v3		< arcAng
		//  |   \
		//  |---  v2	< arcAng * 2/3
		//  |    /
		//  |-- v1		< arcAng * 1/2
		//  |
		// A0			< 0.0
		//
		else if (typeDenteOut == DENTE_UP)
		{
			// A0
			ang = ang0 + 0.0;
			x = (radiusOut * cos(ang));
			y = (radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//
			// DENTE UP - BEGIN
			//
			// A0~A1
			// v1 + side
			// Este vertice fica no meio de A0 e A1 
			ang = ang0 + 0.0;
			x0 = (radiusOut * cos(ang));
			y0 = (radiusOut * sin(ang));
			ang = ang0 + arcAng;
			x1 = (radiusOut * cos(ang));
			y1 = (radiusOut * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.5 );
			y = y0 + ( ( y1-y0 ) * 0.5 );
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			// v2 + side
			ang = ang0 + 0.0;
			x0 = ( (radiusOut+DENTE_WIDTH) * cos(ang));
			y0 = ( (radiusOut+DENTE_WIDTH) * sin(ang));
			ang = ang0 + arcAng;
			x1 = ( (radiusOut+DENTE_WIDTH) * cos(ang));
			y1 = ( (radiusOut+DENTE_WIDTH) * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.66 );
			y = y0 + ( ( y1-y0 ) * 0.66 );
			[glSideOut addVertex:x :y :z11];
			[glSideOut addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z11];
			// A1
			// v3
			ang = ang0 + arcAng;
			x = (radiusOut * cos(ang));
			y = (radiusOut * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			// A1~A2
			// v4
			// Est vertice fica no meio do A1 e A2
			ang = ang0 + arcAng;
			x0 = ((radiusOut+DENTE_WIDTH) * cos(ang));
			y0 = ((radiusOut+DENTE_WIDTH) * sin(ang));
			ang = ang0 + (arcAng * 2.0);
			x1 = ((radiusOut+DENTE_WIDTH) * cos(ang));
			y1 = ((radiusOut+DENTE_WIDTH) * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.33 );
			y = y0 + ( ( y1-y0 ) * 0.33 );
			[glSideOut addVertex:x :y :z11];
			[glSideOut addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z11];
			// v5 + side
			ang = ang0 + arcAng;
			x0 = (radiusOut * cos(ang));
			y0 = (radiusOut * sin(ang));
			ang = ang0 + (arcAng * 2.0);
			x1 = (radiusOut * cos(ang));
			y1 = (radiusOut * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.5 );
			y = y0 + ( ( y1-y0 ) * 0.5 );
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			//
			// DENTE UP - END
			//
			// A2
			ang = ang0 + (gomoAng);
			x = (radiusOut * cos(ang));
			y = (radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
		}
		//
		// DENTE OUT / DOWN
		// Seseha a patir da 2o arco ate o 2o arco do gomo seguinte
		//
		// A3			< arcAng * 3	<< termina aqui
		//  |
		//  |-- v5		< arcAng * 2 + 2/3
		//  |   \
		//  |---  v4	< arcAng * 2 + 1/2
		//  |    /
		// A2 v3		< arcAng * 2
		//  |   \
		//  |---  v2	< arcAng * 1/2
		//  |    /
		//  |-- v1		< arcAng * 1/3
		//  |
		// A1			< arcAng		<< comeca aqui
		//  |
		// A0			< 0.0
		//
		else if (typeDenteOut == DENTE_DOWN)
		{
			// Comeca no gomo anterior
			ang0 -= gomoAng;
			// A1
			ang = ang0 + arcAng;
			x = (radiusOut * cos(ang));
			y = (radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//
			// DENTE UP - BEGIN
			//
			// A1~A2
			// v1 + side
			// Este vertice fica no meio de A0 e A1 
			ang = ang0 + arcAng;
			x0 = (radiusOut * cos(ang));
			y0 = (radiusOut * sin(ang));
			ang = ang0 + (arcAng * 2.0);
			x1 = (radiusOut * cos(ang));
			y1 = (radiusOut * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.33 );
			y = y0 + ( ( y1-y0 ) * 0.33 );
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			// v2 + side
			ang = ang0 + arcAng;
			x0 = ((radiusOut+DENTE_WIDTH) * cos(ang));
			y0 = ((radiusOut+DENTE_WIDTH) * sin(ang));
			ang = ang0 + (arcAng * 2.0);
			x1 = ((radiusOut+DENTE_WIDTH) * cos(ang));
			y1 = ((radiusOut+DENTE_WIDTH) * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.5 );
			y = y0 + ( ( y1-y0 ) * 0.5 );
			[glSideOut addVertex:x :y :z11];
			[glSideOut addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z11];
			// A2
			// v3
			ang = ang0 + (arcAng * 2.0);
			x = (radiusOut * cos(ang));
			y = (radiusOut * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			// A2~A3
			// v4
			// Est vertice fica no meio do A1 e A2
			ang = ang0 + (arcAng * 2.0);
			x0 = ((radiusOut+DENTE_WIDTH) * cos(ang));
			y0 = ((radiusOut+DENTE_WIDTH) * sin(ang));
			ang = ang0 + (arcAng * 3.0);
			x1 = ((radiusOut+DENTE_WIDTH) * cos(ang));
			y1 = ((radiusOut+DENTE_WIDTH) * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.5 );
			y = y0 + ( ( y1-y0 ) * 0.5 );
			[glSideOut addVertex:x :y :z11];
			[glSideOut addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z11];
			// v5 + side
			ang = ang0 + (arcAng * 2.0);
			x0 = (radiusOut * cos(ang));
			y0 = (radiusOut * sin(ang));
			ang = ang0 + (arcAng * 3.0);
			x1 = (radiusOut * cos(ang));
			y1 = (radiusOut * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.66 );
			y = y0 + ( ( y1-y0 ) * 0.66 );
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			//
			// DENTE UP - END
			//
			// A4
			ang = ang0 + (arcAng * 3.0);
			x = (radiusOut * cos(ang));
			y = (radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
		}
		
		// Top Texture
		// Uma textura ao longo do eixo X
		// 1/2 textura ao longo do eixo Y
		// v1    v3    v5
		//  \   /  \  /
		//    v2    v4
		if (glDenteOut)
		{		
			[glDenteOut addTextureVertex:0.0  :0.5];
			[glDenteOut addTextureVertex:0.25 :1.0];
			[glDenteOut addTextureVertex:0.5  :0.5];
			[glDenteOut addTextureVertex:0.75 :1.0];
			[glDenteOut addTextureVertex:1.0  :0.5];
		}
	}
}


//
// GEAR SIDE + DENTE  ( IN ) - ARC 2
//
- (void)createMeshSideIn2
{
	// Create vertices
	GLfloat ang, ang0;
	GLfloat x, y, x0, y0, x1, y1;
	GLfloat z1 = -LABEL_DEPTH;
	GLfloat z11 = z1 - (DENTE_DEPTH*0.15);
	GLfloat z2 = (z1 - DENTE_DEPTH);
	GLfloat z22 = z2 + (DENTE_DEPTH*0.15);
	
	// Cria side para todos os gomos
	// Cria dentes somente no primeiro gomo (os outros serao repetidos)
	// ps: AGORA CRIA UM SO PARA OS LADOS TAMBEM
	for ( int n = 0 ; n < gomos ; n++)
	{
		// Angulo deste gomo
		//ang0 = (gomoAng * n);
		ang0 = [self angInit:n];
		
		// DENTE NOT - APENAS LADO
		if (typeDenteIn == DENTE_NOT)
		{
			// A0
			ang = ang0 + 0.0;
			x = (radiusIn * cos(ang));
			y = (radiusIn * sin(ang));
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			// A1
			ang += arcAng;
			if (![self isStrip])
			{
				x = (radiusIn * cos(ang));
				y = (radiusIn * sin(ang));
				[glSideIn addVertex:x :y :z1];
				[glSideIn addVertex:x :y :z2];
			}
			// A2
			 ang += arcAng;
			 x = (radiusIn * cos(ang));
			 y = (radiusIn * sin(ang));
			 [glSideIn addVertex:x :y :z1];
			 [glSideIn addVertex:x :y :z2];
		}
		//
		// DENTE IN / UP
		// Desenha de A0 ate A2
		//
		// A2			< arcAng * 2
		//  |
		//  |-- v5		< arcAng * 2 + 1/2
		//  |   \
		//  |---  v4	< arcAng * 2 + 1/3
		//  |    /
		// A1 v3		< arcAng
		//  |   \
		//  |---  v2	< arcAng * 2/3
		//  |    /
		//  |-- v1		< arcAng * 1/2
		//  |
		// A0			< 0.0
		//
		else if (typeDenteIn == DENTE_UP)
		{
			// A0
			ang = ang0 + 0.0;
			x = (radiusIn * cos(ang));
			y = (radiusIn * sin(ang));
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//
			// DENTE UP - BEGIN
			//
			// A0~A1
			// v1 + side
			// Este vertice fica no meio de A0 e A1 
			ang = ang0 + 0.0;
			x0 = (radiusIn * cos(ang));
			y0 = (radiusIn * sin(ang));
			ang = ang0 + arcAng;
			x1 = (radiusIn * cos(ang));
			y1 = (radiusIn * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.5 );
			y = y0 + ( ( y1-y0 ) * 0.5 );
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			// v2 + side
			ang = ang0 + 0.0;
			x0 = ( (radiusIn-DENTE_WIDTH) * cos(ang));
			y0 = ( (radiusIn-DENTE_WIDTH) * sin(ang));
			ang = ang0 + arcAng;
			x1 = ( (radiusIn-DENTE_WIDTH) * cos(ang));
			y1 = ( (radiusIn-DENTE_WIDTH) * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.66 );
			y = y0 + ( ( y1-y0 ) * 0.66 );
			[glSideIn addVertex:x :y :z11];
			[glSideIn addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z11];
			// A1
			// v3
			ang = ang0 + arcAng;
			x = (radiusIn * cos(ang));
			y = (radiusIn * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			// A1~A2
			// v4
			// Est vertice fica no meio do A1 e A2
			ang = ang0 + arcAng;
			x0 = ((radiusIn-DENTE_WIDTH) * cos(ang));
			y0 = ((radiusIn-DENTE_WIDTH) * sin(ang));
			ang = ang0 + (arcAng * 2.0);
			x1 = ((radiusIn-DENTE_WIDTH) * cos(ang));
			y1 = ((radiusIn-DENTE_WIDTH) * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.33 );
			y = y0 + ( ( y1-y0 ) * 0.33 );
			[glSideIn addVertex:x :y :z11];
			[glSideIn addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z11];
			// v5 + side
			ang = ang0 + arcAng;
			x0 = (radiusIn * cos(ang));
			y0 = (radiusIn * sin(ang));
			ang = ang0 + (arcAng * 2.0);
			x1 = (radiusIn * cos(ang));
			y1 = (radiusIn * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.5 );
			y = y0 + ( ( y1-y0 ) * 0.5 );
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			//
			// DENTE UP - END
			//
			// A2
			 ang = ang0 + (arcAng * 2.0);
			 x = (radiusIn * cos(ang));
			 y = (radiusIn * sin(ang));
			 [glSideIn addVertex:x :y :z1];
			 [glSideIn addVertex:x :y :z2];
		}
		//
		// DENTE IN / DOWN
		// Seseha a patir da 2o arco ate o 2o arco do gomo seguinte
		//
		// A3			< arcAng * 3	<< termina aqui
		//  |
		//  |-- v5		< arcAng * 2 + 2/3
		//  |   \
		//  |---  v4	< arcAng * 2 + 1/2
		//  |    /
		// A2 v3		< arcAng * 2
		//  |   \
		//  |---  v2	< arcAng * 1/2
		//  |    /
		//  |-- v1		< arcAng * 1/3
		//  |
		// A1			< arcAng		<< comeca aqui
		//  |
		// A0			< 0.0
		//
		else if (typeDenteIn == DENTE_DOWN)
		{
			// Comeca no gomo anterior
			ang0 -= gomoAng;
			// A1
			ang = ang0 + arcAng;
			x = (radiusIn * cos(ang));
			y = (radiusIn * sin(ang));
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//
			// DENTE UP - BEGIN
			//
			// A1~A2
			// v1 + side
			// Este vertice fica no meio de A0 e A1 
			ang = ang0 + arcAng;
			x0 = (radiusIn * cos(ang));
			y0 = (radiusIn * sin(ang));
			ang = ang0 + (arcAng * 2.0);
			x1 = (radiusIn * cos(ang));
			y1 = (radiusIn * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.33 );
			y = y0 + ( ( y1-y0 ) * 0.33 );
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			// v2 + side
			ang = ang0 + arcAng;
			x0 = ((radiusIn-DENTE_WIDTH) * cos(ang));
			y0 = ((radiusIn-DENTE_WIDTH) * sin(ang));
			ang = ang0 + (arcAng * 2.0);
			x1 = ((radiusIn-DENTE_WIDTH) * cos(ang));
			y1 = ((radiusIn-DENTE_WIDTH) * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.5 );
			y = y0 + ( ( y1-y0 ) * 0.5 );
			[glSideIn addVertex:x :y :z11];
			[glSideIn addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z11];
			// A2
			// v3
			ang = ang0 + (arcAng * 2.0);
			x = (radiusIn * cos(ang));
			y = (radiusIn * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			// A2~A3
			// v4
			// Est vertice fica no meio do A1 e A2
			ang = ang0 + (arcAng * 2.0);
			x0 = ((radiusIn-DENTE_WIDTH) * cos(ang));
			y0 = ((radiusIn-DENTE_WIDTH) * sin(ang));
			ang = ang0 + (arcAng * 3.0);
			x1 = ((radiusIn-DENTE_WIDTH) * cos(ang));
			y1 = ((radiusIn-DENTE_WIDTH) * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.5 );
			y = y0 + ( ( y1-y0 ) * 0.5 );
			[glSideIn addVertex:x :y :z11];
			[glSideIn addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z11];
			// v5 + side
			ang = ang0 + (arcAng * 2.0);
			x0 = (radiusIn * cos(ang));
			y0 = (radiusIn * sin(ang));
			ang = ang0 + (arcAng * 3.0);
			x1 = (radiusIn * cos(ang));
			y1 = (radiusIn * sin(ang));
			x = x0 + ( ( x1-x0 ) * 0.66 );
			y = y0 + ( ( y1-y0 ) * 0.66 );
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			//
			// DENTE UP - END
			//
			// A4
			 ang = ang0 + (arcAng * 3.0);
			 x = (radiusIn * cos(ang));
			 y = (radiusIn * sin(ang));
			 [glSideIn addVertex:x :y :z1];
			 [glSideIn addVertex:x :y :z2];
		}
		
		// Top Texture
		// Uma textura ao longo do eixo X
		// 1/2 textura ao longo do eixo Y
		// v1    v3    v5
		//  \   /  \  /
		//    v2    v4
		if (glDenteIn)
		{		
			[glDenteIn addTextureVertex:0.0  :0.5];
			[glDenteIn addTextureVertex:0.25 :1.0];
			[glDenteIn addTextureVertex:0.5  :0.5];
			[glDenteIn addTextureVertex:0.75 :1.0];
			[glDenteIn addTextureVertex:1.0  :0.5];
		}
	}
}




#pragma mark SIDES ARC 3

//
// GEAR SIDE + DENTE  ( OUT ) - ARC 3
//
// 3 faces no gomo - Cria a partir da 2a a cima, para encaixar os dentes
//
// A4		< arcAng * 4 (termina no arcAng do gomo seguinte)
//  \			< Dente IN
//   A3		< arcAng * 3 (fim deste gomo)
// /  \			< Dente IN
//  ---A2	< arcAng * 2
//     |		< Dente OUT
//  ---A1	< arcAng (comeca a sesenhar aqui)
// \  /
//   A0		< 0.0 (NAO DESENHA)
//
- (void)createMeshSideOut3
{
	// Create vertices
	GLfloat ang0, ang;
	GLfloat x, y, x0, y0, x1, y1;
	GLfloat z1 = -LABEL_DEPTH;
	GLfloat z11 = z1 - (DENTE_DEPTH*0.15);
	GLfloat z2 = (z1 - DENTE_DEPTH);
	GLfloat z22 = z2 + (DENTE_DEPTH*0.15);
	
	// Cria side para todos os gomos
	// Cria dentes somente no primeiro gomo (os outros serao repetidos)
	// ps: AGORA CRIA UM SO PARA OS LADOS TAMBEM
	for ( int n = 0 ; n < gomos ; n++)
	{
		// Angulo deste gomo
		//ang0 = (gomoAng * n);
		ang0 = [self angInit:n];
		
		// DENTE NOT - APENAS LADO
		if (typeDenteOut == DENTE_NOT)
		{
			// A1
			ang = ang0 + arcAng;
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			// A2
			ang += arcAng;
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			// A3
			ang += arcAng;
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			// A4
			ang += arcAng;
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			// Cria lados
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
		}
		//
		// DENTE OUT / UP
		//
		// A4		< arcAng * 4		<< proximo comeca aqui fechando o anterior
		//  |
		// A3		< arcAng * 3		<< acaba aqui
		//  |
		//  |-- v6		< arcAng * 2.5
		//  |   |
		// A2 = v5 - v4	< arcAng * 2
		//         /
		// A1 = v3 - v2	< arcAng * 1
		//  |      /
		//  |-- v1		< arcAng * 0.5	<< comeca aqui
		//  |
		// A0			
		//
		else if (typeDenteOut == DENTE_UP)
		{
			//
			// DENTE UP - BEGIN
			//
			// A0~A1
			// v1 + side
			// Est vertice fica no meio do A0 e A1
			ang = ang0;
			x0 = ( radiusOut * cos(ang));
			y0 = ( radiusOut * sin(ang));
			ang = ang0 + arcAng;
			x1 = ( radiusOut * cos(ang));
			y1 = ( radiusOut * sin(ang));
			x = x0 + ( ( x1-x0 ) / 2.0 );
			y = y0 + ( ( y1-y0 ) / 2.0 );
			//AvLog(@"DENTE OUT gomos[%d/%d] xy0[%.2f/%.2f] xy[%.2f/%.2f] ang0[%.2g]",n,gomos,x0,y0,x,y,ang0);
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			// A1
			// v2 + side
			ang = ang0 + arcAng;
			x = ( (radiusOut+DENTE_WIDTH) * cos(ang));
			y = ( (radiusOut+DENTE_WIDTH) * sin(ang));
			[glSideOut addVertex:x :y :z11];
			[glSideOut addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z11];
			// v3
			ang = ang0 + arcAng;
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			// A2
			// v4 + side
			ang = ang0 + arcAng * 2.0;
			x = ( (radiusOut+DENTE_WIDTH) * cos(ang));
			y = ( (radiusOut+DENTE_WIDTH) * sin(ang));
			[glSideOut addVertex:x :y :z11];
			[glSideOut addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z11];
			// v5
			ang = ang0 + arcAng * 2.0;
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			// A2~A3
			// v6
			// Est vertice fica no meio do A2 e A3
			ang = ang0 + arcAng * 2.0;
			x0 = ( radiusOut * cos(ang));
			y0 = ( radiusOut * sin(ang));
			ang = ang0 + arcAng * 3.0;
			x1 = ( radiusOut * cos(ang));
			y1 = ( radiusOut * sin(ang));
			x = x0 + ( ( x1-x0 ) / 2.0 );
			y = y0 + ( ( y1-y0 ) / 2.0 );
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			//
			// DENTE UP - END
			//
			// A3
			ang = ang0 + arcAng * 3.0;
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			// A4
			ang = ang0 + arcAng * 4.0;
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			// Cria lados
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			
			// Top Texture
			// Uma textura ao longo do eixo X
			// 1/2 textura ao longo do eixo Y
			// v1  v3  v5 - v6
			//  \  | \  |
			//    v2   v4
			//if (n == 0)
			{
				[glDenteOut addTextureVertex:0.0  :0.5];
				[glDenteOut addTextureVertex:0.33 :1.0];
				[glDenteOut addTextureVertex:0.33 :0.5];
				[glDenteOut addTextureVertex:0.66 :1.0];
				[glDenteOut addTextureVertex:0.66 :0.5];
				[glDenteOut addTextureVertex:1.0  :0.5];
			}
		}
		//
		// DENTE OUT / DOWN
		//
		// A5			
		//  |
		// A4 = v5		< arcAng * 4	< termina aqui
		//        \ v4	< arcAng * 3.5
		//        /
		// A3 = v3		< arcAng * 3
		//        \ v2	< arcAng * 2.5
		//       /
		// A2 = v1     	< arcAng * 2		<< comeca aqui
		//  |
		// A1			< arcAng
		//  |
		// A0
		//
		else if (typeDenteOut == DENTE_DOWN)
		{
			//
			// DENTE DOWN - BEGIN
			//
			// A2
			// v1 + side
			ang = ang0 + (arcAng * 2.0);
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			// v2
			ang = ang0 + (arcAng * 2.5);
			x = ( (radiusOut+DENTE_WIDTH) * cos(ang));
			y = ( (radiusOut+DENTE_WIDTH) * sin(ang));
			[glSideOut addVertex:x :y :z11];
			[glSideOut addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z11];
			// A3
			// v3
			ang = ang0 + (arcAng * 3.0);
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z1];
			// v4
			ang = ang0 + (arcAng * 3.5);
			x = ( (radiusOut+DENTE_WIDTH) * cos(ang));
			y = ( (radiusOut+DENTE_WIDTH) * sin(ang));
			[glSideOut addVertex:x :y :z11];
			[glSideOut addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteOut addVertex:x :y :z11];
			// A4
			// v5
			ang = ang0 + (arcAng * 4.0);
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			// Desenha dente apenas no 1o vertice
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			//if (n == 0)
				[glDenteOut addVertex:x :y :z1];
			// A5
			ang = ang0 +  (arcAng * 5.0);
			x = ( radiusOut * cos(ang));
			y = ( radiusOut * sin(ang));
			// Desenha dente apenas no 1o vertice
			[glSideOut addVertex:x :y :z1];
			[glSideOut addVertex:x :y :z2];
			
			// Top Texture
			// Uma textura ao longo do eixo X
			// 1/2 textura ao longo do eixo Y
			// v1  v3  v5
			//  \ / \ /
			//   v2  v4
			//if (n == 0)
			{
				[glDenteOut addTextureVertex:0.0 :0.5];
				[glDenteOut addTextureVertex:0.25:1.0];
				[glDenteOut addTextureVertex:0.5 :0.5];
				[glDenteOut addTextureVertex:0.75:1.0];
				[glDenteOut addTextureVertex:1.0 :0.5];
			}
		}
	}
}


//
// GEAR SIDE + DENTE  ( IN ) - ARC 3
//
- (void)createMeshSideIn3
{
	// Create vertices
	GLfloat ang0, ang;
	GLfloat x, y, x0, y0, x1, y1;
	GLfloat z1 = -LABEL_DEPTH;
	GLfloat z11 = z1 - (DENTE_DEPTH*0.15);
	GLfloat z2 = (z1 - DENTE_DEPTH);
	GLfloat z22 = z2 + (DENTE_DEPTH*0.15);

	// Cria side para todos os gomos
	// Cria dentes somente no primeiro gomo (os outros serao repetidos)
	// ps: AGORA CRIA UM SO PARA OS LADOS TAMBEM
	for ( int n = 0 ; n < gomos ; n++)
	{
		// Angulo deste gomo
		//ang0 = (gomoAng * n);
		ang0 = [self angInit:n];
		
		// DENTE NOT - APENAS LADO
		if (typeDenteIn == DENTE_NOT)
		{
			// A1
			ang = ang0 + arcAng;
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			// A2
			ang += arcAng;
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			// A3
			ang += arcAng;
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			// A4
			ang += arcAng;
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			// Cria lados
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
		}
		//
		// DENTE IN / UP
		//
		// A4		< arcAng * 4		<< proximo comeca aqui fechando o anterior
		//  |
		// A3		< arcAng * 3		<< acaba aqui
		//  |
		//  |-- v6		< arcAng * 2.5
		//  |   |
		// A2 = v5 - v4	< arcAng * 2
		//         /
		// A1 = v3 - v2	< arcAng * 1
		//  |      /
		//  |-- v1		< arcAng * 0.5	<< comeca aqui
		//  |
		// A0			
		//
		else if (typeDenteIn == DENTE_UP)
		{
			//
			// DENTE UP - BEGIN
			//
			// A0~A1
			// v1 + side
			// Est vertice fica no meio do A0 e A1
			ang = ang0;
			x0 = ( radiusIn * cos(ang));
			y0 = ( radiusIn * sin(ang));
			ang = ang0 + arcAng;
			x1 = ( radiusIn * cos(ang));
			y1 = ( radiusIn * sin(ang));
			x = x0 + ( ( x1-x0 ) / 2.0 );
			y = y0 + ( ( y1-y0 ) / 2.0 );
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			// A1
			// v2 + side
			ang = ang0 + arcAng;
			x = ( (radiusIn-DENTE_WIDTH) * cos(ang));
			y = ( (radiusIn-DENTE_WIDTH) * sin(ang));
			[glSideIn addVertex:x :y :z11];
			[glSideIn addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z11];
			// v3
			ang = ang0 + arcAng;
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			// A2
			// v4 + side
			ang = ang0 + arcAng * 2.0;
			x = ( (radiusIn-DENTE_WIDTH) * cos(ang));
			y = ( (radiusIn-DENTE_WIDTH) * sin(ang));
			[glSideIn addVertex:x :y :z11];
			[glSideIn addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z11];
			// v5
			ang = ang0 + arcAng * 2.0;
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			// A2~A3
			// v6
			// Est vertice fica no meio do A2 e A3
			ang = ang0 + arcAng * 2.0;
			x0 = ( radiusIn * cos(ang));
			y0 = ( radiusIn * sin(ang));
			ang = ang0 + arcAng * 3.0;
			x1 = ( radiusIn * cos(ang));
			y1 = ( radiusIn * sin(ang));
			x = x0 + ( ( x1-x0 ) / 2.0 );
			y = y0 + ( ( y1-y0 ) / 2.0 );
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			//
			// DENTE UP - END
			//
			// A3
			ang = ang0 + arcAng * 3.0;
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			// A4
			/* Fecha no proximo
			 ang = ang0 + arcAng * 4.0;
			 x = ( radiusIn * cos(ang));
			 y = ( radiusIn * sin(ang));
			 // Cria lados
			 [glSideIn addVertex:x :y :z1];
			 [glSideIn addVertex:x :y :z2];
			 */
			
			// Top Texture
			// Uma textura ao longo do eixo X
			// 1/2 textura ao longo do eixo Y
			// v1  v3  v5 - v6
			//  \  | \  |
			//    v2   v4
			//if (n == 0)
			{
				[glDenteIn addTextureVertex:0.0  :0.5];
				[glDenteIn addTextureVertex:0.33 :1.0];
				[glDenteIn addTextureVertex:0.33 :0.5];
				[glDenteIn addTextureVertex:0.66 :1.0];
				[glDenteIn addTextureVertex:0.66 :0.5];
				[glDenteIn addTextureVertex:1.0  :0.5];
			}
		}
		//
		// DENTE IN / DOWN
		//
		// A4 = v5		< arcAng * 4	< termina aqui
		//        \ v4	< arcAng * 3.5
		//        /
		// A3 = v3		< arcAng * 3
		//        \ v2	< arcAng * 2.5
		//       /
		// A2 = v1     	< arcAng * 2		<< comeca aqui
		//  |
		// A1			< arcAng
		//  |
		// A0
		//
		else if (typeDenteIn == DENTE_DOWN)
		{
			//
			// DENTE DOWN - BEGIN
			//
			// A2
			// v1 + side
			ang = ang0 + (arcAng * 2.0);
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			// v2
			ang = ang0 + (arcAng * 2.5);
			x = ( (radiusIn-DENTE_WIDTH) * cos(ang));
			y = ( (radiusIn-DENTE_WIDTH) * sin(ang));
			[glSideIn addVertex:x :y :z11];
			[glSideIn addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z11];
			// A3
			// v3
			ang = ang0 + (arcAng * 3.0);
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z1];
			// v4
			ang = ang0 + (arcAng * 3.5);
			x = ( (radiusIn-DENTE_WIDTH) * cos(ang));
			y = ( (radiusIn-DENTE_WIDTH) * sin(ang));
			[glSideIn addVertex:x :y :z11];
			[glSideIn addVertex:x :y :z22];
			//if (n == 0)		// Desenha dente apenas no 1o vertice
				[glDenteIn addVertex:x :y :z11];
			// A4
			// v5
			ang = ang0 + (arcAng * 4.0);
			x = ( radiusIn * cos(ang));
			y = ( radiusIn * sin(ang));
			// Desenha dente apenas no 1o vertice
			[glSideIn addVertex:x :y :z1];
			[glSideIn addVertex:x :y :z2];
			//if (n == 0)
				[glDenteIn addVertex:x :y :z1];
			
			// Top Texture
			// Uma textura ao longo do eixo X
			// 1/2 textura ao longo do eixo Y
			// v1  v3  v5
			//  \ / \ /
			//   v2  v4
			//if (n == 0)
			{
				[glDenteIn addTextureVertex:0.0 :0.5];
				[glDenteIn addTextureVertex:0.25:1.0];
				[glDenteIn addTextureVertex:0.5 :0.5];
				[glDenteIn addTextureVertex:0.75:1.0];
				[glDenteIn addTextureVertex:1.0 :0.5];
			}
		}
	}
}


#pragma mark LABELS

//
// NEW LABEL MAPS
// Cria um label na coluna e posicao indicada
// cada label eh um elemento de 4 vertices
// um em cima do outro
//
//    v1  v3
//     | / |
//    v2  v4
//
- (void)addLabelNew:(int)row pos:(int)n align:(int)align texname:(NSString*)texname map:(int)map
{
	GLfloat ang0, ang, x0, y0, x, y, w, h;
	GLfloat z = 0.0;
	GLfloat r;
	CGSize texsize;
	CGPoint pos;
	

    
	// Alloc?
	if (glLabels[row] == nil)
	{
		glLabels[row] = [[GLElements alloc] initElements:4 el:gomos];
		glLabels[row].blending = TRUE;
        [glLabels[row] setTexture:texname alpha:YES];
	}
	
	// Set texture
	//[glLabels[row] setTexture:texname alpha:YES toElement:n];
	//if( n == 0 )
    
	// Recupera angulo de inicio deste gomo
	//ang0 = [self angInit:(n+1)];
	ang0 = [self angInit:n];


	// Origem = Centro do gomo
	// Coluna zero = fora, coluna 1 = dentro
	//
	//   A2		< gomoAng
	// /  \
	//  ---A1	< gomoAng / 2.0
	// \  /
	//   A0		< 0.0
	//
	ang = ( ang0 + (gomoAng * 0.5) );
	
	// Alinha no centro da do gomo
	if (align == LABEL_ALIGN_CENTER)
		r = radiusCenter;
	// Alinha no centro da coluna
	else	// LABEL_ALIGN_ROW
		r = radiusRow[row];
	// Define ponto central
	x0 = (r * cos(ang));
	y0 = (r * sin(ang));
	
	// Origem do mesh fica no centro do label
	w = (labelWidth/2.0);	// dx
	h = (labelHeight/2.0);	// dy
	

    
	// v1 - Inner Vertice
	pos = [self rotateXY:(-w) :(h) ang:ang];
	x = x0 + pos.x;
	y = y0 + pos.y;
	[glLabels[row] addVertex:x :y :z];
	// v2 - Outer Vertice
	pos = [self rotateXY:(-w) :(-h) ang:ang];
	x = x0 + pos.x;
	y = y0 + pos.y;
	[glLabels[row] addVertex:x :y :z];
    

	// v3 - Inner Vertice
	pos = [self rotateXY:(w) :(h) ang:ang];
	x = x0 + pos.x;
	y = y0 + pos.y;
	[glLabels[row] addVertex:x :y :z];
    
 
	// v4 - Outer Vertice
	pos = [self rotateXY:(w) :(-h) ang:ang];
	x = x0 + pos.x;
	y = y0 + pos.y;

	[glLabels[row] addVertex:x :y :z];
    
    if( n == 19 )
    {
        GLTexture *tex;
        tex = [global.texLib.vbos objectForKey:texname];
        GLuint iii = tex.vbo;
        
    }

	//AvLog(@"ADD LABEL NEW row[%d][%d] ang[%.2f] x0y0[%.2f/%.2f] tex[%@][%d]",row,n,(ang0*RADIAN_ANGLES),x0, y0,texname,map);

	// Texture Mapping
	// v2  v4
	//  | \ |
	// v1  v3
	//
	// Texture Atlas
	// Mapa de 16x16 texturas de 64x64 pixels
	// Ordenadas em ordem de leitura (esq->dir / cima->baixo)

    
	texsize = [global.texLib getSize:texname];
	w = (1.0 / (texsize.width / 64.0)) * (labelWidth/labelHeight);	// Considera proporcoes entre alt/larg
	h = (1.0 / (texsize.height / 64.0));
	x0 = ((map % 16) * w);
	y0 = ((map / 16) * h);
	if (rotation == ROTATE_CCW)
	{
		// normal
		[glLabels[row] addTextureVertex:x0   :y0];
		[glLabels[row] addTextureVertex:x0   :y0+h];
		[glLabels[row] addTextureVertex:x0+w :y0];
		[glLabels[row] addTextureVertex:x0+w :y0+h];
	}
	else
	{
		// vira de ponta-cabeca
		[glLabels[row] addTextureVertex:x0+w :y0+h];
		[glLabels[row] addTextureVertex:x0+w :y0];
		[glLabels[row] addTextureVertex:x0   :y0+h];
		[glLabels[row] addTextureVertex:x0   :y0];
	}
	//AvLog(@"LABEL MAP [%@][%03d] size[%.1f/%.1f] w/h[%.3f/%.3f] x/y[%.3f/%.3f]",texname,map,texsize.width,texsize.height,w,h,x0,y0);
	//AvLog(@"ADD LABELMAP ix[%d] [%@] ibo[%d]",i,texname,glLabels[row].tex);
}


// Devolve coordenadas rotacionadas no angulo ang a partir do centro 0x0
// Sempre em RADIANOS
- (CGPoint)rotateXY:(GLfloat)x :(GLfloat)y ang:(GLfloat)ang
{
	// Calcula novo angulo do XY
	GLfloat a0 = atan2( y, x );
	GLfloat a = ( a0 + ang);
	// Calcula raio
	GLfloat r = DISTANCE_BETWEEN(0.0,0.0,x,y);
	// Calcula novo XY com o mesmo raio
	CGPoint pos;
	pos.x = (r * cos(a));
	pos.y = (r * sin(a));
	return pos;
}




#pragma mark BINDING

// Translate - Define novo centro
- (void)bindData
{
	// Disco
	[glObject bindData];
	// Sides
	[glSideOut bindData];
	[glSideIn bindData];
	// Dentes
	if (glDenteOut)
		[glDenteOut bindData];
	if (glDenteIn)
		[glDenteIn bindData];
	// Labels
	for (int n = 0 ; n < rows ; n++)
		if (glLabels[n])
			[glLabels[n] bindData];
}




#pragma mark TRANSLATIONS

// Translate - Define novo centro
- (void)setTranslate:(GLfloat)cx :(GLfloat)cy :(GLfloat)cz
{
	// Guarda para referencia
	centerX = cx;
	centerY = cy;
	
	// Move disco
	glTransform trans = glObject.trans;
	trans.center.x = cx;
	trans.center.y = cy;
	trans.center.z = cz;
	glObject.trans = trans;
}
// Rotation (variavel): Gomos
- (void)setRotate:(int)g :(GLfloat)dec
{
	// Mudou de gomo?
	if (g != currentGomo)
	{
		currentGomo = g;
		[self makeDisplayArray];
	}
	
	// Angulo: Gomo atual + dec atual
	currentAng = ( gomoAng * ( ((GLfloat)currentGomo) + dec ) * RADIAN_ANGLES );
	glTransform trans = glObject.trans;
	trans.rot.z = currentAng;
	glObject.trans = trans;
}


#pragma mark EABLE_DISABLE

// Activate for drawing
- (void)enable
{
	isEnabled = TRUE;

	// Define gomos a desenhar
	//[self makeDisplayArray];

	// save the main projection - FOI PRO 3D VIEW
	//glMatrixMode(GL_MODELVIEW);
	glPushMatrix();	
	
	// Gear
	// PERFORMANCE: First all Dual Textured Objects and then all Single Textured Objects
	// PERFORMANCE: Reduzir o numero de binds agrupando objetos com mesma textura = 1.0 fps!
	// Gear
	[glObject enable];
	// Dentes
	if (glDenteOut)
        [glDenteOut enable];//:gomoIni :displaySize];
	if (glDenteIn)
        [glDenteIn enable ];//:gomoIni :displaySize];
	// Sides
    [glSideOut enable] ;//]:gomoIni :displaySize];   
    [glSideIn enable];//:gomoIni :displaySize];
	//[glSideOut enable:sideIniOut :displaySideOut];
	//[glSideIn enable:sideIniIn :displaySideIn];

	// Labels
	// PERFORMANCE: Desenhar quem usa alpha blending por ultimo
	for (int n = 0 ; n < rows ; n++)
		if (glLabels[n])
            [glLabels[n] enable];// :gomoIni :displaySize];

	// retrieve main projection / undo gear transforms - FOI PRO 3D VIEW
	//glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
}

// Deactivate for drawing
- (void)disable
{
	// Just mark disabled
	isEnabled = FALSE;
	return;
}

// Highlight a gear
- (void)highlight:(BOOL)h
{
	glObject.highlight = h;
}


#pragma mark SOUND BUFFERS

//
// Create sound Buffers
//
- (void)makeSoundBuffers:(int)oct
{
	// Alloc Sound Buffers
	int sinesSize = (sizeof(TzSoundSine*) * gomos);
	sines = (TzSoundSine**) malloc( (size_t)sinesSize );
	memset(sines, 0, (size_t)sinesSize );

	// Create Sines
	for (int n = 0 ; n < gomos ; n++)
		sines[n] = [[TzSoundSine alloc] initWithOct:oct dec:( (CGFloat)n / (CGFloat)gomos ) length:2.0 fade:TRUE];
}

// Return the sound buffer of the current GOMO
-(TzSoundBuffer*) currentSoundBuffer
{
	if (sines)
		return (TzSoundBuffer*) sines[currentGomo];
	else
		return (TzSoundBuffer*) nil;
}


#pragma mark MATH

// Retorna o angulo de inicio de um gomo ( n = 0 : primeiro gomo)
//
//   G1		< n=1 - CW
// /  \
//  ---G0	< n=0 - CW
// \  /
//   G-1	< n=0 - CCW
// ...
//
- (CGFloat)angInit:(int)n
{
	if (rotation == ROTATE_CW)
		return ( gomoAng * n );
	else
		return ( gomoAng * (gomos-1-n) );
}

// Verifica se um ponto esta dentro da engrenagem
- (BOOL)isInside:(CGFloat)x :(CGFloat)y
{
	CGFloat dist = DISTANCE_BETWEEN(centerX,centerY,x,y);
	//AvLog(@"CENTER xy[%.3f/%.3f] to[%.3f/%.3f] radIO[%.3f/%.3f] dist[%.3f]",centerX,centerY,x,y,radiusIn,radiusOut,dist);
	return ( ( dist >= radiusIn && dist <= radiusOut ) ? TRUE : FALSE );
}
// Verifica se um ponto esta proximo da engrenagem (sua largura p/ dentro e p/ fora)
- (BOOL)isAround:(CGFloat)x :(CGFloat)y
{
	CGFloat dist = DISTANCE_BETWEEN(centerX,centerY,x,y);
	return ( ( dist >= (radiusIn-gomoWidth) && dist <= (radiusOut+gomoWidth) ) ? TRUE : FALSE );
}

// Verifica se um ponto esta dentro da engrenagem
// ang = arctan (opposite / adjascent)
// Retorna em GRAUS
- (CGFloat)angTo:(CGFloat)x :(CGFloat)y
{
	return ( atan2f(x-centerX,y-centerY) * RADIAN_ANGLES );
}

// Retorna a diferenca entre 2 angulos em GRAUS
// Retorna em GRAUS
- (CGFloat)angDiff:(CGFloat)ang1 :(CGFloat)ang2
{
	CGFloat diff;
	// Depende da direcao da engrenagem
	if (rotation == ROTATE_CCW)
	{
		// Calcula a diferenca de angulos
		diff = (ang1-ang2);
		// Verifica se passou do limite inferior
		if (ang1 > 90.0 && ang2 < -90.0)
			diff -= 360.0;
		else if (ang1 < -90.0 && ang2 > 90.0)
			diff += 360.0;
	}
	else
	{
		// Calcula a diferenca de angulos
		diff = (ang2-ang1);
		// Verifica se passou do limite inferior
		if (ang2 > 90.0 && ang1 < -90.0)
			diff -= 360.0;
		else if (ang2 < -90.0 && ang1 > 90.0)
			diff += 360.0;
	}
	return diff;
}


@end
