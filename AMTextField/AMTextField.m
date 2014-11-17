//
//  AMTextField.m
//  AMTextField
//
//  Created by Andrea Mazzini on 30/08/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "AMTextField.h"

@interface AMTextField ()

#pragma mark AMTextField Property
@property (nonatomic, strong) CATextLayer *placeholderLayer;
@property (nonatomic, strong) NSString *placeholderString;
@property (nonatomic, assign, setter=setCollapsed:) BOOL isCollapsed;

//Shake Property
@property (nonatomic) int times;
@property (nonatomic) CGFloat delta;
@property (nonatomic) NSTimeInterval interval;
@property (nonatomic) ShakeDirection direction;;


@end

@implementation AMTextField

@synthesize validationType;
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
    
    [self.layer addSublayer:self.placeholderLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
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
    
    
    switch (validationType) {
        case MobileValidation:
            if (![self validateMobile:self.text]) {
                [self shake:self.times withDelta:self.delta andSpeed:self.interval shakeDirection:self.direction completion:nil];
            }
            break;
        case EmailValidation:
            if (![self validatEmail:self.text]) {
                [self shake:self.times withDelta:self.delta andSpeed:self.interval shakeDirection:self.direction completion:nil];
            }
            break;
        case NullOrEmptyValidation:
            if (![self isNullOrEmpty:self.text]) {
                [self shake:self.times withDelta:self.delta andSpeed:self.interval shakeDirection:self.direction completion:nil];
            }
            break;
        default:
            break;
    }
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
#pragma mark Shake Methods

- (void)shake:(int)times withDelta:(CGFloat)delta andSpeed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection
{
    self.times=times;
    self.delta=delta;
    self.interval=interval;
    self.direction=ShakeDirectionHorizontal;
}

- (void)shake:(int)times withDelta:(CGFloat)delta andSpeed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection completion:(void(^)())handler
{
    [self _shake:times direction:1 currentTimes:0 withDelta:delta andSpeed:interval shakeDirection:shakeDirection completion:handler];
}

- (void)_shake:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta andSpeed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection completion:(void(^)())handler
{
    [UIView animateWithDuration:interval animations:^{
        self.transform = (shakeDirection == ShakeDirectionHorizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction);
    } completion:^(BOOL finished) {
        if(current >= times) {
            [UIView animateWithDuration:interval animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (handler) {
                    handler();
                }
            }];
            return;
        }
        [self _shake:(times - 1)
           direction:direction * -1
        currentTimes:current + 1
           withDelta:delta
            andSpeed:interval
      shakeDirection:shakeDirection completion:handler];
    }];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark Validation

- (BOOL)validatEmail:(NSString *)emailAddress
{
    if([self isNullOrEmpty:emailAddress])
        return FALSE;
    
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    //    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    //    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    //    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    //    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    //    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    //    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    //    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilterString ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailAddress];
}

- (BOOL)isNullOrEmpty:(NSString *)s
{
    if(s == nil ||
       s.length == 0 ||
       [s isEqualToString:@""] ||
       [s isEqualToString:@"(null)"])
    {
        return YES;
    }
    
    return NO;
}

/*
 要分台湾手机号还是大陆手机号，需要一组正则表达式根据情况判断
 ⑴台湾手机10位数，皆以09起头，拨打台湾手机，先拨台湾的国际区码00886，接着拨去起头0的手机号码，譬如0960XXXXXX，则拨00886-960XXXXXX
 ⑵台湾座机号码，县市区码2-3位数（以0起头），电话号码6-8位数，拨打台湾座机，先拨台湾的国际区码00886，接着拨去起头0的县市区码，最后拨电话号码，
 譬如台北市电话02-8780XXXX，则拨00886-2-8780XXXX，另一例是台东县电话，089-345XXX，则拨00886-89-345XXX
 */

- (BOOL)validateMobile:(NSString *)mobile
{
    if([self isNullOrEmpty:mobile])
        return FALSE;
    
    if(mobile.length < 10) return FALSE;
    
    //手机号以13， 15，18开头，八个 \d 数字字符
    //    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    //    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    return [phoneTest evaluateWithObject:mobile];
    
    return TRUE;
}



@end

