//
//  LRNAnimationViewManager.m
//  LottieReactNative
//
//  Created by Leland Richardson on 12/12/16.
//  Copyright © 2016 Airbnb. All rights reserved.
//

#import "LRNAnimationViewManager.h"

#import "LRNContainerView.h"

// import RCTBridge.h
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
#import "RCTBridge.h"
#else
#import "React/RCTBridge.h"
#endif

// import RCTUIManager.h
#if __has_include(<React/RCTUIManager.h>)
#import <React/RCTUIManager.h>
#elif __has_include("RCTUIManager.h")
#import "RCTUIManager.h"
#else
#import "React/RCTUIManager.h"
#endif

#import <Lottie/Lottie.h>

#import "LottieReactNative-Swift.h"

@implementation LRNAnimationViewManager

RCT_EXPORT_MODULE(LottieAnimationView)

ViewRecorder * recorder;

- (UIView *)view
{
    recorder = [[ViewRecorder alloc] init];
    return [LRNContainerView new];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (NSDictionary *)constantsToExport
{
  return @{
    @"VERSION": @1,
  };
}

RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString)
RCT_EXPORT_VIEW_PROPERTY(sourceJson, NSString);
RCT_EXPORT_VIEW_PROPERTY(sourceName, NSString);
RCT_EXPORT_VIEW_PROPERTY(progress, CGFloat);
RCT_EXPORT_VIEW_PROPERTY(loop, BOOL);
RCT_EXPORT_VIEW_PROPERTY(speed, CGFloat);

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag
                  fromFrame:(nonnull NSNumber *) startFrame
                  toFrame:(nonnull NSNumber *) endFrame)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[reactTag];
    if (![view isKindOfClass:[LRNContainerView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting LottieContainerView, got: %@", view);
    } else {
      LRNContainerView *lottieView = (LRNContainerView *)view;
      if ([startFrame intValue] != -1 && [endFrame intValue] != -1) {
        [lottieView playFromFrame:startFrame toFrame:endFrame];
      } else {
        [lottieView play];
      }
    }
  }];
}

RCT_EXPORT_METHOD(reset:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    id view = viewRegistry[reactTag];
    if (![view isKindOfClass:[LRNContainerView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting LottieContainerView, got: %@", view);
    } else {
      LRNContainerView *lottieView = (LRNContainerView *)view;
      [lottieView reset];
    }
  }];
}

RCT_EXPORT_METHOD(replaceColor:(nonnull NSNumber *)reactTag
                  r:(nonnull  NSNumber*)r
                  g:(nonnull  NSNumber*)g
                  b:(nonnull  NSNumber*)b
                  )
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[LRNContainerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting LottieContainerView, got: %@", view);
        } else {
            LRNContainerView *lottieView = (LRNContainerView *)view;
            [lottieView replaceColorR:r g:g b:b];
        }
    }];
}

RCT_EXPORT_METHOD(replaceBodyLayers:(nonnull NSNumber *)reactTag
                  bodyImgURL:(nonnull NSString *)bodyImgURL
                  layersURL:(nonnull NSArray *)layerURL)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[LRNContainerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting LottieContainerView, got: %@", view);
        } else {
            LRNContainerView *lottieView = (LRNContainerView *)view;
            [lottieView replaceBodyLayers:bodyImgURL replacementLayersURL:layerURL];
        }
    }];
}

RCT_EXPORT_METHOD(start:(nonnull NSNumber *)reactTag
                  bgData:(nonnull NSDictionary *)bgData
                  fgData:(nonnull NSDictionary *)fgData
                  )
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[LRNContainerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting LottieContainerView, got: %@", view);
        } else {
            
            LRNContainerView *lottieView = (LRNContainerView *)view;
            
            Boolean hasBG = false;
            UIImageView * bgImageView = nil;
            if ([bgData objectForKey:@"path"]){
                NSString* bgPath = bgData[@"path"];
                UIImage * bgImage = [UIImage imageWithContentsOfFile:bgPath];
                bgImageView =  [[UIImageView alloc] initWithImage:bgImage];
                
                
                if ([bgData objectForKey:@"tintColor"]){
                    NSArray * colorArray = bgData[@"tintColor"];
                    NSNumber * r = colorArray[0] ;
                    NSNumber * g = colorArray[1] ;
                    NSNumber * b = colorArray[2] ;
                    //NSNumber * a = colorArray[3] ;
                    UIColor* color = [UIColor colorWithRed:[r floatValue] green:[g floatValue] blue:[b floatValue] alpha:1.0];
                    [lottieView setBackgroundColor:color];
                } else {
                    hasBG = true;
                    [lottieView addSubview:bgImageView];
                    [lottieView sendSubviewToBack:bgImageView];
                }
                bgImageView.frame = lottieView.frame;
            }
            
            Boolean hasFG = false;
            UIImageView * fgImageView = nil;
            if ([fgData objectForKey:@"path"]){
                hasFG = true;
                NSString* fgPath = fgData[@"path"];
                UIImage * fgImage = [UIImage imageWithContentsOfFile:fgPath];
                
                fgImageView =  [[UIImageView alloc] initWithImage:fgImage];
                
                if ([fgData objectForKey:@"tintColor"]){
                    fgImage = [fgImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    fgImageView =  [[UIImageView alloc] initWithImage:fgImage];
                    NSArray * colorArray = fgData[@"tintColor"];
                    NSNumber * r = colorArray[0] ;
                    NSNumber * g = colorArray[1] ;
                    NSNumber * b = colorArray[2] ;
                    UIColor* color = [UIColor colorWithRed:[r floatValue] green:[g floatValue] blue:[b floatValue] alpha:1.0];
                    fgImageView.tintColor = color;
                }
                
                [lottieView addSubview:fgImageView];
                fgImageView.frame = lottieView.frame;
            }
            
            [lottieView play];
            [recorder startWithView:lottieView withCallback:^(NSString* path) {
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                    UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
                }
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (hasFG){
                        [fgImageView removeFromSuperview];
                    }
                    
                    if (hasBG){
                        [bgImageView removeFromSuperview];
                    }
                    
                });
            }];
        }
    }];
}

RCT_EXPORT_METHOD(stop:(nonnull NSNumber *)reactTag){
    [recorder stop];
}

@end
