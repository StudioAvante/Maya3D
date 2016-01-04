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
#import "TzClock.h"
#import "AvanteTextLabel.h"

@interface DateAddVC : UIViewController <UITextFieldDelegate> {
	// UI
	//AvanteTextLabel *dateField;
	UITextField *descField;
	// EDIT
	int editItem;
	int julian;
}

@property(nonatomic,assign) IBOutlet UILabel *dateField;
@property(nonatomic,assign) IBOutlet UILabel *noteField;

@property(nonatomic,retain) NSString* prevTitle;
// IB
@property (nonatomic, assign) IBOutlet UITextField *descField;

- (id)initAddItem:(int)j;
- (id)initEditItem:(int)i;
- (void)setup;
- (BOOL)saveDate;
- (IBAction)done:(id)sender;
- (IBAction)goPrev:(id)sender;
@end
