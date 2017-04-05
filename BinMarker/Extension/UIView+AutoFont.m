//
//  UIView+AutoFont.m
//  BinMarker
//
//  Created by 彭子上 on 2017/4/1.
//  Copyright © 2017年 彭子上. All rights reserved.
//

#import "UIView+AutoFont.h"
#import <objc/runtime.h>

#define ScrenScale [UIScreen mainScreen].bounds.size.width/320.0

@implementation UIView (AutoFont)

+(CGFloat)getFontScrenScale
{
    return ScrenScale;
}

@end


@implementation UILabel (AutoFont)

-(id)AutoInitWithCoder:(NSCoder *)aDecoder
{
    [self AutoInitWithCoder:aDecoder];
    if (self) {
        CGFloat fontSize = self.font.pointSize;
        CGFloat fontScale= [UIView getFontScrenScale];
        self.font=[self.font fontWithSize:fontSize*fontScale];
    }
    return self;
}

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method old=class_getInstanceMethod([self class], @selector(initWithCoder:));
        Method new=class_getInstanceMethod([self class], @selector(AutoInitWithCoder:));
        method_exchangeImplementations(old, new);
    });
}

@end

@implementation UIButton (AutoFont)

-(id)AutoInitWithCoder:(NSCoder *)aDecoder
{
    [self AutoInitWithCoder:aDecoder];
    if (self) {
        CGFloat fontSize = self.titleLabel.font.pointSize;
        CGFloat fontScale= [UIView getFontScrenScale];
        self.titleLabel.font = [self.titleLabel.font fontWithSize:fontSize*fontScale];
    }
    return self;
}

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method old=class_getInstanceMethod([self class], @selector(initWithCoder:));
        Method new=class_getInstanceMethod([self class], @selector(AutoInitWithCoder:));
        method_exchangeImplementations(old, new);
    });
}

@end

