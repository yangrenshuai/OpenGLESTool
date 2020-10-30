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

//@protocol NSSettingWindowDelegate <NSObject>
//-(void)onUniformValueChanged:(NSString*)uniformName withIndex:(int)index withType:(int)type withValue:(NSArray*) numbers;
//@end

@interface NSSettingWindow : NSWindowController

//@property(nonatomic,assign)id<NSSettingWindowDelegate>delegate;

@property (nonatomic, retain) NSArray* uniformNameArray;
@property (nonatomic, retain) NSDictionary* uniformValueDict;

-(void)onUniformUpdate:(NSNotification*)ntf;
-(void)updateScrollView;
-(void)updateUniformValue;
@end

NS_ASSUME_NONNULL_END
