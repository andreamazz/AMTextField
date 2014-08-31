//
//  AMTextField.m
//  AMTextField
//
//  Created by Andrea Mazzini on 30/08/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "AMTextField.h"

@interface AMTextField ()

@property (nonatomic, strong) CATextLayer *placeholderLayer;
@property (nonatomic, strong) NSString *placeholderString;
@property (nonatomic, assign, setter=setCollapsed:) BOOL isCollapsed;

@end

@implementation AMTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.clipsToBounds = NO;
    
    [self setCollapsed:YES];
    
    // TODO: move this out of the way
    UIFont *font = [UIFont systemFontOfSize:14];

    CGPoint offset = (CGPoint){ 10, 3 };
    CGRect bounds = self.bounds;
    bounds.size = (CGSize){ bounds.size.width - offset.x, font.pointSize + offset.y };
    self.placeholderLayer.bounds = bounds;
    self.placeholderLayer.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self.layer addSublayer:self.placeholderLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidBeginEditing)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidEndEditing)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:self];
}

- (CATextLayer *)placeholderLayer
{
    if (!_placeholderLayer) {
        
        // TODO: move this out of the way
        UIFont *font = [UIFont systemFontOfSize:14];
        
        _placeholderLayer = [[CATextLayer alloc] init];
        _placeholderLayer.font = (__bridge CFTypeRef)(font.fontName);
        _placeholderLayer.fontSize = font.pointSize;
        _placeholderLayer.foregroundColor = [UIColor blackColor].CGColor;
        
        _placeholderLayer.wrapped = NO;
        
        _placeholderLayer.contentsScale = [[UIScreen mainScreen] scale];
        _placeholderLayer.zPosition = 2.0;
    }
    return _placeholderLayer;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    self.placeholderString = placeholder;
    self.placeholderLayer.string = placeholder;
}

- (void)textFieldDidBeginEditing
{
    if (self.isCollapsed) {
        [self bounceAnimateFrom:self.frame.size.height / 2 to:-self.frame.size.height / 2];
        [self setCollapsed:NO];
    }
}

- (void)textFieldDidEndEditing
{
    if (self.text.length == 0 && !self.isCollapsed) {
        [self bounceAnimateFrom:-self.frame.size.height / 2 to:self.frame.size.height / 2];
        [self setCollapsed:YES];
    }
}

- (void)bounceAnimateFrom:(CGFloat)from to:(CGFloat)to
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.y";
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.3;
    
    // Thanks to http://khanlou.com/2012/01/cakeyframeanimation-make-it-bounce/
    int steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    float e = 2.71;
    for (NSUInteger i = 0; i < steps; i++) {
        [values addObject:@(from * pow(e, -0.055 * i) * cos(0.08 * i) + to)];
    }
    animation.values = values;
    
    animation.additive = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    [self.placeholderLayer addAnimation:animation forKey:@"bounce"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
