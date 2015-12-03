//
//  DateAddVC.h
//  Maya3D
//
//  Created by Roger on 14/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "Tzolkin.h"
#import "TzDate.h"
#import "CustomPickerView.h"


@interface DatebookVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate>
{
	int lastTabCopy;
	// Picked date on picker
	int				pickedItem;
	TzDate			*pickedDate;
	// Picker
	UIPickerView	*datebookPicker;
}


// ROGER
- (int)elementIndex:(NSInteger)row :(NSInteger)component;
// ACTIONS
- (IBAction)goInfo:(id)sender;
- (IBAction)selectDate:(id)sender;
- (IBAction)editDate:(id)sender;
- (IBAction)removeDate:(id)sender;

@end



