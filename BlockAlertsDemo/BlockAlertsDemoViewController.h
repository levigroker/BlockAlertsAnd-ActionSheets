//
//  BlockAlertsDemoViewController.h
//  BlockAlertsDemo
//
//  Created by Gustavo Ambrozio on 9/1/12.
//  Copyright (c) 2012 CodeCrop Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockAlertsDemoViewController : UIViewController <UITextFieldDelegate>

- (IBAction)showAlert:(id)sender;
- (IBAction)showActionSheet:(id)sender;
- (IBAction)showAlertPlusActionSheet:(id)sender;
- (IBAction)showActionSheetPlusAlert:(id)sender;
- (IBAction)goNuts:(id)sender;
- (IBAction)whatsArrived:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)showTextPrompt:(id)sender;
- (IBAction)showNumberPrompt:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *testKeyboard;

@end
