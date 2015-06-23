//
//  ViewController.m
//  Demo
//
//  Created by Andrea Mazzini on 31/08/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "ViewController.h"
#import "AMTextField.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet AMTextField *textField;

@end

@implementation ViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.textField.placeholder = @"Username";
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]])
            [view resignFirstResponder];
    }
}

@end
