//
//  ViewController.m
//  Demo
//
//  Created by Andrea Mazzini on 31/08/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "ViewController.h"
#import "AMTextField.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet AMTextField *textField;


@end

@implementation ViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textField.placeholder = @"Email";
    self.textField.validationType=EmailValidation;
    [self.textField shake:10  withDelta:5.f andSpeed:0.04 shakeDirection:ShakeDirectionHorizontal];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]])
            [view resignFirstResponder];
    }
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
