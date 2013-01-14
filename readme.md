BlockAlertsAnd-ActionSheets
====

Based off of [gpambrozio/BlockAlertsAnd-ActionSheets](https://github.com/gpambrozio/BlockAlertsAnd-ActionSheets)

Installing
----------

If you're using [CocoPods](http://cocopods.org) it's as simple as adding this to your `Podfile`:

	pod 'BlockAlertsAnd-ActionSheets', :git => 'https://github.com/levigroker/BlockAlertsAnd-ActionSheets.git'


Forked
------
I've forked the original to fix some issues with it, since the original author does not appear to be accepting pull requests.

Using the Library
-----------------

To create an alert view you use:

    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Alert Title"
                                                   message:@"This is a very long message, designed just to show you how smart this class is"];

Then for every button you want you call:

    [alert addButtonWithTitle:@"Do something cool" block:^{
        // Do something cool when this button is pressed
    }];

You can also add a "Cancel" button and a "Destructive" button (this is one of the improvements that UIAlertView can't even do):

    [alert setCancelButtonWithTitle:@"Please, don't do this" block:^{
        // Do something or nothing.... This block can even be nil!
    }];

    [alert setDestructiveButtonWithTitle:@"Kill, Kill" block:^{
        // Do something nasty when this button is pressed
    }];

When all your buttons are in place, just show:

    [alert show];

