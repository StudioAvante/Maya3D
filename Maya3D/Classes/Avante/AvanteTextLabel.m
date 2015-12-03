//
//  AvanteTextLabel.m
//  Maya3D
//
//  Created by Roger on 21/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "AvanteTextLabel.h"
#import "Tzolkin.h"

@implementation AvanteTextLabel

@synthesize width;
@synthesize height;
@synthesize theLabel;


- (void)dealloc
{
	[super dealloc];
}



// Original UIView initializer
/*
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}
*/

// MY INIT
// Desenha dentro de um retangulo, CENTRALIZADO
- (id)init:(NSString*)str frame:(CGRect)f size:(CGFloat)sz color:(UIColor*)c
{
	return [self init:str x:f.origin.x y:f.origin.y w:f.size.width h:f.size.height size:sz color:c];
}

// MY INIT
// Desenha dentro de um retangulo, CENTRALIZADO
- (id)init:(NSString*)str x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz color:(UIColor*)c
{
	// Frame fixo!
	framed = YES;
	// Guarda Tamanho inicial
	sizeOrig.width = w;
	sizeOrig.height = h;
	// Tamanhos atuais
	width = w;
	height = h;
	//AvLog(@"INIT LABEL w[%f] h[%f] x[%f] y[%f] text[%@]", w, h, x, y, str);
	return [self init:str x:x y:y size:sz color:c];
}

// MY INIT
// Desenha na posicao X/Y definida
- (id)init:(NSString*)str x:(CGFloat)x y:(CGFloat)y size:(CGFloat)sz color:(UIColor*)c
{
	// Inicializa view
	if ((self = [super initWithFrame:CGRectZero]) == nil)
		return nil;

	// Guarda posicaono pai
	parentX = x;
	parentY = y;
	
	// cria o label
	theLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	theLabel.backgroundColor = [UIColor clearColor];
	theLabel.font = [UIFont systemFontOfSize:sz];
	theLabel.textAlignment = UITextAlignmentCenter;
	theLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	
	// Set text & frame + add!
	[self update:str color:c];
	[self resizeFrame];
	[self addSubview:theLabel];
	[theLabel release];
	
	// config view
	// outros
	self.frame = CGRectMake(parentX, parentY, width, height);
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.backgroundColor = [UIColor clearColor];	// make the background transparent
	//clearsContextBeforeDrawing = TRUE;

	//AvLog(@"INIT LABEL w[%f] h[%f] x[%f] y[%f] text[%@]", width, height, x, y, str);
	return self;
}

//
// SET FRAME
//
- (void)resizeFrame
{
	CGSize size;	
	// Se nao tem frame, calcula nova LARGURA de acordo com texto
	if (framed == NO)
	{
		size = [theLabel.text sizeWithFont:theLabel.font];
		width = size.width;
		height = size.height;
	}
	// Se wrap, calcula nova ALTURA de acordo com texto
	else if (wrapped == YES)
	{
		// Get new frame size
		size = [theLabel.text sizeWithFont:theLabel.font constrainedToSize:sizeOrig lineBreakMode:UILineBreakModeWordWrap];
		// Use new size
		width = size.width;
		height = size.height;
	}
	
	// v1.2: centraliza
	CGFloat x = ceil( (framed == YES && theLabel.textAlignment == UITextAlignmentCenter) ? (sizeOrig.width-width) / 2.0 : 0.0);
	
	// Atualiza posicao dentro do pai de acordo com tamanho do texto
	theLabel.frame = CGRectMake(x, 0.0, width, height);
	//AvLog(@"RESIZE FRAME [%@]",theLabel.text);
}

#pragma mark UPDATE

//
// UPDATE TEXT
//
// Update text and schedule redraw
- (void)update:(NSString*)str color:(UIColor*)c
{
	// update color
	[self setColorBestShadow:c];
	// update Label
	[self update:str];
}
- (void)update:(NSString*)str
{
	// Update field text
	theLabel.text = str;
	
	// Se nao tem frame, re-calcula tamanho do texto
	if (framed == FALSE || wrapped == YES)
		[self resizeFrame];
	
	//AvLog(@"UPDATE LABEL x[%.1f] y[%.1f] w[%.1f] h[%.1f] [%@]",self.frame.origin.x,self.frame.origin.x,self.frame.size.width,self.frame.size.height,str);
	
	// Redesenha label
	//[self setNeedsDisplay];
}


#pragma mark SETTERS

//
// SETTERS
//
- (void)setAlign:(UITextAlignment)a
{
	if (a == ALIGN_LEFT)
		theLabel.textAlignment = UITextAlignmentLeft;
	else if (a == ALIGN_RIGHT)
		theLabel.textAlignment = UITextAlignmentRight;
	else
		theLabel.textAlignment = UITextAlignmentCenter;
}
- (void)setWrap:(BOOL)wrap
{
	wrapped = wrap;
	if (wrapped)
	{
		theLabel.lineBreakMode = UILineBreakModeWordWrap;
		theLabel.numberOfLines = 100;
	}
	else
	{
		theLabel.lineBreakMode = UILineBreakModeTailTruncation;
		theLabel.numberOfLines = 1;
	}
}
- (void)setFit:(BOOL)fit
{
	theLabel.adjustsFontSizeToFitWidth = fit;
}
- (void)setBold:(BOOL)b
{
	if (bold)
		theLabel.font = [UIFont boldSystemFontOfSize:theLabel.font.pointSize];
	else
		theLabel.font = [UIFont systemFontOfSize:theLabel.font.pointSize];
}


//
// SET COLOR
//
// Set color only
- (void)setColor:(UIColor*)c
{
	theLabel.textColor = c;
}
// Set shadow only
- (void)setShadow:(UIColor*)c
{
	theLabel.shadowColor = c;
}
// Set color and its better shadow
- (void)setColorBestShadow:(UIColor*)c
{
	// Set color
	theLabel.textColor = c;
	// Set better shadow
	if ( c == [UIColor redColor] )
		theLabel.shadowColor = [UIColor redColor];
	if ( c == [UIColor whiteColor] )
		theLabel.shadowColor = [UIColor darkGrayColor];
	else
		theLabel.shadowColor = [UIColor whiteColor];
}

#pragma mark STYLE

//
// SET STYLE
//
// Style for Pickers
- (void)setPickerStyle
{
	// Font
	theLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
	// Colors
	theLabel.textColor = [UIColor blackColor];
	theLabel.shadowColor = [UIColor whiteColor];
	theLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	// new Frame
	[self resizeFrame];
}
- (void)setNavigationBarStyle
{
	// Font
	theLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
	// Colors
	theLabel.textColor = [UIColor whiteColor];
	theLabel.shadowColor = [UIColor darkGrayColor];
	theLabel.shadowOffset = CGSizeMake(0.0, 0.0);
	// new Frame
	[self resizeFrame];
}

@end
