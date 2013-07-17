//
//  BlockTextPromptAlertView.h
//  BlockAlertsDemo
//
//  Created by Barrett Jacobsen on 2/13/12.
//  Copyright (c) 2012 Barrett Jacobsen. All rights reserved.
//

#import "BlockAlertView.h"

@class BlockTextPromptAlertView;

typedef BOOL (^BlockTextPromptAlertShouldDismiss)(NSInteger buttonIndex, BlockTextPromptAlertView* theAlert);
typedef BOOL(^TextFieldReturnCallBack)(BlockTextPromptAlertView *);

@interface BlockTextPromptAlertView : BlockAlertView <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) NSInteger maxLength;

@property (nonatomic, assign) BOOL disableAutoBecomeFirstResponder;
@property (nonatomic, assign) BOOL selectAllOnBeginEdit;
@property (nonatomic, assign) NSInteger buttonIndexForReturn;
@property (nonatomic, copy) NSCharacterSet *unacceptedInput;

@property (readwrite, copy) BlockTextPromptAlertShouldDismiss shouldDismiss;

+ (BlockTextPromptAlertView *)promptWithTitle:(NSString *)title message:(NSString *)message defaultText:(NSString*)defaultText;
+ (BlockTextPromptAlertView *)promptWithTitle:(NSString *)title message:(NSString *)message defaultText:(NSString*)defaultText block:(TextFieldReturnCallBack) block;

+ (BlockTextPromptAlertView *)promptWithTitle:(NSString *)title message:(NSString *)message textField:(out UITextField**)textField;

+ (BlockTextPromptAlertView *)promptWithTitle:(NSString *)title message:(NSString *)message textField:(out UITextField**)textField block:(TextFieldReturnCallBack) block;

- (id)initWithTitle:(NSString *)title message:(NSString *)message defaultText:(NSString*)defaultText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message defaultText:(NSString*)defaultText block: (TextFieldReturnCallBack) block;

- (void)setAllowableCharacters:(NSString *)accepted;

@end
