//
//  LRNContainerView.m
//  LottieReactNative
//
//  Created by Leland Richardson on 12/12/16.
//  Copyright © 2016 Airbnb. All rights reserved.
//

#import "LRNContainerView.h"

// import UIView+React.h
#if __has_include(<React/UIView+React.h>)
#import <React/UIView+React.h>
#elif __has_include("UIView+React.h")
#import "UIView+React.h"
#else
#import "React/UIView+React.h"
#endif

@implementation LRNContainerView {
  LOTAnimationView *_animationView;
}

- (void)reactSetFrame:(CGRect)frame
{
  [super reactSetFrame:frame];
  if (_animationView != nil) {
    [_animationView reactSetFrame:frame];
  }
}

- (void)setProgress:(CGFloat)progress {
  _progress = progress;
  if (_animationView != nil) {
    _animationView.animationProgress = _progress;
  }
}

- (void)setSpeed:(CGFloat)speed {
  _speed = speed;
  if (_animationView != nil) {
    _animationView.animationSpeed = _speed;
  }
}

- (void)setLoop:(BOOL)loop {
  _loop = loop;
  if (_animationView != nil) {
    _animationView.loopAnimation = _loop;
  }
}

- (void)setResizeMode:(NSString *)resizeMode {
  if ([resizeMode isEqualToString:@"cover"]) {
    [self setContentMode:UIViewContentModeScaleAspectFill];
  } else if ([resizeMode isEqualToString:@"contain"]) {
    [self setContentMode:UIViewContentModeScaleAspectFit];
  } else if ([resizeMode isEqualToString:@"center"]) {
    [self setContentMode:UIViewContentModeCenter];
  }
}

- (void)setSourceJson:(NSString *)jsonString {
  NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:kNilOptions
                                                         error:nil];
 
  if ([json objectForKey:@"uri"] != nil){
      NSString* uri = json[@"uri"];
      NSURL * url = [NSURL fileURLWithPath:uri];
      LOTAnimationView * view = [[LOTAnimationView alloc] initWithContentsOfURL:url];
      [self replaceAnimationView:view];
  } else {
      [self replaceAnimationView:[LOTAnimationView animationFromJSON:json]];
  }
}

- (void)setSourceName:(NSString *)name {
  [self replaceAnimationView:[LOTAnimationView animationNamed:name]];
}

- (void)play {
  if (_animationView != nil) {
    [_animationView play];
  }
}

- (void)playFromFrame:(NSNumber *)startFrame
              toFrame:(NSNumber *)endFrame {
  if (_animationView != nil) {
    [_animationView playFromFrame:startFrame
                          toFrame:endFrame withCompletion:nil];
  }
}

- (void)reset {
  if (_animationView != nil) {
    _animationView.animationProgress = 0;
    [_animationView pause];
  }
}

- (void)replaceColorR:(nonnull  NSNumber*)r
                    g:(nonnull  NSNumber*)g
                    b:(nonnull  NSNumber*)b
{
    LOTKeypath *keypath = [LOTKeypath keypathWithKeys:@"**", @"Color", nil];
    
    UIColor* color =  [[UIColor alloc] initWithRed:r.floatValue green:g.floatValue blue:b.floatValue alpha:1.0];
    LOTColorValueCallback *colorCallback = [LOTColorValueCallback withCGColor:color.CGColor];
    
    [_animationView setValueDelegate:colorCallback forKeypath:keypath];
}

- (void)replaceBodyLayers:(NSString* )bodyImgURL
     replacementLayersURL:(NSArray* )bodyLayers
{
    UIImage* maskedImage = [UIImage imageWithContentsOfFile:bodyImgURL];
    
    for (NSString *layerName in bodyLayers ){
        [self setImageToLayer:maskedImage withName:layerName onView:_animationView];
    }
}

- (void)setImageToLayer:(UIImage*)image withName:(NSString *) layerName onView:(LOTAnimationView*)lottieBg
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    int width = 1500;//self.maskedImage.size.width;
    int height = 1500;//self.maskedImage.size.height;
    CGRect imageRect = CGRectMake( -width / 2, -height / 2,  width, height);
    imageView.frame = imageRect;
    imageView.layer.masksToBounds = true;
    //[lottieBg addSubview:imageView toLayerNamed:layerName applyTransform:YES];
    
    LOTKeypath *keypath = [LOTKeypath keypathWithString:layerName];
    [lottieBg addSubview:imageView toKeypathLayer:keypath];
}


# pragma mark Private

- (void)replaceAnimationView:(LOTAnimationView *)next {
  if (_animationView != nil) {
    [_animationView removeFromSuperview];
  }
  _animationView = next;
  [self addSubview: next];
  [_animationView reactSetFrame:self.frame];
  [_animationView setContentMode:UIViewContentModeScaleAspectFit];
  [self applyProperties];
}

- (void)applyProperties {
  _animationView.animationProgress = _progress;
  _animationView.animationSpeed = _speed;
  _animationView.loopAnimation = _loop;
}

@end
