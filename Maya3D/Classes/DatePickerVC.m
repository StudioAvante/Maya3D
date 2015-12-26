//
//  DatePickerVC.m
//  Maya3D
//
//  Created by Roger on 27/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "DatePickerVC.h"
#import "Tzolkin.h"
#import "TzGlobal.h"
#import "TzCalendar.h"
#import "AvantePicker.h"
#import "AvantePickerImage.h"
#import "AvanteTextLabel.h"
#import "AvanteMayaNum.h"

@implementation DatePickerVC

// DESTRUCTOR
- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// CONSTRUCTOR
- (id)initWithType:(int)t
{
	// Suuuper
    if ((self = [super initWithNibName:@"TzFullView" bundle:nil]) == nil)
		return nil;
	
	// misc
	UIToolbar *toolBar;
	CGRect frame;
	CGFloat y = 0.0;
	
    y = 20+44;
	// Create Tool Bar estetico para o label
	frame = CGRectMake(0.0, y, kscreenWidth, kToolbarHeight);
	toolBar = [[UIToolbar alloc] initWithFrame:frame];
	toolBar.barStyle = UIBarStyleBlackOpaque;
	[self.view addSubview:toolBar];
	[toolBar release];
	
	// Create Label
	//frame = CGRectMake(0.0, 0.0, kscreenWidth, kToolbarHeight);
    frame = CGRectMake(0.0, y + 0.0, kscreenWidth, kToolbarHeight);
	descLabel = [[AvanteTextLabel alloc] init:@"" frame:frame size:22.0 color:[UIColor whiteColor]];
	[descLabel setNavigationBarStyle];
	[self.view addSubview:descLabel];
	[descLabel release];
	y+= kToolbarHeight;
	
	// Cria picker correto
	type = t;
	// Cria picker correto
	if ( type == DATE_PICKER_GREGORIAN )
	{
		y += 30.0;	// 12.0 //Labels
		self.title = LOCAL(@"GREGORIAN_PICKER");
		gregPicker = [[AvantePicker alloc] init:0.0 y:y labels:YES];
		[self initGregPicker];
		currentPicker = gregPicker;
	}
	else if ( type == DATE_PICKER_JULIAN )
	{
		self.title = LOCAL(@"JULIAN_PICKER");
		julianPicker = [[AvantePicker alloc] init:0.0 y:y labels:NO];
		[self initJulianPicker];
		currentPicker = julianPicker;
	}
	else 	if ( type == DATE_PICKER_LONG_COUNT && global.prefNumbering == NUMBERING_123 )
	{
		y += 30.0;	// 12.0 //Labels
		self.title = LOCAL(@"LONG_COUNT_PICKER");
		longCountPicker = [[AvantePicker alloc] init:0.0 y:y labels:YES];
		[self initLongCountPicker];
		currentPicker = longCountPicker;
	}
	else if ( type == DATE_PICKER_LONG_COUNT && global.prefNumbering == NUMBERING_MAYA )
	{
        y += 30.0; //12.0;	// Labels
		self.title = LOCAL(@"LONG_COUNT_PICKER");
		longCountMayaPicker = [[AvantePickerImage alloc] init:0.0 y:y labels:YES];
		[self initLongCountMayaPicker];
		currentPicker = longCountMayaPicker;
	}
	else
	{
		AvLog(@"INVALID PICKER TYPE [%d]",type);
		return nil;
	}
	//AvLog(@"PICKER Type [%d] [%@] retain[%d]",type,self.title,[currentPicker retainCount]);

	// Add picker
	[self.view addSubview:currentPicker];
	[currentPicker release];
	y += currentPicker.frame.size.height;
	
	// Create ToolBar Items
	// FLEX
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    flex.tintColor = [UIColor whiteColor];
	// TODAY button
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc]
									initWithTitle:LOCAL(@"TODAY_BUTTON")
									style:UIBarButtonItemStyleBordered
									target:self action:@selector(actionToday:)];
    
    [todayButton setTintColor:[UIColor whiteColor]];
	// SELECT button
    UIBarButtonItem *selectButton = [[UIBarButtonItem alloc]
									 initWithTitle:LOCAL(@"SELECT")
									 style:UIBarButtonSystemItemDone
									 target:self action:@selector(actionSelect:)];
    
    [selectButton setTintColor:[UIColor whiteColor]];
	selectButton.style = UIBarButtonItemStyleDone;
	// Add Itens To Toolbar
	NSArray *items = [NSArray arrayWithObjects: flex, todayButton, flex, selectButton, flex, nil];
	[flex release];
	[todayButton release];
	[selectButton release];
	
	// Create the Tool Bar
	frame = CGRectMake(0.0, y, kscreenWidth, kToolbarHeight);
	toolBar = [[UIToolbar alloc] initWithFrame:frame];
	toolBar.barStyle = UIBarStyleBlackOpaque;
	[toolBar setItems:items animated:NO];
	//[items release];	// nao precisa poris NSArray nao tem alloc
	// Add ToobBar to main view
	[self.view addSubview:toolBar];
	[toolBar release];
	y+= kToolbarHeight;

    //////////////////////
    // YEAR/CENTURY Label 1
    
    if ( type == DATE_PICKER_GREGORIAN )
    {
        AvanteTextLabel *label;
        
        //   y+= 15;
        CGFloat y1 = y;
        
        
        y+= 40;
        label = [[AvanteTextLabel alloc] init:LOCAL(@"CENTURY_PS1")
                                            x:0.0 y:y w:kscreenWidth h:12.0 size:12.0 color:[UIColor whiteColor]];
        [self.view addSubview:label];
        [label release];
        // YEAR/CENTURY Label 2
        y += 14.0;
        label = [[AvanteTextLabel alloc] init:LOCAL(@"CENTURY_PS2")
                                            x:0.0 y:y w:kscreenWidth h:12.0 size:12.0 color:[UIColor whiteColor]];
        [self.view addSubview:label];
        [label release];
        
        // YEAR/CENTURY help
#ifndef LITE
        UIButton *yearInfo = [UIButton buttonWithType:UIButtonTypeInfoLight];
        
        float x = 275.0 * kscreenWidth / 320;
        yearInfo.frame = CGRectMake(x, y1+40, 25.0, 25.0);
        yearInfo.backgroundColor = [UIColor clearColor];
        yearInfo.tintColor = [UIColor whiteColor];
        [yearInfo setImage:[global imageFromFile:@"icon_info2"] forState:UIControlStateNormal];
        [yearInfo addTarget:self action:@selector(infoGreg:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:yearInfo];
#endif
    
    }

    //////////////////////
    
    
	// Finito
	return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithTitle:self.prevTitle style:UIBarButtonItemStyleDone target:self action:@selector(goPrev:)];
    [but setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = but;
    self.navigationItem.leftBarButtonItem.enabled = TRUE;
    [but release];
    
}

-(IBAction)goPrev:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
	// Title
	[self navigationController].navigationBar.topItem.title = self.title;
	// Seleciona valores correntes
	[self goToDate:global.cal];
	// Zera os segundos atuais
	secs = 0.0;
}
- (void)viewWillDisappear
{
	[timer1 release];
	[timer2 release];
	[timer3 release];
	[timer4 release];
	[timer5 release];
}





//
// DATE_PICKER_GREGORIAN
//
- (void)initGregPicker
{
	AvanteTextLabel *label;
	NSString *str, *dt;
	CGFloat y;
	int n, comp;
	
//	// YEAR/CENTURY Label 1
//	y = (self.view.frame.size.height - 35.0);
//    
//    y+= 50;
//	label = [[AvanteTextLabel alloc] init:LOCAL(@"CENTURY_PS1") 
//											x:0.0 y:y w:kscreenWidth h:12.0 size:12.0 color:[UIColor whiteColor]];
//	[self.view addSubview:label];
//	[label release];
//	// YEAR/CENTURY Label 2
//	y += 14.0;
//	label = [[AvanteTextLabel alloc] init:LOCAL(@"CENTURY_PS2") 
//											x:0.0 y:y w:kscreenWidth h:12.0 size:12.0 color:[UIColor whiteColor]];
//	[self.view addSubview:label];
//	[label release];
//	
//	// YEAR/CENTURY help
//#ifndef LITE
//	UIButton *yearInfo = [UIButton buttonWithType:UIButtonTypeInfoLight];
//    
//    float x = 275.0 * kscreenWidth / 320;
//	yearInfo.frame = CGRectMake(x, 430.0, 25.0, 25.0);
//	yearInfo.backgroundColor = [UIColor clearColor];
//    yearInfo.tintColor = [UIColor whiteColor];
//	[yearInfo setImage:[global imageFromFile:@"icon_info2"] forState:UIControlStateNormal];
//	[yearInfo addTarget:self action:@selector(infoGreg:) forControlEvents:UIControlEventTouchUpInside];	
//	[self.view addSubview:yearInfo];
//#endif
	
	// Monta D-M ou M-D ???
	for ( comp = 0 ; comp <= 1 ; comp++)
	{
		if ( (comp == 0 && global.prefDateFormat == GREG_DMY) || (comp == 1 && global.prefDateFormat == GREG_MDY))
		{
			// Day
			compDay = comp;
			[gregPicker addComponent:LOCAL(@"DAY") w:40];
			[gregPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
			for ( n = 1 ; n <= 31 ; n++ )
			{
				str = [NSString stringWithFormat:@"%d",n];
				[gregPicker addRowToComponent:comp text:str];
			}
		}
		else
		{
			// Month
			compMonth = comp;
			[gregPicker addComponent:LOCAL(@"MONTH") w:140];
			[gregPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
			for ( n = 1 ; n <= 12 ; n++ )
			{
				NSString *dt = [NSString stringWithFormat:@"%d",n];
				str = [TzCalGreg constNameOfMonth:n];
				[gregPicker addRowToComponent:comp text:str data:dt];
			}
		}
	}
	// Year
	//comp++;
	[gregPicker addComponent:LOCAL(@"YEAR_STAR") w:70];
	[gregPicker addComponentCallback:comp :self :@selector(didChangeYear)];
	for ( n = -3113 ; n <= 4772 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[gregPicker addRowToComponent:comp text:str];
	}
	// Century
	comp++;
	[gregPicker addComponent:LOCAL(@"CENTURY") w:50];
	[gregPicker addComponentCallback:comp :self :@selector(didChangeCentury)];
	for ( n = -31 ; n <= 48 ; n++ )
	{
		dt = [NSString stringWithFormat:@"%d",n];
		str = [NSString stringWithFormat:@"%d",n];
		[gregPicker addRowToComponent:comp text:str data:dt];
	}
}

//
// DATE_PICKER_JULIAN
//
- (void)initJulianPicker
{
	int n, col, comp;
	NSString *str;
	
	// Cria um slider para cada digito
	for ( col = 7 ; col >= 1 ; col-- )
	{
		comp = (7-col);
		str = [NSString stringWithFormat:@"n%d",col];
		[julianPicker addComponent:str w:35];
		[julianPicker addComponentCallback:comp:self:@selector(didChangeAnything)];
		for ( n = 0 ; n <= 9 ; n++ )
		{
			str = [NSString stringWithFormat:@"%d",n];
			[julianPicker addRowToComponent:comp text:str];
		}
	}
}

//
// DATE_PICKER_LONG_COUNT - 123
//
- (void)initLongCountPicker
{
	int n, comp;
	NSString *str;
	
	// BAKTUN
	comp = 0;
	[longCountPicker addComponent:LOCAL(@"LONG_BAKTUN") w:50];
	[longCountPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 20 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[longCountPicker addRowToComponent:comp text:str];
	}
	// KATUN
	comp++;
	[longCountPicker addComponent:LOCAL(@"LONG_KATUN") w:50];
	[longCountPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 20 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[longCountPicker addRowToComponent:comp text:str];
	}
	// TUN
	comp++;
	[longCountPicker addComponent:LOCAL(@"LONG_TUN") w:50];
	[longCountPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 20 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[longCountPicker addRowToComponent:comp text:str];
	}
	// UINAL
	comp++;
	[longCountPicker addComponent:LOCAL(@"LONG_UINAL") w:50];
	[longCountPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 18 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[longCountPicker addRowToComponent:comp text:str];
	}
	// KIN
	comp++;
	[longCountPicker addComponent:LOCAL(@"LONG_KIN") w:50];
	[longCountPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 20 ; n++ )
	{
		str = [NSString stringWithFormat:@"%d",n];
		[longCountPicker addRowToComponent:comp text:str];
	}
}

//
// DATE_PICKER_LONG_COUNT - MAYA
//
- (void)initLongCountMayaPicker
{
	int n, comp;
	NSString *dt;
	AvanteMayaNum *mayaView;
	
	// BAKTUN
	comp = 0;
	[longCountMayaPicker addComponent:LOCAL(@"LONG_BAKTUN") w:50 h:40];
	[longCountMayaPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 20 ; n++ )
	{
		dt = [NSString stringWithFormat:@"%d", n];
		mayaView = [[AvanteMayaNum alloc] init:n x:0.0 y:0.0 size:IMAGE_SIZE_BIG];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE_BIG, IMAGE_SIZE_BIG)];
//        [view addSubview:mayaView];
////		[longCountMayaPicker addRowToComponent:comp view:mayaView data:dt];
//        [longCountMayaPicker addRowToComponent:comp view:view data:dt];
        
        [longCountMayaPicker addRowToComponent:comp imageName:mayaView.imageName data:dt];
		[mayaView release];
//        [view release];
        
	}
	// KATUN
	comp++;
	[longCountMayaPicker addComponent:LOCAL(@"LONG_KATUN") w:50 h:40];
	[longCountMayaPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 20 ; n++ )
	{
		dt = [NSString stringWithFormat:@"%d",n];
        
		mayaView = [[AvanteMayaNum alloc] init:n x:0.0 y:0.0 size:IMAGE_SIZE_BIG];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE_BIG, IMAGE_SIZE_BIG)];
//        [view addSubview:mayaView];
//        
//		[longCountMayaPicker addRowToComponent:comp view:view data:dt];
        [longCountMayaPicker addRowToComponent:comp imageName:mayaView.imageName data:dt];
        [mayaView release];
//        [view release];
	}
    
	// TUN
	comp++;
	[longCountMayaPicker addComponent:LOCAL(@"LONG_TUN") w:50 h:40];
	[longCountMayaPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 20 ; n++ )
	{
		dt = [NSString stringWithFormat:@"%d",n];
		mayaView = [[AvanteMayaNum alloc] init:n x:0.0 y:0.0 size:IMAGE_SIZE_BIG];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE_BIG, IMAGE_SIZE_BIG)];
//        [view addSubview:mayaView];
//
//		[longCountMayaPicker addRowToComponent:comp view:view data:dt];
        [longCountMayaPicker addRowToComponent:comp imageName:mayaView.imageName data:dt];
        [mayaView release];
//        [view release];
	}
	// UINAL
	comp++;
	[longCountMayaPicker addComponent:LOCAL(@"LONG_UINAL") w:50 h:40];
	[longCountMayaPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 18 ; n++ )
	{
		dt = [NSString stringWithFormat:@"%d",n];
		mayaView = [[AvanteMayaNum alloc] init:n x:0.0 y:0.0 size:IMAGE_SIZE_BIG];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE_BIG, IMAGE_SIZE_BIG)];
//        [view addSubview:mayaView];
//
//		[longCountMayaPicker addRowToComponent:comp view:view data:dt];
        [longCountMayaPicker addRowToComponent:comp imageName:mayaView.imageName data:dt];
        [mayaView release];
        //[view release];
	}
	// KIN
	comp++;
	[longCountMayaPicker addComponent:LOCAL(@"LONG_KIN") w:50 h:40];
	[longCountMayaPicker addComponentCallback:comp :self :@selector(didChangeAnything)];
	for ( n = 0 ; n < 20 ; n++ )
	{
		dt = [NSString stringWithFormat:@"%d",n];
		mayaView = [[AvanteMayaNum alloc] init:n x:0.0 y:0.0 size:IMAGE_SIZE_BIG];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE_BIG, IMAGE_SIZE_BIG)];
//        [view addSubview:mayaView];

//		[longCountMayaPicker addRowToComponent:comp view:view data:dt];
        [longCountMayaPicker addRowToComponent:comp imageName:mayaView.imageName data:dt];
        [mayaView release];
  //      [view release];
	}
}


#pragma mark TODAY

// Go to TODAY
- (void)goToDate:(TzCalendar*)cal
{
	// Seleciona valores correntes
	if ( type == DATE_PICKER_GREGORIAN )
	{
		NSString *d = [NSString stringWithFormat:@"%d",cal.greg.day];
		NSString *m = [NSString stringWithFormat:@"%d",cal.greg.month];
		NSString *y = [NSString stringWithFormat:@"%d",cal.greg.year];
		[currentPicker selectRowWithData:d inComponent:compDay animated:NO];
		[currentPicker selectRowWithData:m inComponent:compMonth animated:NO];
		[currentPicker selectRowWithData:y inComponent:2 animated:NO];
		[self didChangeYear:cal.greg.year];
	}
	else if ( type == DATE_PICKER_JULIAN )
	{
		int j = cal.julian;
		NSString *n1 = [NSString stringWithFormat:@"%d", ( j % 10 ) ];
		NSString *n2 = [NSString stringWithFormat:@"%d", ( j % 100 / 10 ) ];
		NSString *n3 = [NSString stringWithFormat:@"%d", ( j % 1000 / 100 ) ];
		NSString *n4 = [NSString stringWithFormat:@"%d", ( j % 10000 / 1000 ) ];
		NSString *n5 = [NSString stringWithFormat:@"%d", ( j % 100000 / 10000 ) ];
		NSString *n6 = [NSString stringWithFormat:@"%d", ( j % 1000000 / 100000 ) ];
		NSString *n7 = [NSString stringWithFormat:@"%d", ( j % 10000000 / 1000000 ) ];
		[currentPicker selectRowWithData:n7 inComponent:0 animated:YES];
		[currentPicker selectRowWithData:n6 inComponent:1 animated:YES];
		[currentPicker selectRowWithData:n5 inComponent:2 animated:YES];
		[currentPicker selectRowWithData:n4 inComponent:3 animated:YES];
		[currentPicker selectRowWithData:n3 inComponent:4 animated:YES];
		[currentPicker selectRowWithData:n2 inComponent:5 animated:YES];
		[currentPicker selectRowWithData:n1 inComponent:6 animated:YES];
	}
	else if ( type == DATE_PICKER_LONG_COUNT )
	{
		[currentPicker selectRow:cal.longCount.baktun	inComponent:0 animated:YES];
		[currentPicker selectRow:cal.longCount.katun	inComponent:1 animated:YES];
		[currentPicker selectRow:cal.longCount.tun		inComponent:2 animated:YES];
		[currentPicker selectRow:cal.longCount.uinal	inComponent:3 animated:YES];
		[currentPicker selectRow:cal.longCount.kin		inComponent:4 animated:YES];
	}
	
	// Programa atualizacao do label apos animacoes terminarem
	if (type != DATE_PICKER_GREGORIAN)
	{
		timer1 = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateLabel:) userInfo:nil repeats:NO];
		timer2 = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateLabel:) userInfo:nil repeats:NO];
		timer3 = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateLabel:) userInfo:nil repeats:NO];
		timer4 = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(updateLabel:) userInfo:nil repeats:NO];
		timer5 = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateLabel:) userInfo:nil repeats:NO];
	}
}



#pragma mark USER ACTIONS

// Mudou ano > Atualiza seculo
- (void) didChangeYear
{
	int year = (int)[[currentPicker selectedRowData:2] integerValue];
	[self didChangeYear:year];
}
- (void) didChangeYear:(int)year
{
	NSString *century;
	if ( year >= 0 )
		century = [NSString stringWithFormat:@"%d", ((year/100)+1) ];
	else
		century = [NSString stringWithFormat:@"%d", (year/100) ];
	//AvLog(@"DID CHANGE YEAR y[%d] c[%@]", year, century);
	[currentPicker selectRowWithData:century inComponent:3 animated:FALSE];
	// Atualiza desc
	[self didChangeAnything];
}
// Mudou Seculo > Atualiza Ano
- (void) didChangeCentury
{
	int century = (int)[[currentPicker selectedRowData:3] integerValue];
	NSString *year;
	if ( century > 0 )
		year = [NSString stringWithFormat:@"%d", ((century-1)*100) ];
	else if ( century == 0 )
		year = [NSString stringWithFormat:@"%d", (-1) ];
	else
		year = [NSString stringWithFormat:@"%d", (century*100) ];
	AvLog(@"DID CHANGE CENTURY c[%d] y[%@]", century, year);
	[currentPicker selectRowWithData:year inComponent:2 animated:FALSE];
	// Atualiza desc
	[self didChangeAnything];
}

// User interacted
- (void)didChangeAnything
{
	// Zera segundos
	secs = 0.0;

	// Update pickers
	[self updateLabel];
}

// Update Pickers
- (void)updateLabel:(NSTimer*)theTimer
{
	[self updateLabel];
}
- (void)updateLabel
{
	NSString *str;
	BOOL valid = 0;
	
	// Usa data selecionada
	if ( type == DATE_PICKER_GREGORIAN )
	{
		NSInteger d = [[currentPicker selectedRowData:compDay] integerValue];
		NSInteger m = [[currentPicker selectedRowData:compMonth] integerValue];
		NSInteger y = [[currentPicker selectedRowData:2] integerValue];
		str = [TzCalGreg makeDayNameShort:(int)d:(int)m:(int)y];
		valid = [TzCalGreg validateGreg:(int)d:(int)m:(int)y];
	}
	else if ( type == DATE_PICKER_JULIAN )
	{
		NSInteger n7 = [[currentPicker selectedRowData:0] integerValue];
		NSInteger n6 = [[currentPicker selectedRowData:1] integerValue];
		NSInteger n5 = [[currentPicker selectedRowData:2] integerValue];
		NSInteger n4 = [[currentPicker selectedRowData:3] integerValue];
		NSInteger n3 = [[currentPicker selectedRowData:4] integerValue];
		NSInteger n2 = [[currentPicker selectedRowData:5] integerValue];
		NSInteger n1 = [[currentPicker selectedRowData:6] integerValue];
		int j = (int)(n1 + n2*10 + n3*100 + n4*1000 + n5*10000 + n6*100000 + n7*1000000);
		str = [NSString stringWithFormat:@"%07d",j];
		valid = [global.cal validateJulian:j];
	}
	else if ( type == DATE_PICKER_LONG_COUNT )
	{
		NSInteger b = [[currentPicker selectedRowData:0] integerValue];
		NSInteger k = [[currentPicker selectedRowData:1] integerValue];
		NSInteger t = [[currentPicker selectedRowData:2] integerValue];
		NSInteger u = [[currentPicker selectedRowData:3] integerValue];
		NSInteger i = [[currentPicker selectedRowData:4] integerValue];
		str = [NSString stringWithFormat:@"%d.%d.%d.%d.%d",(int)b,(int)k,(int)t,(int)u,(int)i];
	}
	
	// Atualiza label
	if (valid != 0)
		[descLabel update:str color:[UIColor redColor]];
	else
		[descLabel update:str color:[UIColor whiteColor]];
}


#pragma mark ACTIONS

//
// GO TO TODAY
//
- (void)actionToday:(id)sender
{
	TzCalendar *today = [[TzCalendar alloc] initWithToday];
	[self goToDate:today];
	secs = (int)today.secs;
	AvLog(@"TODAY SECS [%d]",secs);
	[today release];
}

//
// SELECT DATE
//
- (void)actionSelect:(id)sender
{
	int valid = 0;
	
	// Usa data selecionada
	if ( type == DATE_PICKER_GREGORIAN )
	{
		NSInteger d = [[currentPicker selectedRowData:compDay] integerValue];
		NSInteger m = [[currentPicker selectedRowData:compMonth] integerValue];
		NSInteger y = [[currentPicker selectedRowData:2] integerValue];
		valid = [global.cal updateWithGreg:(int)d:(int)m:(int)y];
		AvLog(@"PICKED GREG [%02d-%02d-%03d] valid[%d]",d,m,y,valid);
	}
	else if ( type == DATE_PICKER_JULIAN )
	{
		NSInteger n7 = [[currentPicker selectedRowData:0] integerValue];
		NSInteger n6 = [[currentPicker selectedRowData:1] integerValue];
		NSInteger n5 = [[currentPicker selectedRowData:2] integerValue];
		NSInteger n4 = [[currentPicker selectedRowData:3] integerValue];
		NSInteger n3 = [[currentPicker selectedRowData:4] integerValue];
		NSInteger n2 = [[currentPicker selectedRowData:5] integerValue];
		NSInteger n1 = [[currentPicker selectedRowData:6] integerValue];
		int j = (int)(n1 + n2*10 + n3*100 + n4*1000 + n5*10000 + n6*100000 + n7*1000000);
		valid = [global.cal updateWithJulian:j];
		AvLog(@"PICKED JULIAN [%07d] valid[%d]",j,valid);
	}
	else if ( type == DATE_PICKER_LONG_COUNT )
	{
		valid = [global.cal updateWithMaya
				 :(int)[[currentPicker selectedRowData:0] integerValue]
				 :(int)[[currentPicker selectedRowData:1] integerValue]
				 :(int)[[currentPicker selectedRowData:2] integerValue]
				 :(int)[[currentPicker selectedRowData:3] integerValue]
				 :(int)[[currentPicker selectedRowData:4] integerValue] ];
		AvLog(@"PICKED LONG COUNT valid[%d]",valid);
	}
	
	// Atualiza segundos, se houver
	// Remove meio dia, pois a data padrao se inicias as 12hs
	if (secs)
	{
		AvLog(@"SET SECS [%d]",secs);
		[global.cal addSeconds:(double)(secs)-(SECONDS_PER_DAY/2.0)];
	}
	
	// Data valida?
	if (valid <= -2)
	{
		[global alertSimple:LOCAL(@"INVALID_DATE")];
		return;
	}
	else if (valid < 0)
	{
		[global alertSimple:LOCAL(@"DATE_TOO_LOW")];
		return;
	}
	else if (valid > 0)
	{
		[global alertSimple:LOCAL(@"DATE_TOO_HIGH")];
		return;
	}
	// OK! - Volta para View anterior
	[[self navigationController] popViewControllerAnimated:YES];
}

//
// INFO ACTIONS
//
- (IBAction)infoGreg:(id)sender {
	[global goInfo:INFO_GREGORIAN vc:self];
}


@end
