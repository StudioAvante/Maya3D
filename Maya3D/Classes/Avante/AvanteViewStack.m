//
//  AvanteViewStack.m
//  Maya3D
//
//  Created by Roger on 05/04/09.
//  Copyright 2009 Studio Avante. All rights reserved.
//

#import "AvanteViewStack.h"
#import "AvanteView.h"


@implementation AvanteViewStack

- (void)dealloc
{
	// super
    [super dealloc];
}


//
// STACK: Adiciona uma view ao stack
//
- (void)stackView:(AvanteView*)v
{
	CGRect frame;
	
	// Calcula Y e HEIGHT da nova view
	frame = v.frame;
	frame.origin.y = [self getHeightSum];
	//frame.size.height = v.heightSum;	// SE MEXEU FUDEU!!! desordena tudo dentro dele
	v.frame = frame;
	
	// Guarda referencia desta view
	stack[size] = v;
	
	// next...
	size++;
}

//
// RESIZE: Resize frame de acordo com views adicionadas
//
- (void)resize
{
	CGRect frame;
	CGFloat y = 0.0;
	CGFloat h;
	AvanteView *v;

	for (int n = 0 ; n < size ; n++ )
	{
		// Get next view in stack
		v = stack[n];
		h = v.heightSum;

		// Update frame Y / HEIGHT
		frame = v.frame;
		frame.origin.y = y;
		//frame.size.height = h;	// SE MEXEU FUDEU!!! desordena tudo dentro dele
		v.frame = frame;
		
		// Increase Y
		y += h;
	}
}

//
// HEIGHT: Retorna o tamanho total, soma de todas as views
//
- (CGFloat)getHeightSum
{
	CGFloat h = 0.0;
	for (int n = 0 ; n < size ; n++ )
		h += stack[n].heightSum;
	return h;
}


@end
