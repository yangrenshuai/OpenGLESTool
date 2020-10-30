//
//  SettingCellView.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/23.
//  Copyright © 2020 apple. All rights reserved.
//

#import "SettingCellView.h"
#import <GLUT/GLUT.h>
#import "math.h"

@implementation SettingCellView{
    float flag;
}

// Convenience Method
+ (instancetype)viewFromNIB {
    // 加载xib中的视图，其中xib文件名和本类类名必须一致
    // 这个xib文件的File's Owner必须为空
    // 这个xib文件必须只拥有一个视图，并且该视图的class为本类
    NSMutableArray* views = [[NSMutableArray array]init];
    if([[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil topLevelObjects:&views]){
    //NSArray *views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
        for (int i=0; i<views.count; i++) {
            if([views[i] isKindOfClass:[NSView class]]){
                return views[i];
            }
        }
    }
    return nil;
}

- (void)awakeFromNib {
    // 视图内容布局
    //self.backgroundColor = [UIColor yellowColor];
    //self.titleLabel.textColor = [UIColor whiteColor];
    
    flag = 1;
    
    self.curValueSlider.minValue = 0;
    self.curValueSlider.maxValue = 1.0;
    self.curValueSlider.floatValue = 0;
    
    self.minValueTextField.floatValue = 0;
    self.maxValueTextField.floatValue = 1;
    self.animationCheckBox.state = NSControlStateValueOff;
    self.animateIntervalTextField.floatValue = 0.01;
    
    _isIntValue = false;
    _isFloatValue = true;
    _isBoolValue = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMinTextFieldDidChange:) name:NSControlTextDidEndEditingNotification object:self.minValueTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCurTextFieldDidChange:) name:NSControlTextDidEndEditingNotification object:self.curValueTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMaxTextFieldDidChange:) name:NSControlTextDidEndEditingNotification object:self.maxValueTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAnimateIntervalTextFieldDidChange:) name:NSControlTextDidEndEditingNotification object:self.animateIntervalTextField];
    
    [self.animationCheckBox setTarget:self];
    [self.animationCheckBox setAction:@selector(onAnimationCheckBoxClicked)];
    
    //[self.curValueSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.curValueSlider setTarget:self];
    [self.curValueSlider setContinuous:YES];
    [self.curValueSlider setAction:@selector(onCurValueSliderValueChanged:)];

}

-(void)onAnimationCheckBoxClicked{
    if(_settingValue!=nil)
    {
        if(self.animationCheckBox.state == NSControlStateValueOn){
            _settingValue.isAutoIncrement = true;
        }else{
            _settingValue.isAutoIncrement = false;
        }
    }
}

-(void)onCurValueSliderValueChanged:(NSSlider *)sender{
    if(_isIntValue){
        self.curValueTextField.floatValue = self.curValueSlider.floatValue;
    }else{
        self.curValueTextField.floatValue = self.curValueSlider.floatValue;
    }
    [self onCurTextFieldDidChange:nil];
}

-(void)setTitle:(NSString*)title{
    self.titleLabel.stringValue = title;
}
    
-(void)onMinTextFieldDidChange:(NSNotification *)notification{
    if(self.minValueTextField.floatValue > self.maxValueTextField.floatValue){
        self.minValueTextField.floatValue = self.maxValueTextField.floatValue;
    }
    self.curValueSlider.minValue = self.minValueTextField.floatValue;
    if(self.curValueTextField.floatValue < self.minValueTextField.floatValue){
        self.curValueTextField.floatValue = self.minValueTextField.floatValue;
        if(_isIntValue){
            int x = roundf(self.curValueTextField.floatValue);
            self.curValueTextField.floatValue = x;
        }
    }
    if(_settingValue!=nil){
        if(_isIntValue){
            _settingValue.value = roundf(self.curValueTextField.floatValue);
            _settingValue.minValue = roundf(self.minValueTextField.floatValue);
        }else if(_isFloatValue){
            _settingValue.value = self.curValueTextField.floatValue;
            _settingValue.minValue = self.minValueTextField.floatValue;
        }else{
            _settingValue.value = self.curValueTextField.floatValue>0.5?1:0;
            self.minValueTextField.floatValue = 0;
            self.maxValueTextField.floatValue = 1;
            _settingValue.minValue = 0;
            _settingValue.maxValue = 1;
            self.curValueTextField.floatValue = _settingValue.value;
        }
        self.curValueSlider.floatValue = self.curValueTextField.floatValue;
    }
}

-(void)onCurTextFieldDidChange:(NSNotification *)notification{
    if(self.curValueTextField.floatValue < self.minValueTextField.floatValue){
        self.curValueTextField.floatValue = self.minValueTextField.floatValue;
    }else if(self.curValueTextField.floatValue > self.maxValueTextField.floatValue){
        self.curValueTextField.floatValue = self.maxValueTextField.floatValue;
    }else{
        self.curValueSlider.floatValue = self.curValueTextField.floatValue;
    }
    if(_isIntValue){
        int x = roundf(self.curValueTextField.floatValue);
        self.curValueTextField.floatValue = x;
    }
    if(_settingValue!=nil){
        if(_isIntValue){
            _settingValue.value = roundf(self.curValueTextField.floatValue);
        }else if(_isFloatValue){
            _settingValue.value = self.curValueTextField.floatValue;
        }else{
            if(self.curValueTextField.floatValue > 0.5){
                _settingValue.value = 1;
            }else{
                _settingValue.value = 0;
            }
        }
        self.curValueSlider.floatValue = self.curValueTextField.floatValue;
    }
}

-(void)onMaxTextFieldDidChange:(NSNotification *)notification{
    if(self.minValueTextField.floatValue > self.maxValueTextField.floatValue){
        self.maxValueTextField.floatValue = self.minValueTextField.floatValue;
    }
    self.curValueSlider.maxValue = self.maxValueTextField.floatValue;
    if(self.curValueTextField.floatValue > self.maxValueTextField.floatValue){
        self.curValueTextField.floatValue = self.maxValueTextField.floatValue;
        if(_isIntValue){
            int x = roundf(self.curValueTextField.floatValue);
            self.curValueTextField.floatValue = x;
        }
    }
    if(_settingValue!=nil){
        if(_isIntValue){
            _settingValue.value = roundf(self.curValueTextField.floatValue);
            _settingValue.maxValue = roundf(self.maxValueTextField.floatValue);
        }else if(_isFloatValue){
            _settingValue.value = self.curValueTextField.floatValue;
            _settingValue.maxValue = self.maxValueTextField.floatValue;
        }else{
            _settingValue.value = self.curValueTextField.floatValue>0.5?1:0;
            self.minValueTextField.floatValue = 0;
            self.maxValueTextField.floatValue = 1;
            _settingValue.minValue = 0;
            _settingValue.maxValue = 1;
            self.curValueTextField.floatValue = _settingValue.value;
        }
        self.curValueSlider.floatValue = self.curValueTextField.floatValue;
    }
}

-(void)onAnimateIntervalTextFieldDidChange:(NSNotification *)notification{
    if(_settingValue!=nil){
        _settingValue.autoIncrementValue = self.animateIntervalTextField.floatValue;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self.minValueTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self.curValueTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self.maxValueTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self.animateIntervalTextField];
}

-(void)resetValue{
    if(_settingValue!=nil){
        self.isIntValue = _settingValue.isIntValue;
        self.isFloatValue = _settingValue.isFloatValue;
        self.isBoolValue = _settingValue.isBoolValue;
        self.titleLabel.stringValue = [SettingCellView getName:_settingValue.uniformType withIndex:_settingValue.index];
        if (_settingValue.isIntValue) {
            self.minValueTextField.floatValue = roundf(_settingValue.minValue);
            self.maxValueTextField.floatValue = roundf(_settingValue.maxValue);
            self.curValueTextField.floatValue = roundf(_settingValue.value);
            self.animationCheckBox.state = _settingValue.isAutoIncrement ? NSControlStateValueOn : NSControlStateValueOff;
            self.animateIntervalTextField.floatValue = _settingValue.autoIncrementValue;
            
            self.curValueSlider.maxValue = roundf(self.maxValueTextField.floatValue);
            self.curValueSlider.minValue = roundf(self.minValueTextField.floatValue);
            self.curValueSlider.floatValue = roundf(self.curValueTextField.floatValue);
        }else if(_settingValue.isFloatValue){
        
            self.minValueTextField.floatValue = _settingValue.minValue;
            self.maxValueTextField.floatValue = _settingValue.maxValue;
            self.curValueTextField.floatValue = _settingValue.value;
            self.animationCheckBox.state = _settingValue.isAutoIncrement ? NSControlStateValueOn : NSControlStateValueOff;
            self.animateIntervalTextField.floatValue = _settingValue.autoIncrementValue;
            
            self.curValueSlider.maxValue = self.maxValueTextField.floatValue;
            self.curValueSlider.minValue = self.minValueTextField.floatValue;
            self.curValueSlider.floatValue = self.curValueTextField.floatValue;
        }else{ // bool
            self.minValueTextField.floatValue = 0;
            self.maxValueTextField.floatValue = 1;
            self.curValueTextField.floatValue = _settingValue.value > 0.5 ? 1: 0;
            self.animationCheckBox.state = _settingValue.isAutoIncrement ? NSControlStateValueOn : NSControlStateValueOff;
            self.animateIntervalTextField.floatValue = 1;
            
            self.curValueSlider.maxValue = 1;
            self.curValueSlider.minValue = 0;
            self.curValueSlider.floatValue = self.curValueTextField.floatValue;
        }
    }
}

-(void)updateValue{
    if(self.animationCheckBox.state == NSControlStateValueOn){
//        float interval = [self.animateIntervalTextField floatValue];
//        float minValue = [self.minValueTextField floatValue];
//        float maxValue = [self.maxValueTextField floatValue];
//        float curValue = [self.curValueTextField floatValue];
//        curValue = curValue + interval*flag;
//        if(curValue > maxValue){
//            curValue = maxValue;
//            flag = -1;
//        }else if(curValue < minValue){
//            curValue = minValue;
//            flag = 1;
//        }
        float curValue = self.settingValue.value;
        [self.curValueTextField setFloatValue:curValue];
        [self.curValueSlider setFloatValue:curValue];
    }
}

//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//    // Drawing code here.
//}

+(NSString*)getName:(int)type withIndex:(int)index{
    NSArray* names = @[@"x",@"y",@"z",@"w"];
    NSString* name = @" ";
    switch(type){
        case GL_FLOAT:
            break;
        case GL_FLOAT_VEC2:
        case  GL_FLOAT_VEC3:
        case  GL_FLOAT_VEC4:
            name = names[index];
            break;
        case GL_INT:
            break;
        case  GL_INT_VEC2:
        case  GL_INT_VEC3:
        case  GL_INT_VEC4:
            name = names[index];
            break;
        case GL_BOOL:
            break;
        case GL_BOOL_VEC2:
        case GL_BOOL_VEC3:
        case GL_BOOL_VEC4:
            name = names[index];
            break;
        case GL_FLOAT_MAT2:
        case GL_FLOAT_MAT3:
        case  GL_FLOAT_MAT4:
            name = [NSString stringWithFormat:@"%d",index];
        case  GL_SAMPLER_2D:
            
            break;
        case GL_SAMPLER_CUBE:
            break;
        default:
            break;
    }
    return name;
}

@end
