//
//  AMTextField.h
//  AMTextField
//
//  Created by Andrea Mazzini on 30/08/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMTextField : UITextField

@property (nonatomic, assign) CGPoint placeholderOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *labelFontColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *placeholderFontColor UI_APPEARANCE_SELECTOR;

@end
