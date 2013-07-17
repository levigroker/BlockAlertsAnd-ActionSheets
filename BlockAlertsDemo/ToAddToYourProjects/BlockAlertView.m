//
//  BlockAlertView.m
//
//

#import "BlockAlertView.h"
#import "BlockBackground.h"
#import "BlockUI.h"

@interface BlockAlertView ()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) BOOL vignetteBackground;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) NSMutableArray *blocks;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) id retainedSelf;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) BOOL shown;
@property (nonatomic, assign) BOOL cancelBounce;

@end

@implementation BlockAlertView

static UIImage *background = nil;
static UIImage *backgroundlandscape = nil;
static UIFont *titleFont = nil;
static UIFont *messageFont = nil;
static UIFont *buttonFont = nil;


#pragma mark - init

+ (void)initialize
{
    if (self == [BlockAlertView class])
    {
        background = [UIImage imageNamed:kAlertViewBackground];
        background = [background stretchableImageWithLeftCapWidth:0 topCapHeight:kAlertViewBackgroundCapHeight];
        backgroundlandscape = [UIImage imageNamed:kAlertViewBackgroundLandscape];
        backgroundlandscape = [backgroundlandscape stretchableImageWithLeftCapWidth:0 topCapHeight:kAlertViewBackgroundCapHeight];
        titleFont = kAlertViewTitleFont;
        messageFont = kAlertViewMessageFont;
        buttonFont = kAlertViewButtonFont;
    }
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message
{
    return [[BlockAlertView alloc] initWithTitle:title message:message];
}

+ (void)showInfoAlertWithTitle:(NSString *)title message:(NSString *)message
{
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:title message:message];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"Dismiss", nil) block:nil];
    [alert show];
}

+ (void)showErrorAlert:(NSError *)error
{
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:NSLocalizedString(@"Operation Failed", nil) message:[NSString stringWithFormat:NSLocalizedString(@"The operation did not complete successfully: %@", nil), error]];
    [alert setCancelButtonWithTitle:@"Dismiss" block:nil];
    [alert show];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (void)addComponents:(CGRect)frame {
    if (self.title)
    {
        CGSize size = [self.title sizeWithFont:titleFont
                         constrainedToSize:CGSizeMake(frame.size.width-kAlertViewBorder*2, 1000)
                             lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kAlertViewBorder, _height, frame.size.width-kAlertViewBorder*2, size.height)];
        labelView.font = titleFont;
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = NSLineBreakByWordWrapping;
        labelView.textColor = kAlertViewTitleTextColor;
        labelView.backgroundColor = [UIColor clearColor];
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.shadowColor = kAlertViewTitleShadowColor;
        labelView.shadowOffset = kAlertViewTitleShadowOffset;
        labelView.text = self.title;
        [self.view addSubview:labelView];
        
        self.height += size.height + kAlertViewBorder;
    }
    
    if (self.message)
    {
        CGSize size = [self.message sizeWithFont:messageFont
                               constrainedToSize:CGSizeMake(frame.size.width-kAlertViewBorder*2, 1000)
                                   lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kAlertViewBorder, self.height, frame.size.width-kAlertViewBorder*2, size.height)];
        labelView.font = messageFont;
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = NSLineBreakByWordWrapping;
        labelView.textColor = kAlertViewMessageTextColor;
        labelView.backgroundColor = [UIColor clearColor];
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.shadowColor = kAlertViewMessageShadowColor;
        labelView.shadowOffset = kAlertViewMessageShadowOffset;
        labelView.text = self.message;
        [self.view addSubview:labelView];
        
        self.height += size.height + kAlertViewBorder;
    }
}

- (void)setupDisplay
{
    [[self.view subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    UIWindow *parentView = [BlockBackground sharedInstance];
    CGRect frame = parentView.bounds;
    frame.origin.x = floorf((frame.size.width - background.size.width) * 0.5);
    frame.size.width = background.size.width;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        frame.size.width += 150;
        frame.origin.x -= 75;
    }
    
    self.view.frame = frame;
    
    self.height = kAlertViewBorder + 15;
    
    if (NeedsLandscapePhoneTweaks) {
        self.height -= 15; // landscape phones need to trimmed a bit
    }

    [self addComponents:frame];

    if (self.shown)
        [self show];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
    self = [super init];
    
    if (self)
    {
        self.title = title;
        self.message = message;
        
        self.view = [[UIView alloc] init];
        
        self.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        self.blocks = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(setupDisplay) 
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification 
                                                   object:nil];   
        
        if ([self class] == [BlockAlertView class])
            [self setupDisplay];
        
        self.vignetteBackground = NO;
    }
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color block:(void (^)())block
{
    [self.blocks addObject:[NSArray arrayWithObjects:
                            block ? [block copy] : [NSNull null],
                            title,
                            color,
                            nil]];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"gray" block:block];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"black" block:block];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block];
}

- (void)addButtonWithTitle:(NSString *)title imageIdentifier:(NSString*)identifier block:(void (^)())block {
    [self addButtonWithTitle:title color:identifier block:block];
}

- (void)show
{
    self.shown = YES;
    
    BOOL isSecondButton = NO;
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < self.blocks.count; i++)
    {
        NSArray *block = [self.blocks objectAtIndex:i];
        NSString *title = [block objectAtIndex:1];
        NSString *color = [block objectAtIndex:2];
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"alert-%@-button.png", color]];
        image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width+1)>>1 topCapHeight:0];
        
        UIImage *highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"alert-%@-button-highlighted.png", color]];
        
        highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:(int)(highlightedImage.size.width+1)>>1 topCapHeight:0];
        
        CGFloat maxHalfWidth = floorf((self.view.bounds.size.width-kAlertViewBorder*3)*0.5);
        CGFloat width = self.view.bounds.size.width-kAlertViewBorder*2;
        CGFloat xOffset = kAlertViewBorder;
        if (isSecondButton)
        {
            width = maxHalfWidth;
            xOffset = width + kAlertViewBorder * 2;
            isSecondButton = NO;
        }
        else if (i + 1 < self.blocks.count)
        {
            // In this case there's another button.
            // Let's check if they fit on the same line.
            CGSize size = [title sizeWithFont:buttonFont
                                  minFontSize:10
                               actualFontSize:nil
                                     forWidth:self.view.bounds.size.width-kAlertViewBorder*2
                                lineBreakMode:NSLineBreakByClipping];
            
            if (size.width < maxHalfWidth - kAlertViewBorder)
            {
                // It might fit. Check the next Button
                NSArray *block2 = [self.blocks objectAtIndex:i+1];
                NSString *title2 = [block2 objectAtIndex:1];
                size = [title2 sizeWithFont:buttonFont
                                minFontSize:10
                             actualFontSize:nil
                                   forWidth:self.view.bounds.size.width-kAlertViewBorder*2
                              lineBreakMode:NSLineBreakByClipping];
                
                if (size.width < maxHalfWidth - kAlertViewBorder)
                {
                    // They'll fit!
                    isSecondButton = YES;  // For the next iteration
                    width = maxHalfWidth;
                }
            }
        }
        else if (self.blocks.count  == 1)
        {
            // In this case this is the ony button. We'll size according to the text
            CGSize size = [title sizeWithFont:buttonFont
                                  minFontSize:10
                               actualFontSize:nil
                                     forWidth:self.view.bounds.size.width-kAlertViewBorder*2
                                lineBreakMode:NSLineBreakByClipping];
            
            size.width = MAX(size.width, 80);
            if (size.width + 2 * kAlertViewBorder < width)
            {
                width = size.width + 2 * kAlertViewBorder;
                xOffset = floorf((self.view.bounds.size.width - width) * 0.5);
            }
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(xOffset, self.height, width, kAlertButtonHeight);
        button.titleLabel.font = buttonFont;
        if (IOS_LESS_THAN_6) {
#pragma clan diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            button.titleLabel.minimumFontSize = 10;
#pragma clan diagnostic pop
        }
        else {
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            button.titleLabel.adjustsLetterSpacingToFitWidth = YES;
            button.titleLabel.minimumScaleFactor = 0.1;
        }
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.shadowOffset = kAlertViewButtonShadowOffset;
        button.backgroundColor = [UIColor clearColor];
        button.tag = i+1;
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        if (highlightedImage)
        {
            [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        }
        [button setTitleColor:kAlertViewButtonTextColor forState:UIControlStateNormal];
        [button setTitleShadowColor:kAlertViewButtonShadowColor forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.accessibilityLabel = title;
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        
        if (!isSecondButton)
            self.height += kAlertButtonHeight + kAlertViewBorder;
        
        index++;
    }

    //self.height += 10;  // Margin for the shadow // not sure where this came from, but it's making things look strange (I don't see a shadow, either)
    
    if (self.height < background.size.height)
    {
        CGFloat offset = background.size.height - self.height;
        self.height = background.size.height;
        CGRect frame;
        for (NSUInteger i = 0; i < self.blocks.count; i++)
        {
            UIButton *btn = (UIButton *)[self.view viewWithTag:i+1];
            frame = btn.frame;
            frame.origin.y += offset;
            btn.frame = frame;
        }
    }

    CGRect frame = self.view.frame;
    frame.origin.y = - self.height;
    frame.size.height = self.height;
    self.view.frame = frame;
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        modalBackground.image = backgroundlandscape;
    else
        modalBackground.image = background;
    
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    modalBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:modalBackground atIndex:0];
    
    if (self.backgroundImage)
    {
        [BlockBackground sharedInstance].backgroundImage = self.backgroundImage;
        self.backgroundImage = nil;
    }

    [BlockBackground sharedInstance].vignetteBackground = self.vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:self.view];
    
    __block CGPoint center = self.view.center;
    center.y = floorf([BlockBackground sharedInstance].bounds.size.height * 0.5) + kAlertViewBounce;
    
    self.cancelBounce = NO;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [BlockBackground sharedInstance].alpha = 1.0f;
                         self.view.center = center;
                     }
                     completion:^(BOOL finished) {
                         if (self.cancelBounce) return;
                         
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:0
                                          animations:^{
                                              center.y -= kAlertViewBounce;
                                              self.view.center = center;
                                          }
                                          completion:^(BOOL finished) {
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"AlertViewFinishedAnimations" object:self];
                                          }];
                     }];
    
    self.retainedSelf = self;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    self.shown = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             CGPoint center = self.view.center;
                             center.y += 20;
                             self.view.center = center;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.4
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  CGRect frame = self.view.frame;
                                                  frame.origin.y = -frame.size.height;
                                                  self.view.frame = frame;
                                                  [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                                              }
                                              completion:^(BOOL finished) {
                                                  [[BlockBackground sharedInstance] removeView:self.view];
                                                  self.view = nil;
                                                  self.retainedSelf = nil;
                                              }];
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:self.view];
        self.view = nil;
        self.retainedSelf = nil;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action

- (void)buttonClicked:(id)sender
{
    /* Run the button's block */
    int buttonIndex = [(UIButton *)sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
