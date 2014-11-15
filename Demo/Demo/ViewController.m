//
//  ViewController.m
//  Demo
//
//  Created by Andrea Mazzini on 31/08/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "ViewController.h"
#import "AMTextField.h"
#import "UIView+Shake.h"
#import "NSString+Utils.h"
#import "AMPopTip.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet AMTextField *textField;

//shake
@property (weak, nonatomic) IBOutlet UITextField *textShakes;
@property (weak, nonatomic) IBOutlet UITextField *textSpeed;
@property (weak, nonatomic) IBOutlet UITextField *textDelta;
@property (weak, nonatomic) IBOutlet UISegmentedControl *shakeDirection;
//tipPop
@property (nonatomic, strong) AMPopTip *popTip;

@end

@implementation ViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textField.placeholder = @"Email";
    //prepare For Shake
#pragma mark  Shake
    [self setTitle:@"Demo"];
    [@[_textDelta, _textShakes, _textSpeed] enumerateObjectsUsingBlock:^(UITextField* obj, NSUInteger idx, BOOL *stop) {
        [obj.layer setBorderWidth:2];
        [obj.layer setBorderColor:[UIColor colorWithRed:107.0/255.0 green:150.0/255.0 blue:199.0/255.0 alpha:1].CGColor];
        [obj setDelegate:self];
    }];
    [self.shakeDirection.layer setBorderWidth:2];
    [self.shakeDirection.layer setBorderColor:self.shakeDirection.tintColor.CGColor];
    self.shakeDirection.selectedSegmentIndex = 0;
    //prepare For tipPop
#pragma mark  TipPop
   
    [[AMPopTip appearance] setFont:[UIFont fontWithName:@"Avenir-Medium" size:12]];
    
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.edgeMargin = 5;
    self.popTip.tapHandler = ^{
        NSLog(@"Tap!");
    };
    self.popTip.dismissHandler = ^{
        NSLog(@"Dismiss!");
    };
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]])
            [view resignFirstResponder];
    }
}
#pragma mark Shake
- (IBAction)actionShake:(id)sender
{
    [self shake];
}

- (void)shake
{
//    [self.view.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
//        [obj shake:[self.textShakes.text intValue]
//         withDelta:[self.textDelta.text floatValue]
//          andSpeed:[self.textSpeed.text floatValue]
//    shakeDirection:(self.shakeDirection.selectedSegmentIndex == 0) ? ShakeDirectionHorizontal : ShakeDirectionVertical];
//    }];
    
    [self.textField shake:[self.textShakes.text intValue]
     withDelta:[self.textDelta.text floatValue]
      andSpeed:[self.textSpeed.text floatValue]
shakeDirection:(self.shakeDirection.selectedSegmentIndex == 0) ? ShakeDirectionHorizontal : ShakeDirectionVertical];

    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(![NSString validatEmail:textField.text])
    {
        [self shake];
        
        static int direction = 0;
        [self.popTip showText:@"Enter Correct Email" direction:direction maxWidth:200 inView:self.view fromFrame:textField.frame duration:2];
        direction = (direction + 1) % 2;

    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UITextField class]]) {
            [obj resignFirstResponder];
        }
    }];
}
@end
