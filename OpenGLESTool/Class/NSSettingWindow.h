//
//  NSSettingWindow.h
//  OpenGLESTool
//
//  Created by apple on 2020/7/23.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

#define UPDATE_SHADER_UNIFORM "UPDATE_SHADER_UNIFORM";
#define UPDATE_SHADER_UNIFORM_INDEX "UPDATE_SHADER_UNIFORM_INDEX";

@protocol NSSettingWindowDelegate <NSObject>
-(void)onUniformValueChanged:(NSString*)uniformName withIndex:(int)index withType:(int)type withValue:(NSNumber*) number;
//-(void)onSettingWindowClosed;
@end

@interface NSSettingWindow : NSWindowController

@property(nonatomic,assign)id<NSSettingWindowDelegate>delegate;

@property (nonatomic, retain) NSMutableDictionary* uniformDict;
@property (nonatomic, retain) NSMutableDictionary* uniformIndexDict;

-(void)onUniformUpdate:(NSNotification*)ntf;
-(void)updateScrollView;

@end

NS_ASSUME_NONNULL_END
