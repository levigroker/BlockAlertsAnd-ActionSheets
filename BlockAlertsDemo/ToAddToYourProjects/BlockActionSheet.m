//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"
#import "BlockUI.h"

@interface BlockActionSheet ()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) BOOL vignetteBackground;
@property (nonatomic, strong) NSMutableArray *blocks;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) id retainedSelf;

@end

@implementation BlockActionSheet

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (void)initialize
{
    if (self == [BlockActionSheet class])
    {
        background = [UIImage imageNamed:kActionSheetBackground];
        background = [background stretchableImageWithLeftCapWidth:0 topCapHeight:kActionSheetBackgroundCapHeight];
        titleFont = kActionSheetTitleFont;
        buttonFont = kActionSheetButtonFont;
    }
}

+ (id)sheetWithTitle:(NSString *)title
{
    return [[BlockActionSheet alloc] initWithTitle:title];
}

- (id)initWithTitle:(NSString *)title 
{
    if ((self = [super init]))
    {
        UIWindow *parentView = [BlockBackground sharedInstance];
        CGRect frame = parentView.bounds;
        
        self.view = [[UIView alloc] initWithFrame:frame];
        self.blocks = [[NSMutableArray alloc] init];
        self.height = kActionSheetTopMargin;

        if (title)
        {
            CGSize size = [title sizeWithFont:titleFont
                            constrainedToSize:CGSizeMake(frame.size.width-kActionSheetBorder*2, 1000)
                                lineBreakMode:UILineBreakModeWordWrap];
            
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kActionSheetBorder, self.height, frame.size.width-kActionSheetBorder*2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = UILineBreakModeWordWrap;
            labelView.textColor = kActionSheetTitleTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = UITextAlignmentCenter;
            labelView.shadowColor = kActionSheetTitleShadowColor;
            labelView.shadowOffset = kActionSheetTitleShadowOffset;
            labelView.text = title;
            [self.view addSubview:labelView];
            
            self.height += size.height + 5;
        }
        _vignetteBackground = NO;
    }
    
    return self;
}

- (NSUInteger)buttonCount
{
    return self.blocks.count;
}

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color block:(void (^)())block atIndex:(NSInteger)index
{
    if (index >= 0)
    {
        [self.blocks insertObject:[NSArray arrayWithObjects:
                                   block ? [block copy] : [NSNull null],
                                   title,
                                   color,
                                   nil]
                          atIndex:index];
    }
    else
    {
        [self.blocks addObject:[NSArray arrayWithObjects:
                                block ? [block copy] : [NSNull null],
                                title,
                                color,
                                nil]];
    }
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block atIndex:-1];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"black" block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:-1];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block atIndex:index];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"black" block:block atIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"gray" block:block atIndex:index];
}

- (void)showInView:(UIView *)view
{
    NSUInteger i = 1;
    for (NSArray *block in self.blocks)
    {
        NSString *title = [block objectAtIndex:1];
        NSString *color = [block objectAtIndex:2];
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"action-%@-button.png", color]];
        image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width)>>1 topCapHeight:0];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(kActionSheetBorder, self.height, self.view.bounds.size.width-kActionSheetBorder*2, kActionSheetButtonHeight);
        button.titleLabel.font = buttonFont;
        button.titleLabel.minimumFontSize = 6;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
        button.titleLabel.shadowOffset = kActionSheetButtonShadowOffset;
        button.backgroundColor = [UIColor clearColor];
        button.tag = i++;
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setTitleColor:kActionSheetButtonTextColor forState:UIControlStateNormal];
        [button setTitleShadowColor:kActionSheetButtonShadowColor forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.accessibilityLabel = title;
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        self.height += kActionSheetButtonHeight + kActionSheetBorder;
    }
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:self.view.bounds];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    [self.view insertSubview:modalBackground atIndex:0];
    
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:self.view];
    CGRect frame = self.view.frame;
    frame.origin.y = [BlockBackground sharedInstance].bounds.size.height;
    frame.size.height = self.height + kActionSheetBounce;
    self.view.frame = frame;
    
    __block CGPoint center = self.view.center;
    center.y -= self.height + kActionSheetBounce;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         [BlockBackground sharedInstance].alpha = 1.0f;
                         self.view.center = center;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              center.y += kActionSheetBounce;
                                              self.view.center = center;
                                          } completion:nil];
                     }];
    
    self.retainedSelf = self;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated 
{
    if (buttonIndex >= 0 && buttonIndex < [self.blocks count])
    {
        id obj = [[self.blocks objectAtIndex: buttonIndex] objectAtIndex:0];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
    
    if (animated)
    {
        CGPoint center = self.view.center;
        center.y += self.view.bounds.size.height;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.view.center = center;
                             [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                         } completion:^(BOOL finished) {
                             [[BlockBackground sharedInstance] removeView:self.view];
                             self.view = nil;
                             self.retainedSelf = nil;
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:self.view];
        self.view = nil;
        self.retainedSelf = nil;
    }
}

#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = [sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
