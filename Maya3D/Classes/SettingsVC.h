//
//  SettingsVC.h
//  Maya3D
//
//  Created by Roger on 19/11/08.
//  Copyright 2008 Studio Avante. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsVC : UIViewController
{
	UISegmentedControl *controlHemisphere;
	UISegmentedControl *controlStartDate;
	UISegmentedControl *controlDateFormat;
	UISegmentedControl *controlNumbering;
	UISegmentedControl *controlGearLabel;
	UISegmentedControl *controlGearSound;
	UISegmentedControl *controlLangSetting;
}

@property (nonatomic, assign) IBOutlet UISegmentedControl *controlHemisphere;
@property (nonatomic, assign) IBOutlet UISegmentedControl *controlStartDate;
@property (nonatomic, assign) IBOutlet UISegmentedControl *controlDateFormat;
@property (nonatomic, assign) IBOutlet UISegmentedControl *controlNumbering;
@property (nonatomic, assign) IBOutlet UISegmentedControl *controlGearLabel;
@property (nonatomic, assign) IBOutlet UISegmentedControl *controlGearSound;
@property (nonatomic, assign) IBOutlet UISegmentedControl *controlLangSetting;

- (id)init;
// Estes metodos vao aparecer no Interface Builder para ligar no botao
- (IBAction)setHemisphere:(id)sender;
- (IBAction)setStartDate:(id)sender;
- (IBAction)setDateFormat:(id)sender;
- (IBAction)setNumberting:(id)sender;
- (IBAction)setGearLabel:(id)sender;
- (IBAction)setGearSound:(id)sender;
- (IBAction)setLangSetting:(id)sender;
- (IBAction)actionDone:(id)sender;

@end
