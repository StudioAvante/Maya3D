//
//  AvantePicker.m
//  Maya3D
//
//  Created by Roger on 28/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "AvantePicker.h"

#define LABEL_FONT_SIZE	12.0

@implementation AvantePicker

@synthesize drawLabels;

- (void)dealloc
{
	[components release];
	[super dealloc];
}

- (id)init:(CGFloat)x y:(CGFloat)y labels:(BOOL)l
{
	CGRect frame;

	// Size frame with labels
	drawLabels = l;
	if (drawLabels)
		frame = CGRectMake(x, y, kscreenWidth, (kUIPickerHeight + HEIGHT_FOR_LINES(LABEL_FONT_SIZE,1)) );
	else
		frame = CGRectMake(x, y, kscreenWidth, kUIPickerHeight);
	
	// super
	if ( (self = [super initWithFrame:frame]) == nil)
		return nil;
	
	// Configure UIPickerView
//	self.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin |        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.showsSelectionIndicator = YES;	// note this is default to NO
    self.delegate = self;
    self.dataSource = self;
    
    self.backgroundColor = [UIColor whiteColor];
	// Inicializa os componentes
	components = [[NSMutableArray alloc] init];
	// ok!
	return self;
}


// Adiciona um component (Coluna)
- (void)addComponent:(NSString*)text w:(int)w
{
	[self addComponent:text w:w h:0.0];
}
- (void)addComponent:(NSString*)text w:(int)w h:(int)h
{
	AvantePickerComponent *comp = [[AvantePickerComponent alloc] init:text w:w h:h];
	[components addObject:comp];
	//AvLog(@"NEW COMPONENT *[%d] [%@] components=[%d]", comp, text, [components count]);
	[comp release];	// no exemplo releasava
}

// Adiciona um row (dado)
// Return TRUE ou FALSE
- (BOOL)addRowToComponent:(int)component text:(NSString*)str
{
	return [self addRowToComponent:component text:str data:str];
}
- (BOOL)addRowToComponent:(int)component text:(NSString*)str data:(NSString*)dt 
{
	// Find component
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return FALSE;
	//AvLog(@"NEW ROW at [%d] dt[%@] text[%@]", c, dt, str);
	[comp addRow:str data:dt];
	return TRUE;
}

// Adiciona callback
- (void)addComponentCallback:(NSInteger)component :(id)obj :(SEL)action
{
	// Find component
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return;
	//AvLog(@"NEW ROW at [%d] [%@]", c, str);
	parent = obj;
	comp.callback = action;
	return;
}



// Seleciona um elemento
- (void)selectRowWithData:(NSString*)dt inComponent:(NSInteger)component animated:(BOOL)anim
{
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return;
	// Select row
	NSInteger row = [comp indexOfData:dt];
	if ( row >= 0) 
		[self selectRow:row inComponent:component animated:anim];
}
- (void)selectRowWithDataCloser:(NSInteger)target inComponent:(NSInteger)component animated:(BOOL)anim
{
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return;
	// Select row
	NSInteger row = [comp indexOfDataCloser:target];
	if ( row >= 0)
		[self selectRow:row inComponent:component animated:anim];
}

// Retorna os dados de uma linha
- (NSString*)selectedRowData:(NSInteger)component
{
	// Recupera o componente
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return nil;
	// Recupera linha selecionada
	NSInteger row = [self selectedRowInComponent:component];
	// Recupera dados
	return [comp dataForRow:row];
}
- (NSString*)selectedRowText:(NSInteger)component
{
	// Recupera o componente
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return nil;
	// Recupera linha selecionada
	NSInteger row = [self selectedRowInComponent:component];
	// Recupera dados
	return [comp textForRow:row];
}




#pragma mark UIPickerViewDelegate methods

// tell the picker how many components it will have (in our case we have one component)
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger count = [components count];
    return count;//[components count];
}

// tell the picker how many rows are available for a given component (in our case we have one component)
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    AvantePickerComponent *comp = [components objectAtIndex:component];
    if (comp == nil)
        return 0;
    else
        return [comp count];
}
// tell the picker the width of each row for a given component (in our case we have one component)
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return 0;
	else
		return comp.width;
//    return 100;
}

// tell the picker the height of each row for a given component (in our case we have one component)
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    
    if( component >= [components count] )
        return 0.0;
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return 0;
	else
		return [comp smartHeight];
}



// tell the picker the title for a given component (in our case we have one component)
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return nil;
	else
		return [comp textForRow:row];
}

// tell the picker which view to use for a given component and row, we have an array of color views to show
/*
 - (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
		  forComponent:(NSInteger)component reusingView:(UIView *)view
{
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return nil;
	else
		return [comp viewForRow:row];
}
*/

// SELECIONOU ALGO...
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// Exec callback
	AvantePickerComponent *comp = [components objectAtIndex:component];
	if (comp == nil)
		return;
	// exec!
	if (comp.callback == nil)
		return;
	[parent performSelector:comp.callback];
}

#pragma mark drawRect

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
	// Draw Labels?
	if (drawLabels)
	{
		// Verifica tamanho util do picker
		AvantePickerComponent *comp;
		CGFloat wid = 0;
		for (comp in components)
			wid += comp.width;
//		if (wid > 290.0)
//			wid = 290.0;
		//AvLog(@"LABELS widComps[%f]",wid);
		// Cria os labels
		CGFloat lx = ((kscreenWidth-wid)/2.0) - 2.0;
		CGFloat h = HEIGHT_FOR_LINES(LABEL_FONT_SIZE,1);
		for (comp in components)
		{
			AvanteTextLabel *label = [[AvanteTextLabel alloc] 
					 init:comp.title 
					 x:lx 
					 y:-h 
					 w:comp.width 
					 h:h
					 size:LABEL_FONT_SIZE 
					 color:[UIColor whiteColor]];
			//label.colorShadow = [UIColor whiteColor];
			[self addSubview:label];
			[label release];
			lx += comp.width+2.0;
		}
	}
}

@end


