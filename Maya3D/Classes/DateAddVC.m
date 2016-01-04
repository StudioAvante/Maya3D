//
//  DateAddVC.m
//  Maya3D
//
//  Created by Roger on 14/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import "DateAddVC.h"
#import "TzGlobal.h"
#import "TzCalendar.h"
#import "TzDatebook.h"


@implementation DateAddVC

@synthesize descField;
@synthesize dateField;
@synthesize noteField;

// Destructor
- (void)dealloc {
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    TzDate *date = [[TzDate alloc] initJulian:julian];
    
    // Atualiza UI
    //[dateField update:date.greg.dayNameFull];
    dateField.text = date.greg.dayNameFull;
    noteField.text = LOCAL(@"ENTER_DESCRIPTION");
    descField.text = date.text;
    
    [date release];
}
//
// EDIT
//
// Chamado quando eh EDICAO
- (id)initAddItem:(int)j
{
	// Inikt with NIB file
	if ((self = [super initWithNibName:@"TzDateAddView" bundle:nil]) == nil)
		return nil;
	
	// Setup
	[self setup];
	
	// Cria data se ja nao foi criada
	editItem = -1;
	julian = j;
	TzDate *date = [[TzDate alloc] initJulian:julian];
	
	// Atualiza UI
	//[dateField update:date.greg.dayNameFull];
//    dateField.text = date.greg.dayNameFull;
	// release
	[date release];

	// finito!
	return self;
}

//
// EDIT
//
// Chamado quando eh EDICAO
- (id)initEditItem:(int)i
{
	// Inikt with NIB file
	if ((self = [super initWithNibName:@"TzDateAddView" bundle:nil]) == nil)
		return nil;
	
	// Setup
	[self setup];
	
	// Recupera data do DATEBOOK para EDICAO
	editItem = i;
	TzDate *date = (TzDate*) [global.datebook objectAtIndex:editItem];
	
	// Atuializa UI
	//[dateField update:date.greg.dayNameFull];
    dateField.text = date.greg.dayNameFull;
	descField.text = date.text;
	//AvLog(@"EDIT desc[%@]", date.text);

	// ok!
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)setup
{
	// Ajusta tamanho da fonte
	descField.font = [UIFont systemFontOfSize:16.0];
	descField.clearsOnBeginEditing = NO;
	
    
	// Data e hora atual
//	CGRect frame;
//	frame = CGRectMake(0.0, 64+10.0, kscreenWidth, 24.0);
//	dateField = [[AvanteTextLabel alloc] init:@"gregname" frame:frame size:20.0 color:[UIColor whiteColor]];
//	//[dateField setNavigationBarStyle];
//	[self.view addSubview:dateField];
//	[dateField release];
//
//	// Prompt
//	frame = CGRectMake(0.0, 64 + 38.0, kscreenWidth, 24.0);
//	AvanteTextLabel *label = [[AvanteTextLabel alloc] init:LOCAL(@"ENTER_DESCRIPTION") frame:frame size:14.0 color:[UIColor whiteColor]];
//	[self.view addSubview:label];
//	[label release];
    noteField.text = LOCAL(@"ENTER_DESCRIPTION");
////
//    frame = descField.frame;
//    frame.origin.y = 104.0;
//    [descField setFrame:frame];
    
}


//
// ADD
//
// Go to today
- (void)viewWillAppear:(BOOL)animated
{
	// Dá foco a descricao
	[descField becomeFirstResponder];
    
    UIBarButtonItem *but;
    but = [[UIBarButtonItem alloc] initWithTitle:self.prevTitle style:UIBarButtonItemStylePlain target:self action:@selector(goPrev:)];
    
    [but setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = but;
    self.navigationItem.leftBarButtonItem.enabled = TRUE;
    [but release];

}

- (IBAction)goPrev:(id)sender  
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

// Isto serve para remover o teclado quando se aperta Return no textField
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	//[dateField resignFirstResponder];
	AvLog(@"RETURN");
	return [self saveDate];
}

#pragma mark ROGER


// ROGER
- (IBAction)done:(id)sender {
	[self saveDate];
}
- (BOOL) saveDate {
	// Description needed please!
	if ([descField.text length] == 0)
	{
		[global alertSimple:LOCAL(@"DATE_DESC_PLEASE")];
		return FALSE;
	}
	// SAVE
	//[date setDescription:descField.text];
	if (editItem >= 0)
	{
		// EDIT!
		[global.datebook updateDate:editItem :descField.text];
		// Save!
		if ([global.datebook saveToXML] == TRUE)
			[global alertSimple:LOCAL(@"DATE_EDITED")];
		else
			[global alertSimple:LOCAL(@"DATE_EDIT_ERROR")];
	}
	else
	{
		// ADD NEW DATE
		TzDate *newDate = [[TzDate alloc] initJulian:julian :descField.text];
		newDate.fixed = FALSE;
		newDate.pickerView.highlighted = TRUE;
		[global.datebook addDate:newDate];
		[newDate release];
		// Save!
		if ([global.datebook saveToXML] == TRUE)
			[global alertSimple:LOCAL(@"DATE_ADDED")];
		else
			[global alertSimple:LOCAL(@"DATE_ADD_ERROR")];
	}
	// OK! - Volta para View anterior
	[[self navigationController] popViewControllerAnimated:YES];
	return TRUE;
}

@end
