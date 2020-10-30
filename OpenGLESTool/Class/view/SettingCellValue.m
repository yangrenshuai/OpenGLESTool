//
//  SettingCellValue.m
//  OpenGLESTool
//
//  Created by YRS on 2020/10/29.
//  Copyright © 2020 apple. All rights reserved.
//

#import "SettingCellValue.h"

@implementation SettingCellValue

-(id)init{
    self = [super init];
    if(self){
        self.index = 0;
        
        //self.uniformType = ;
        self.uniformIndex = 0;
        
        self.isAutoIncrement = false;
        self.autoIncrementValue = 0.033;
        
        self.isIntValue = false;
        self.isFloatValue = false;
        self.isBoolValue = false;
        
        self.value = 0;
        
        self.minValue = 0;
        self.maxValue = 1;
        self.lastCheckValue = -1;
        
    }
    return self;
}

- (void)setIsBoolValue:(bool)isBoolValue{
    _isBoolValue = isBoolValue;
    if(_isBoolValue){
        _isIntValue = false;
        _isFloatValue = false;
    }
}

- (void)setIsIntValue:(bool)isIntValue{
    _isIntValue = isIntValue;
    if(isIntValue){
        _isFloatValue = false;
        _isBoolValue = false;
        //_autoIncrementValue = 1;
    }
}

-(void)setIsFloatValue:(bool)isFloatValue{
    _isFloatValue = isFloatValue;
    if(isFloatValue){
        _isIntValue = false;
        _isBoolValue = false;
    }
}

-(void)updateValue{
    if(_isAutoIncrement){
        if(_isIntValue){
//            int m = roundf(_maxValue);
//            int f = _value + roundf(_autoIncrementValue);
//            if(f > m){
//                f = roundf(_minValue);
//            }
//            _value = f;
            float f = _value + _autoIncrementValue;
            if(f > _maxValue){
                f = _minValue;
            }
            _value = f;
        }else if(_isFloatValue){
            float f = _value + _autoIncrementValue;
            if(f > _maxValue){
                f = _minValue;
            }
            _value = f;
        }else{ // boolean
            if(_value>0.5){
                _value = 1;
            }else{
                _value = 0;
            }
        }
    }
}

@end
