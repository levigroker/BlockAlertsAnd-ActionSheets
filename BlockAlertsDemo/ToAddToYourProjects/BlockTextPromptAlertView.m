//
//  BlockTextPromptAlertView.m
//  BlockAlertsDemo
//
//  Created by Barrett Jacobsen on 2/13/12.
//  Copyright (c) 2012 Barrett Jacobsen. All rights reserved.
//

#import "BlockTextPromptAlertView.h"

#define kTextBoxHeight      31
#define kTextBoxSpacing     5
#define kTextBoxHorizontalMargin 12

#define kKeyboardResizeBounce         20

@interface BlockTextPromptAlertView()

@property (nonatomic, copy) TextFieldReturnCallBack callBack;
@property (nonatomic, strong) NSCharacterSet *unacceptedInput;
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, assign) CGFloat height;

@end

@implementation BlockTextPromptAlertView

+ (BlockTextPromptAlertView *)promptWithTitle:(NSString *)title message:(NSString *)message defaultText:(NSString*)defaultText {
    return [self promptWithTitle:title message:message defaultText:defaultText block:nil];
}

+ (BlockTextPromptAlertView *)promptWithTitle:(NSString *)title message:(NSString *)message defaultText:(NSString*)defaultText block:(TextFieldReturnCallBack)block {
    return [[BlockTextPromptAlertView alloc] initWithTitle:title message:message defaultText:defaultText block:block];
}

+ (BlockTextPromptAlertView *)promptWithTitle:(NSString *)title message:(NSString *)message textField:(out UITextField**)textField {
    return [self promptWithTitle:title message:message textField:textField block:nil];
}


+ (BlockTextPromptAlertView *)promptWithTitle:(NSString *)title message:(NSString *)message textField:(out UITextField**)textField block:(TextFieldReturnCallBack) block{
    BlockTextPromptAlertView *prompt = [[BlockTextPromptAlertView alloc] initWithTitle:title message:message defaultText:nil block:block];
    
    *textField = prompt.textField;
    
    return prompt;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message defaultText:(NSString*)defaultText block: (TextFieldReturnCallBack) block {
    
    self = [super initWithTitle:title message:message];
    
    if (self) {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(kTextBoxHorizontalMargin, self.height, self.view.bounds.size.width - kTextBoxHorizontalMargin * 2, kTextBoxHeight)];
        
        [theTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [theTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [theTextField setBorderStyle:UITextBorderStyleRoundedRect];
        [theTextField setTextAlignment:UITextAlignmentCenter];
        [theTextField setClearButtonMode:UITextFieldViewModeAlways];
        
        if (defaultText)
            theTextField.text = defaultText;
        
        if (block){
            theTextField.delegate = self;
        }
        
        [self.view addSubview:theTextField];
        
        self.textField = theTextField;
        
        self.height += kTextBoxHeight + kTextBoxSpacing;
        
        self.callBack = block;
    }
    
    return self;
}
- (void)show {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [super show];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.textField selector:@selector(becomeFirstResponder) name:@"AlertViewFinishedAnimations" object:nil];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.textField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    __block CGRect frame = self.view.frame;
    
    if (frame.origin.y + frame.size.height > screenHeight - keyboardSize.height) {
        
        frame.origin.y = screenHeight - keyboardSize.height - frame.size.height;
        
        if (frame.origin.y < 0)
            frame.origin.y = 0;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             self.view.frame = frame;
                         } 
                         completion:nil];
    }
}


- (void)setAllowableCharacters:(NSString*)accepted {
    self.unacceptedInput = [[NSCharacterSet characterSetWithCharactersInString:accepted] invertedSet];
    self.textField.delegate = self;
}

- (void)setMaxLength:(NSInteger)max {
    _maxLength = max;
    self.textField.delegate = self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)_textField{
    if (self.callBack){
        return self.callBack(self);
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger newLength = [self.textField.text length] + [string length] - range.length;
    
    if (self.maxLength > 0 && newLength > self.maxLength)
        return NO;
    
    if (!self.unacceptedInput)
        return YES;
    
    if ([[string componentsSeparatedByCharactersInSet:self.unacceptedInput] count] > 1)
        return NO;
    else 
        return YES;
}


@end
