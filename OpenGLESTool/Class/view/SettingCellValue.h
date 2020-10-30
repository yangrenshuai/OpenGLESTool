//
//  SettingCellValue.h
//  OpenGLESTool
//
//  Created by YRS on 2020/10/29.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSBundle.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingCellValue : NSObject

@property (atomic, copy) NSString* uniformName;
@property (nonatomic, assign) int uniformType;
@property (atomic, assign) int uniformIndex;

@property (nonatomic, assign) int totalCnt; // 记录当前uniform总共需要几个参数
@property (nonatomic, assign) int index; // matrix vec4 vec3 vec2 的第几个元素

@property (nonatomic, assign) bool isAutoIncrement;

@property (nonatomic, assign) bool isIntValue;
@property (nonatomic, assign) bool isFloatValue;
@property (nonatomic, assign) bool isBoolValue;

@property (nonatomic, assign) float value;

@property (nonatomic, assign) float lastCheckValue;

@property (nonatomic, assign) float maxValue;
@property (nonatomic, assign) float minValue;

@property (nonatomic, assign) float autoIncrementValue; // 自增量

-(void)updateValue;
@end

NS_ASSUME_NONNULL_END
