//
//  BlockActionSheet.h
//
//

#import <UIKit/UIKit.h>

/**
 * A simple block-enabled API wrapper on top of UIActionSheet.
 */
@interface BlockActionSheet : NSObject

@property (nonatomic, strong, readonly) UIView *view;

+ (id)sheetWithTitle:(NSString *)title;

- (id)initWithTitle:(NSString *)title;

- (void)setCancelButtonWithTitle:(NSString *) title block:(void (^)()) block;
- (void)setDestructiveButtonWithTitle:(NSString *) title block:(void (^)()) block;
- (void)addButtonWithTitle:(NSString *) title block:(void (^)()) block;

- (void)setCancelButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(void (^)()) block;
- (void)setDestructiveButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(void (^)()) block;
- (void)addButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(void (^)()) block;

- (void)showInView:(UIView *)view;

- (NSUInteger)buttonCount;

@end
