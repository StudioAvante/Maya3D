//
//  AvanteTextField.m
//  Maya3D
//
//  Created by Roger on 21/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "AvanteTextField.h"

#define MAIN_FONT_SIZE		20.0
#define MIN_MAIN_FONT_SIZE	8.0


@implementation AvanteTextField

@synthesize textField;

- (void)dealloc
{
	[super dealloc];
}


/*
// Original UIView initializer
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
 }
*/

// MAYA Constructor
- (id)initMayaNum:(int)n x:(CGFloat)x y:(CGFloat)y offx:(CGFloat)offx offy:(CGFloat)offy w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz type:(int)t
{
	offsetX = offx;
	offsetY = offy;
	return [self initMayaNum:n x:x y:y w:w h:h size:sz type:t];
}
- (id)initMayaNum:(int)n x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz type:(int)t
{
	// Create as numeric
	// Inicializa
	if ((self = [self init:@"" x:x y:y w:w h:h size:sz]) == nil)
		return nil;

	// Cria view para numero maya
	mayaImage = [[AvanteMayaNum alloc]
				 init:0
				 x:(w-IMAGE_SIZE_SMALL)/2+offsetX
				 y:(h-IMAGE_SIZE_SMALL)/2+offsetY
				 size:IMAGE_SIZE_SMALL];
	mayaImage.hidden = TRUE;
	[self addSubview:mayaImage];
	[mayaImage release];
	
	// Apdate as maya
	[self updateMayaNum:n type:t];
	return self;
}

// Generic Constructor - com OFFSET
- (id)init:(NSString*)str x:(CGFloat)x y:(CGFloat)y offx:(CGFloat)offx offy:(CGFloat)offy w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz
{
	offsetX = offx;
	offsetY = offy;
	return [self init:str x:x y:y w:w h:h size:sz];
}
// Generic Constructor
- (id)init:(NSString*)str x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h size:(CGFloat)sz
{
	// Inicializa
	if ((self = [super initWithFrame:CGRectZero]) == nil)
		return nil;
	
	// Define tamanho do frame da view
	type = NUMBERING_123;
	self.frame = CGRectMake(x, y, w, h);
	//autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.backgroundColor = [UIColor clearColor];	// make the background transparent
	
	// Define texto e fonte
	highlighted = FALSE;
	
	// Cria o UITextField SEM TEXTO
	CGRect myFrame = CGRectMake(0.0, 0.0, w, h);
	textField = [[UITextField alloc] initWithFrame:myFrame];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textColor = [UIColor blackColor];
	textField.placeholder = @"";
	textField.backgroundColor = [UIColor whiteColor];
	textField.textAlignment = UITextAlignmentCenter;
	textField.enabled = FALSE;
	[self addSubview:textField];
	[textField release];

	// Cria um label com o texto por cima, centralizado
	label = [[AvanteTextLabel alloc] 
			 init:str 
			 x:0.0+offsetX
			 y:0.0+offsetY
			 w:w
			 h:h
			 size:sz
			 color:[UIColor blackColor]];
	label.hidden = FALSE;
	// Adiciona no Field para rotacionar direito no 3D
	[textField addSubview:label];
	[label release];
	
	// OK!
	return self;
}

//
// ACT AS BUTTON
//
- (void)addTarget:(id)target action:(SEL)action
{
	butTarget = target;
	butAction = action;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (butTarget && butAction)
		[butTarget performSelector:butAction];
}


// update text image only
- (void)update:(NSString*)str
{
	[label update:str];
}
// update maya image & text label
- (void)updateMayaNum:(int)n type:(int)t
{
	// se mudou de tipo, redesenha esta view
	if (t != type)
	{
		type = t;
		if (type == NUMBERING_MAYA)
		{
			mayaImage.hidden = FALSE;
			label.hidden = TRUE;
		}
		else
		{
			mayaImage.hidden = TRUE;
			label.hidden = FALSE;
		}

	}
	// update maya num
	if (type == NUMBERING_MAYA)
		[mayaImage updateWithNum:n];
	// update text label
	else
		[self update:[NSString stringWithFormat:@"%d",n]];
}

// Resize textField to text name
- (void)resizeToText
{
	// Get text size
	CGSize size = [label.theLabel.text sizeWithFont:label.theLabel.font];
	[self resize:(size.width + 16.0):(size.height + 8.0)];
}
// Resize textField
- (void)resize:(CGFloat)w:(CGFloat)h
{
	// Resize textField
	CGRect f = textField.frame;
	f.size.width = w;
	f.size.height = h;
	textField.frame = f;
	//AvLog(@"RESIZE field frame xy[%.2f/%.2f] wh[%.2f/%.2f]",f.origin.x,f.origin.y,f.size.width,f.size.height);
	// Resize Label
	f = label.frame;
	f.size.width = w;
	f.size.height = h;
	label.frame = f;
	label.width = w;
	label.height = h;
	[label resizeFrame];
	//AvLog(@"RESIZE label frame xy[%.2f/%.2f] wh[%.2f/%.2f]",f.origin.x,f.origin.y,f.size.width,f.size.height);
}


@end
