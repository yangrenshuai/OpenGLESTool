//
//  SettingCellView.h
//  OpenGLESTool
//
//  Created by apple on 2020/7/23.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSBundle.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingCellView : NSView

@property (strong) IBOutlet NSTextField *titleLabel;

@property (strong) IBOutlet NSTextField *minValueTextField;
@property (strong) IBOutlet NSTextField *curValueTextField;
@property (strong) IBOutlet NSTextField *maxValueTextField;

@property (strong) IBOutlet NSSlider *curValueSlider;
@property (strong) IBOutlet NSButton *animationCheckBox;
@property (strong) IBOutlet NSTextField *animateIntervalTextField;

@property (assign) bool isIntValue;
@property (assign) bool isFloatValue;
@property (assign) bool isBoolValue;

+ (instancetype)viewFromNIB;

-(void)setTitle:(NSString*)title;
-(void)updateValue;

@end

NS_ASSUME_NONNULL_END
