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

RCT_EXPORT_METHOD(replaceBodyLayers:(nonnull NSNumber *)reactTag
                  bodyImgURL:(nonnull NSString *)bodyImgURL
                  layersURL:(nonnull NSString *)layerURL)
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

RCT_EXPORT_METHOD(start:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[LRNContainerView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting LottieContainerView, got: %@", view);
        } else {
            LRNContainerView *lottieView = (LRNContainerView *)view;
            [recorder startWithView:lottieView withCallback:^(NSString* path) {
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                    UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
                }
            }];
            
            [lottieView play];
        }
    }];
}

RCT_EXPORT_METHOD(stop:(nonnull NSNumber *)reactTag){
    [recorder stop];
}

@end
