//
//  AvantePickerElement.m
//  Maya3D
//
//  Created by Roger on 28/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "AvantePickerComponent.h"


@implementation AvantePickerComponent

@synthesize title;
@synthesize width;
@synthesize height;
@synthesize callback;

- (void)dealloc
{
	[title release];
	[text release];
	[data release];
	[views release];
	[super dealloc];
}

- (id)init:(NSString*)t w:(int)w h:(int)h
{
	self = [super init];
	if (!self)
		return nil;
	// init data
	title = [[NSString alloc] initWithString:t];
	width = w;
	height = h;
	text = [[NSMutableArray alloc] init];
	data = [[NSMutableArray alloc] init];
	views = [[NSMutableArray alloc] init];
    imageNames = [[NSMutableArray alloc] init];
	return self;
}

// Adiciona um elemento / row
// Return TRUE ou FALSE
- (BOOL)addRow:(NSString*)str
{
	return [self addRow:str data:str];
}
- (BOOL)addRow:(NSString*)str data:(NSString*)dt
{
	[text addObject:str];
	[data addObject:dt];
	return TRUE;
}
- (BOOL)addRowView:(UIView*)view data:(NSString*)dt
{
	// Add row
	[views addObject:view];
	[data addObject:dt];
	return TRUE;
}

- (BOOL)addRowImageName:(NSString*)name data:(NSString*)dt
{
    [imageNames addObject:name];
    [data addObject:dt];
    return TRUE;
}
// Retorna numero de rows / elementos deste componente
- (NSUInteger)count
{
	return [data count];
}

// SETTER
// Retorna altura dos componentes baseados no 1o view.
- (CGFloat)smartHeight
{
	// Se nao tem view, improvisa....
	if (height > 0)
		return height;
	// Se nao tem view, eh um texto, usa padrao
	if ([views count] == 0)
		return 35.0;
	// senao devolve altura da view mas um poquito
//	return 35.0;   
	UIView *viewToUse = [views objectAtIndex:0];
	if (viewToUse == nil)
		return 0;
	else
		return viewToUse.bounds.size.height + 15.0;
}

// Retorna dados de uma linha
- (NSString*)dataForRow:(NSInteger)row
{
	if ([data count] < (row+1) )
		return nil;
	return (NSString*) [data objectAtIndex:row];
}
// Retorna texto de uma linha  (somente componentes sem view)
- (NSString*)textForRow:(NSInteger)row
{
	if ([text count] < (row+1) )
		return nil;
	return (NSString*) [text objectAtIndex:row];
}

// Retorna view de uma linha (somente componentes com view)
- (UIView*)viewForRow:(NSInteger)row
{
	if ([views count] < (row+1) )
		return nil;
	return (UIView*) [views objectAtIndex:row];
}

- (NSString*)imageNameForRow:(NSInteger)row
{
    if ([imageNames count] < (row+1) )
        return nil;
    
    return [imageNames objectAtIndex:row];
}

// Retorna a linha onde se encontra um dado
- (NSInteger) indexOfData:(NSString*)str
{
	for ( int row = 0 ; row < [data count] ; row++ )
	{
		NSString *ss = [data objectAtIndex:row];
		if ( [str compare:ss] == NSOrderedSame )
			return row;
	}
	return -1;
}
// Retorna a linha cujo dado se aproxima mais de um valor
- (NSInteger) indexOfDataCloser:(NSInteger)target
{
	NSInteger value, closerValue;
	NSInteger closerIndex = -1;
	for ( int row = 0 ; row < [data count] ; row++ )
	{
		value = [[data objectAtIndex:row] integerValue];
		if ( abs((int)(target-value)) < abs((int)(target-closerValue)) || closerIndex == -1)
		{
			closerIndex = row;
			closerValue = value;
		}
	}
	return closerIndex;
}
// Retorna a linha onde se encontra um texto
- (NSInteger) indexOfText:(NSString*)str
{
	for ( int row = 0 ; row < [text count] ; row++ )
	{
		NSString *ss = [text objectAtIndex:row];
		if ( [str compare:ss] == NSOrderedSame )
			return row;
	}
	return -1;
}



@end
