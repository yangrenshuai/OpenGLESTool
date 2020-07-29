//
//  SettingCellView.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/23.
//  Copyright © 2020 apple. All rights reserved.
//

#import "SettingCellView.h"
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
    
    //[self.curValueSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.curValueSlider setTarget:self];
    [self.curValueSlider setContinuous:YES];
    [self.curValueSlider setAction:@selector(onCurValueSliderValueChanged:)];

}

-(void)onCurValueSliderValueChanged:(NSSlider *)sender{
    if(_isIntValue){
        int x = roundf(self.curValueSlider.floatValue);
        //    NSLog(@"onCurValueSliderValueChanged:%d",x);
        self.curValueTextField.floatValue = x;
    }else{
        self.curValueTextField.floatValue = self.curValueSlider.floatValue;
    }
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
}

-(void)onCurTextFieldDidChange:(NSNotification *)notification{
    if(self.curValueTextField.floatValue < self.minValueTextField.floatValue){
        self.curValueTextField.floatValue = self.minValueTextField.floatValue;
    }else if(self.curValueTextField.floatValue < self.maxValueTextField.floatValue){
        self.curValueTextField.floatValue = self.maxValueTextField.floatValue;
    }else{
        self.curValueSlider.floatValue = self.curValueTextField.floatValue;
    }
    if(_isIntValue){
        int x = roundf(self.curValueTextField.floatValue);
        self.curValueTextField.floatValue = x;
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
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self.minValueTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self.curValueTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self.maxValueTextField];
}

-(void)updateValue{
    if(self.animationCheckBox.state == NSControlStateValueOn){
        float interval = [self.animateIntervalTextField floatValue];
        float minValue = [self.minValueTextField floatValue];
        float maxValue = [self.maxValueTextField floatValue];
        float curValue = [self.curValueTextField floatValue];
        curValue = curValue + interval*flag;
        if(curValue > maxValue){
            curValue = maxValue;
            flag = -1;
        }else if(curValue < minValue){
            curValue = minValue;
            flag = 1;
        }
        [self.curValueTextField setFloatValue:curValue];
        [self.curValueSlider setFloatValue:curValue];
    }
}

//- (void)drawRect:(NSRect)dirtyRect {
//    [super drawRect:dirtyRect];
//    // Drawing code here.
//}

@end
