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

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self loadDefaults];
    return self;
}

- (instancetype)init
{
    self = [super init];
    [self loadDefaults];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self loadDefaults];
    return self;
}

- (void)loadDefaults
{
    [self setCollapsed:YES];
    
    _placeholderOffset = (CGPoint){ 10, 3 };
    _labelFontColor = [UIColor blackColor];
    _placeholderFontColor = [UIColor lightGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidBeginEditing)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidEndEditing)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.clipsToBounds = NO;
    
    self.placeholderLayer.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self updateFont];

    self.placeholderString = self.placeholder;
    self.placeholderLayer.string = self.placeholder;

    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: [UIColor clearColor]}];

    [self.layer addSublayer:self.placeholderLayer];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self updateFont];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self textFieldDidChange];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
}

- (void)updateFont
{
    self.placeholderLayer.font = (__bridge CFTypeRef)(self.font.fontName);
    self.placeholderLayer.fontSize = self.font.pointSize;
    CGRect bounds = self.bounds;
    bounds.size = (CGSize){ bounds.size.width - self.placeholderOffset.x, self.font.pointSize + self.placeholderOffset.y };
    self.placeholderLayer.bounds = bounds;
}

- (CATextLayer *)placeholderLayer
{
    if (!_placeholderLayer) {
        _placeholderLayer = [[CATextLayer alloc] init];
        _placeholderLayer.foregroundColor = self.placeholderFontColor.CGColor;
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
    [self expandLabelIfNeeded];
}

- (void)textFieldDidEndEditing
{
    [self collapseLabelIfNeeded];
}

- (void)expandLabelIfNeeded
{
    if (self.isCollapsed) {
        [self bounceAnimateFrom:self.frame.size.height / 2 to:-self.frame.size.height / 2];
        [self animateToColor:self.labelFontColor];
        [self setCollapsed:NO];
    }
}

- (void)collapseLabelIfNeeded
{
    if (self.text.length == 0 && !self.isCollapsed) {
        [self bounceAnimateFrom:-self.frame.size.height / 2 to:self.frame.size.height / 2];
        [self animateToColor:self.placeholderFontColor];
        [self setCollapsed:YES];
    }
}

- (void)textFieldDidChange
{
    if (!self.isFirstResponder) {
        [self expandLabelIfNeeded];
        [self collapseLabelIfNeeded];
    }
}

#pragma mark - Animations

- (void)animateToColor:(UIColor *)color
{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"foregroundColor";
    animation.duration = 0.3;
    animation.fillMode = kCAFillModeForwards;
    animation.fromValue = (id)self.placeholderLayer.foregroundColor;
    animation.toValue = (id)color.CGColor;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = NO;
    [self.placeholderLayer setForegroundColor:color.CGColor];
    [self.placeholderLayer addAnimation:animation forKey:@"color"];
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
