//
//  AvanteRollerVertical.m
//  Maya3D
//
//  Created by Roger on 16/12/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "AvanteRollerVertical.h"
#import "Tzolkin.h"
#import "TzGlobal.h"

#define CELL_NUM			600.0
#define CELL_WIDTH			30.0
#define CELL_HEIGHT			kRollerVerticalHeight
#define CONTENTS_WIDTH		(CELL_NUM * CELL_WIDTH)

@implementation AvanteRollerVertical

- (void)dealloc {
	//[scrollView removeFromSuperview];
    [super dealloc];
}

- (id)init:(CGFloat)x :(CGFloat)y
{
	UIImageView *imgView;
	UIImage *image;
	
	// Init View
	CGRect frame = CGRectMake(x, y, kscreenWidth, CELL_HEIGHT);
    if ((self = [super initWithFrame:frame]) == nil)
		return nil;
	//self.bounds = frame;
	self.userInteractionEnabled = YES;

	// Roller cells
	frame = CGRectMake(0.0, 0.0, kscreenWidth, CELL_HEIGHT);
	scrollView = [[UIScrollView alloc] initWithFrame:frame];
	scrollView.delegate = self;
	scrollView.userInteractionEnabled = YES;
	
	scrollView.contentSize = CGSizeMake(CONTENTS_WIDTH, CELL_HEIGHT);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
	
	// Roller
	image = [global imageFromFile:@"roller_cell"];
	for ( CGFloat n = 0 ; n < CELL_NUM ; n++ )
	{
		frame = CGRectMake( (n*CELL_WIDTH), 0.0, CELL_WIDTH, CELL_HEIGHT);
		imgView = [[UIImageView alloc] initWithImage:image];
		imgView.frame = frame;
		[scrollView addSubview:imgView];
		[imgView release];
	}
	[self addSubview:scrollView];
	[scrollView release];
	
	// Top
	image = [global imageFromFile:@"roller_top"];
	frame = CGRectMake(0.0, 0.0, kscreenWidth, CELL_HEIGHT);
	imgView = [[UIImageView alloc] initWithImage:image];
	imgView.frame = frame;
	[self addSubview:imgView];
	[imgView release];
	
	// Posiciona no meio do scrollView
	[self scrollBackToCenter];

	// Finito.
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
}

// Adiciona callback
- (void)addCallback:(id)obj dragLeft:(SEL)left dragRight:(SEL)right
{
	dragCallbackObj = obj;
	dragCallbackLeft = left;
	dragCallbackRight = right;
}
// Volta para o centro
- (void)scrollBackToCenter
{
	CGPoint off = scrollView.contentOffset;
	off.x = (CONTENTS_WIDTH / 2) + (((NSInteger)off.x) % ((NSInteger)CELL_WIDTH));
	lastCell = (NSInteger) ( off.x / CELL_WIDTH );
	//AvLog(@"SCROLL: BACK x[%f] lastCell[%d]",off.x, lastCell);
	scrollView.contentOffset = off;
	// Marca esta celula como a ultima
}


#pragma mark UIScrollViewDelegate

// mexeu!
- (void)scrollViewDidScroll:(UIScrollView *)view
{
	// Verifica se mudou de celula
	CGPoint off = scrollView.contentOffset;
	NSInteger cell = (NSInteger) ( off.x / CELL_WIDTH );
	//AvLog(@"SCROLL: scrollViewDidScroll x[%f] lastCell[%d] cell[%d]",off.x, lastCell, cell);
	if ( cell < lastCell)
	{
		[dragCallbackObj performSelector:dragCallbackRight];
		lastCell = cell;
	}
	else if ( cell > lastCell )
	{
		[dragCallbackObj performSelector:dragCallbackLeft];
		lastCell = cell;
	}
}
// PARAAAA!!!
- (void)stop
{
	// manda para onde esta agora, sem animacao
	[scrollView setContentOffset:scrollView.contentOffset animated:NO];
}

// Quando parar de mexer, volta ao centro
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self scrollBackToCenter];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self scrollBackToCenter];
}

@end
