//
//  BlockAlertView.h
//
//

#import <UIKit/UIKit.h>

@interface BlockAlertView : NSObject

@property (nonatomic, strong, readonly) UIView *view;

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message;

+ (void)showInfoAlertWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showErrorAlert:(NSError *)error;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;

// Images should be named in the form "alert-IDENTIFIER-button.png"
- (void)addButtonWithTitle:(NSString *)title imageIdentifier:(NSString*)identifier block:(void (^)())block;

- (void)addComponents:(CGRect)frame;

- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

- (void)setupDisplay;

@end
