//
//  AMTextField.h
//  AMTextField
//
//  Created by Andrea Mazzini on 30/08/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ShakeDirection) {
    ShakeDirectionHorizontal = 0,
    ShakeDirectionVertical
};



typedef NS_ENUM(NSInteger, TypeValidation) {
    MobileValidation = 0,
    EmailValidation  = 1,
    NullOrEmptyValidation
};

@interface AMTextField : UITextField

@property (nonatomic, assign) CGPoint placeholderOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *labelFontColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *placeholderFontColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) TypeValidation validationType;
#pragma mark Shake Methods Decleration

/**-----------------------------------------------------------------------------
 * @name UITextField+Shake
 * -----------------------------------------------------------------------------
 */

/** Shake the UITextField at a custom speed
 *
 * Shake the text field a given number of times with a given speed
 *
 * @param times     The number of shakes
 * @param delta     The width of the shake
 * @param interval  The duration of one shake
 * @param direction  of the shake
 */
- (void)shake:(int)times withDelta:(CGFloat)delta andSpeed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection;






@end
