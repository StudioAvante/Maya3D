//
//  DateAddVC.h
//  Maya3D
//
//  Created by Roger on 14/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//


#import "DatebookVC.h"
#import "TzGlobal.h"
#import "TzCalendar.h"
#import "TzDatebook.h"
#import "DateAddVC.h"
#import "TzClock.h"

@implementation DatebookVC


#pragma mark UIPickerView - DatebookVC custom functions

- (void)dealloc
{
	[datebookPicker release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	AvLog(@"DATEBOOK_VC: viewDidLoad");
	
	// Corrige nome
	self.title = LOCAL(@"TAB_DATEBOOK");
	
	// 1a vez...
	pickedItem = -1;
		
	// HELP BUTTON
	UIBarButtonItem *but;
	but = [[UIBarButtonItem alloc]
		   initWithImage:[global imageFromFile:@"icon_info"]
		   style:UIBarButtonItemStylePlain
		   target:self action:@selector(goInfo:)];
	self.navigationItem.leftBarButtonItem = but;
	self.navigationItem.leftBarButtonItem.enabled = TRUE;
	[but release];
}


// CARREGA DATAS EM MEMORIA
- (void)viewWillAppear:(BOOL)animated
{
	// Pause Clock
	[global.theClock pause];
	// Reload!
	[datebookPicker reloadAllComponents];
}

// GO TO NEAREST POSITION
- (void)viewDidAppear:(BOOL)animated
{
	// Save Current Tab
	global.currentTab = TAB_DATEBOOK;
	global.currentVC = self;
	if (global.lastTab != TAB_DATEBOOK)
		lastTabCopy = global.lastTab;
	// Go to TODAY
	if (pickedItem == -1)
	{
		int row;
		for (row = 0 ; row < ([global.datebook count]) ; row++)
		{
			TzDate *dt = (TzDate*)[global.datebook objectAtIndex:row];
			// Se encontrou a data, usa ela
			if (dt.julian == global.cal.julian)
				break;
			// Se passou da data, usa a mais proxima
			else if (dt.julian > global.cal.julian)
			{
				// Se tem data anterior, verifica ela
				if (row)
				{
					TzDate *dtprev = (TzDate*)[global.datebook objectAtIndex:row-1];
					if ( (dtprev.julian - global.cal.julian) > (global.cal.julian - dt.julian) )
						row--;
				}
				break;
			}
		}
		pickedItem = row;
	}
	// Move Picker
	[datebookPicker selectRow:pickedItem inComponent:0 animated:YES];
	// Data selecionada
	pickedDate = (TzDate*)[global.datebook objectAtIndex:pickedItem];
}
- (void)viewDidDisappear:(BOOL)animated {
	// Save Last Tab
	global.lastTab = TAB_DATEBOOK;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// if you want to only support portrait mode, do this
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

// ROGER
// Encontra o TzDate de um componente
// Retorna -1 se nao ha elementos
- (int)elementIndex:(NSInteger)row :(NSInteger)component
{
	// Encontra celula visiveis (algumas podem estar escondidas por causa do search)
	int count = 0;
	int n;
	for (n = 0 ; n < [global.datebook count] ; n++)
	{
		TzDate *dt = (TzDate*)[global.datebook objectAtIndex:n];
		if (dt.visible == FALSE)
			continue;
		if (count == row)
			break;
		count++;
	}
	if (count == [global.datebook count])
		return -1;
	else
		return n;
}


#pragma mark UIPickerView - DatebookVC Delegate


// Quantidade de componente (colunas)
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

// Largura de cada componente (colunas)
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	//CustomView *viewToUse = [pickerViews objectAtIndex:0];
	//return viewToUse.bounds.size.width;
	return 280.0;
}

// Altura das linhas
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	//CustomView *viewToUse = [pickerViews objectAtIndex:0];
	//return viewToUse.bounds.size.height;
	return 30.0;
}

// Numero de linhas
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSInteger count = 0;
	// Ignora linhas nao visiveis
	for (int n = 0 ; n < [global.datebook count] ; n++)
	{
		TzDate *dt = (TzDate*)[global.datebook objectAtIndex:n];
		if (dt.visible)
			count++;
	}
	//AvLog(@"TZOLKIN: GET NUMBER [%d]", count);
	return count;
}

// Texto de cada linha / coluna (componente)
 - (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	// Encontra celula visiveis (algumas podem estar escondidas por causa do search)
	int n = [self elementIndex:row:component];
	if (n < 0)
		return @"...";
	// Recupera data
	TzDate *dt = (TzDate*)[global.datebook objectAtIndex:n];
	//AvLog(@"TZOLKIN: GET TZDATE[%d] *[%d] %s", n, dt, [dt.desc UTF8String]);
	// Data/celula encontrada
	return dt.desc;
}
// tell the picker which view to use for a given component and row, we have an array of color views to show
 - (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
		  forComponent:(NSInteger)component reusingView:(UIView *)view
{
	int n = [self elementIndex:row:component];
	//AvLog(@"TZOLKIN: GET VIEW row[%d] element[%d] index[%d]", row, component, n);
	if (n < 0)
		return nil;
	// Recupera data
	TzDate *dt = (TzDate*)[global.datebook objectAtIndex:n];
	CustomPickerView *viewToUse = dt.pickerView;
	//AvLog(@"TZOLKIN: GET VIEW[%d] *[%d]", n, viewToUse);
	return viewToUse;
}
// SELECIONOU ALGO...
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	int n = [self elementIndex:row:component];
	if (n < 0)
		return;
	// Data/celula encontrada
	pickedItem = [self elementIndex:row:component];
	pickedDate = (TzDate*)[global.datebook objectAtIndex:pickedItem];
	AvLog(@"TZOLKIN: SELECIONOU [%s]", [pickedDate.desc UTF8String]);
}




#pragma mark UISearchBar delegate methods

// SEARCH

// Guarda a data selecionada para voltar aqui
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	//
	return;
}
// EDITOU o searchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	AvLog(@"TZOLKIN: textDidChange [%s]", [searchText UTF8String]);
	// Se o texto esta vazio, todos sao visiveis
	if ([searchText length] == 0)
	{
		for (int n = 0 ; n < [global.datebook count] ; n++)
		{
			TzDate *dt = [global.datebook objectAtIndex:n];
			dt.visible = TRUE;
		}	
	}
	// Search Dates
	else
	{
		// Parse array
		NSArray *words = [searchText componentsSeparatedByString:@" "];
		// Serch dates
		for (int n = 0 ; n < [global.datebook count] ; n++)
		{
			TzDate *dt = [global.datebook objectAtIndex:n];
			BOOL vis = TRUE;
			for (int w = 0 ; w < [words count] ; w++)
			{
				NSString *word = [words objectAtIndex:w];
				NSRange range = [[dt.desc lowercaseString] rangeOfString:[word lowercaseString]];
				if ([word length] && range.location == NSNotFound)
				{
					vis = FALSE;
					break;
				}
			}
			//AvLog(@"TZOLKIN: SEARCH vis=[%d]", vis);
			dt.visible = vis;
		}
	}
	// Go to last date selected (or below)
	int count = 0;
	for (int row = 0 ; row < ([global.datebook count]) ; row++)
	{
		TzDate *dt = (TzDate*)[global.datebook objectAtIndex:row];
		if (dt.visible)
		{
			if (pickedDate.julian >= dt.julian)
			{
				[datebookPicker selectRow:count inComponent:0 animated:YES];
				break;
			}
			count++;
		}
	}
	// Reload picker
	[datebookPicker reloadAllComponents];
	return;
}
// Isto serve para remover o teclado quando se aperta Return no textField
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	//NSString *searchText = searchBar.text;
	//AvLog(@"TZOLKIN: searchBarTextDidEndEditing=%s", [searchText UTF8String]);
	[searchBar resignFirstResponder];
	return;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	return;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	return;
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	return;
}


#pragma mark ACTIONS

// Info page
- (IBAction)goInfo:(id)sender {
	[global goInfo:INFO_DATEBOOK vc:self];
}
// SELECT
- (IBAction)selectDate:(id)sender {	
	// Seleciona a data atual como data corrente
	if (pickedDate)
		[global.cal updateWithJulian:pickedDate.julian];
	// Volta a tela anterior
	//[[self navigationController] popViewControllerAnimated:YES];
	self.tabBarController.selectedIndex = lastTabCopy;
}
// EDIT
- (IBAction)editDate:(id)sender {
	// Verifica se eh data fixa
	AvLog(@"EDIT fixed=%d",pickedDate.fixed);
	if (pickedDate.fixed)
	{
		[global alertSimple:LOCAL(@"CANT_EDIT_FIXED")];
		return;
	}
	// Chama a view de edicao
	DateAddVC *vc = [[DateAddVC alloc] initEditItem:pickedItem];
	vc.title = LOCAL(@"DATE_EDIT");
	vc.hidesBottomBarWhenPushed  = YES;
	[[self navigationController] pushViewController:vc animated:YES];
	[vc release];
}
// DELETE
- (IBAction)removeDate:(id)sender {
	// Verifica se eh data fixa
	
	AvLog(@"DELETE fixed=%d",pickedDate.fixed);
	if (pickedDate.fixed)
	{
		[global alertSimple:LOCAL(@"CANT_DELETE_FIXED")];
		return;
	}
	// Confirma
	[global alertYesNo:LOCAL(@"DATE_DELETE_CONFIRM") delegate:self];
}

#pragma mark alertView Delegate

// DELETE RESPONSE
// UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)i
{
	AvLog(@"BUTTON PRESSED=%d",i);
	// Cancel?
	if (i == 0)
		return;
	
	// Remove!
	AvLog(@"REMOVE ITEM [%d]",pickedItem);
	[global.datebook removeItem:pickedItem];
	[global.datebook debugList];
	[global.datebook saveToXML];
	if ([global.datebook saveToXML] == FALSE)
	{
		// ERRO! Insere a data novamente no datebook
		[global alertSimple:LOCAL(@"DATE_DELETE_ERROR")];
		[global.datebook addDate:pickedDate];
		return;
	}
	
	// Seleciona proximo
	pickedDate = (TzDate*)[global.datebook objectAtIndex:pickedItem];
	// Reload!
	[datebookPicker reloadAllComponents];
}



@end


