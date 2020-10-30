//
//  NSSettingWindow.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/23.
//  Copyright © 2020 apple. All rights reserved.
//

#import "NSSettingWindow.h"
#import "NSScrollView+NSSTools.h"
#import "SettingCellView.h"
#import <GLUT/GLUT.h>
#import "SettingCellValue.h"

@interface NSSettingWindow ()<NSWindowDelegate>

@property (strong) IBOutlet NSScrollView *topScrollView;

@property (strong) IBOutlet NSView *bottomView;

@end

@implementation NSSettingWindow{
    NSObject* uniformObserver;
    NSObject* uniformIndexObserver;
    NSWindow* window;
    NSView* documentView;
    NSButton* selBtn;
    NSRecursiveLock* lock;
}

-(instancetype)init{
    self = [super init];
    if(self){
        lock = [[NSRecursiveLock alloc]init];
        //_valueDict = [NSMutableDictionary dictionary];
        NSLog(@"NSSettingWindow init");
    }
    return self;
}

//-(void)setUniformDict:(NSMutableDictionary *)uniformDict{
//    _uniformDict = uniformDict;
//}

//- (instancetype)initWithFrame:(NSRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        NSLog(@"NSSettingWindow initWithFrame");
//    }
//    return self;
//}

- (void)setUniformValueDict:(NSDictionary *)uniformValueDict
{
    [lock lock];
    //[_valueDict removeAllObjects];
    _uniformValueDict = [[NSMutableDictionary alloc] initWithDictionary:uniformValueDict];
    [lock unlock];
}

- (void)setUniformNameArray:(NSArray *)uniformNameArray{
    [lock lock];
    _uniformNameArray = [[NSArray alloc] initWithArray:uniformNameArray];
    [lock unlock];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    
    NSArray<NSWindow *>* windows = [NSApplication sharedApplication].windows;
    for (NSWindow *win in windows){
        if([win.title isEqualToString:[NSSettingWindow className]]){
            window = win;
            window.delegate = self;
            break;
        }
    }
    
    NSLog(@"NSSettingWindow awakeFromNib!");
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUniformUpdate:) name:@"UPDATE_SHADER_UNIFORM" object:nil];
    
    _topScrollView.backgroundColor = [NSColor colorWithWhite:0.2 alpha:1.0];
    
    [_topScrollView setVerticalContentSizeConstraintActive:true];
    _topScrollView.scrollerStyle = NSScrollerStyleOverlay;
    _topScrollView.hasVerticalScroller = true;
    _topScrollView.hasHorizontalScroller = false;
    _topScrollView.scrollerKnobStyle  = NSScrollerKnobStyleDark;
    _topScrollView.horizontalScrollElasticity = NSScrollElasticityAutomatic;
    documentView = [[NSView alloc]init];
    _topScrollView.documentView = documentView;
    
    //[self updateScrollView];
    
    // Register to be notified when the window closes so we can stop the displaylink
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:[self window]];
    
    // char* ch = glGetString(GL_SHADING_LANGUAGE_VERSION);
        
}

-(void)windowWillClose:(NSNotification *)notification{
    NSLog(@"NSSettingWindow windowWillClose");
    
    //    if(_delegate!=nil){
    //        [_delegate onDeleteColorDialogWillClose];
    //    }
    //    _delegate = nil;
    
    //[NSApp stop:self];
    //[NSApp stopModal];会报错啊
    
    
    
    
}

-(void)updateUniformValue{
    if(_uniformValueDict!=nil){
        NSArray* views = self.bottomView.subviews;
        for(int i=0;i<views.count;i++){
            SettingCellView* cellView = (SettingCellView*)views[i];
            if(!cellView.isHidden){
                [cellView updateValue];
            }
        }
    }
}

- (void)windowDidResize:(NSNotification *)notification{
    NSLog(@"-----NSSettingWindow----!rect:%@",NSStringFromRect(self.window.frame));
    
    self.topScrollView.frame = CGRectMake(5, self.window.frame.size.height-190, self.window.frame.size.width-10, 180);
    self.bottomView.frame = CGRectMake(5, 5, self.window.frame.size.width-10, self.window.frame.size.height-195);
}

- (BOOL)windowShouldClose:(NSWindow *)sender{
    NSLog(@"-----NSSettingWindow----!cls:%@",sender.className);
    return true;
}

-(void)onUniformUpdate:(NSNotification*)ntf{
    NSLog(@"NSSettingWindow get NSNotification UPDATE_SHADER_UNIFORM!");
    [self updateScrollView];
}

-(void)dealloc{
    NSLog(@"NSSettingWindow dealloc");
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_SHADER_UNIFORM" object:nil];
}

-(void) updateScrollView{
    if(_uniformNameArray!=nil){
                
        NSUInteger maxCnt = self.uniformNameArray.count;
        
        NSArray* subViews = [documentView subviews];
        
        int itemWidth = self.topScrollView.frame.size.width - 10;
        int itemHeight = 30;
        float hSpace = 5;
        float vSpace = 5;
        
        int totalHeight = vSpace + maxCnt * (vSpace + itemHeight);
        if(totalHeight < self.topScrollView.frame.size.height){
            totalHeight = self.topScrollView.frame.size.height;
        }
        if(subViews.count > maxCnt){
            for(NSUInteger i=maxCnt;i<subViews.count;i++){
                NSView* view = subViews[i];
                [view removeFromSuperview];
            }
        }else if(subViews.count < maxCnt){
            documentView.frame = CGRectMake(0,0, self.topScrollView.frame.size.width, totalHeight);
            for (NSUInteger i=subViews.count; i<maxCnt; i++) {
                float y = totalHeight - vSpace - itemHeight - i * (itemHeight+vSpace);
                NSButton* imgView = [[NSButton alloc] initWithFrame:CGRectMake(hSpace, y, itemWidth, itemHeight)];
                //imgView.delegate = self;
                [imgView setButtonType:NSButtonTypeOnOff];
                imgView.wantsLayer = true;
                //imgView.layer.borderColor = [[NSColor colorWithWhite:0.5 alpha:1.0] CGColor];
                //imgView.layer.borderWidth = 2;
                imgView.layer.backgroundColor = [[NSColor colorWithWhite:0.5 alpha:1.0] CGColor];
                [documentView addSubview:imgView];
                [imgView setTarget:self];
                [imgView setImageScaling:NSImageScaleProportionallyUpOrDown];
                [imgView setAction:@selector(onUniformNameClick:)];
                
            }
            //rightImgScrollView.contentSize = CGSizeMake(rightImgScrollView.frame.size.width, vSpace + maxCnt * (vSpace + itemHeight));
            
        }
        subViews = [documentView subviews];
        for (int i=0; i<subViews.count; i++) {
            
            NSButton* imgView = (NSButton*)[subViews objectAtIndex:i];
            float y = totalHeight - vSpace - itemHeight - i * (itemHeight+vSpace);
            imgView.frame = CGRectMake(hSpace, y, itemWidth, itemHeight);
            imgView.tag = 0x2000+i;
            [imgView setTitle:self.uniformNameArray[i]];
            
            // 创建段落样式，主要是为了设置居中
            NSMutableParagraphStyle* pghStyle = [[NSMutableParagraphStyle alloc] init];
            pghStyle.alignment = NSTextAlignmentCenter;
            // 创建Attributes，设置颜色和段落样式
            NSDictionary* dicAtt = @{NSForegroundColorAttributeName: [NSColor whiteColor], NSParagraphStyleAttributeName: pghStyle, NSFontAttributeName:[NSFont systemFontOfSize:20]};
            // 创建NSAttributedString赋值给NSButton的attributedTitle属性
            imgView.attributedTitle = [[NSAttributedString alloc] initWithString:self.uniformNameArray[i] attributes:dicAtt];
        }
        [self.topScrollView scrollToTop];
        
        subViews = [documentView subviews];
        if(subViews.count>0){
            //[self onUniformNameClick:(NSButton *)[subViews objectAtIndex:0]];// 重新加载uniform数据
        }
    }
}

-(void)onUniformNameClick:(NSButton*)sender{
    long selectIndex = ((NSView*)sender).tag-0x2000;
    NSLog(@"onUniformNameClick tag:%ld", selectIndex);
    if(selBtn!=nil){
        // 创建段落样式，主要是为了设置居中
        NSMutableParagraphStyle* pghStyle = [[NSMutableParagraphStyle alloc] init];
        pghStyle.alignment = NSTextAlignmentCenter;
        // 创建Attributes，设置颜色和段落样式
        NSDictionary* dicAtt = @{NSForegroundColorAttributeName: [NSColor whiteColor], NSParagraphStyleAttributeName: pghStyle, NSFontAttributeName:[NSFont systemFontOfSize:20]};
        // 创建NSAttributedString赋值给NSButton的attributedTitle属性
        selBtn.attributedTitle = [[NSAttributedString alloc] initWithString:selBtn.title attributes:dicAtt];
    }
    selBtn = sender;
    if(selBtn!=nil){
        // 创建段落样式，主要是为了设置居中
        NSMutableParagraphStyle* pghStyle = [[NSMutableParagraphStyle alloc] init];
        pghStyle.alignment = NSTextAlignmentCenter;
        // 创建Attributes，设置颜色和段落样式
        NSDictionary* dicAtt = @{NSForegroundColorAttributeName: [NSColor greenColor], NSParagraphStyleAttributeName: pghStyle, NSFontAttributeName:[NSFont systemFontOfSize:20]};
        // 创建NSAttributedString赋值给NSButton的attributedTitle属性
        selBtn.attributedTitle = [[NSAttributedString alloc] initWithString:selBtn.title attributes:dicAtt];
    }
    if(self.uniformValueDict!=nil && self.uniformNameArray!=nil && selectIndex<self.uniformNameArray.count){
        
        NSString* key = self.uniformNameArray[selectIndex];
        SettingCellValue* val = [self.uniformValueDict objectForKey:[NSString stringWithFormat:@"%@_%d",key,0]];
        if(val==nil){
            NSLog(@"onUniformNameClick uniformValueDict not found value:%@", [NSString stringWithFormat:@"%@_%d",key,0]);
            return;
        }
        int type = val.uniformType;
        
        int cnt = val.totalCnt;
        
        NSArray* views = self.bottomView.subviews;
        if(views.count > cnt){
            for (int i=cnt; i<views.count; i++) {
                [views[i] setHidden:true];
            }
        }else if(views.count < cnt){
            for (NSUInteger i=views.count; i<cnt; i++) {
                SettingCellView* cell = [SettingCellView viewFromNIB];
                cell.frame = CGRectMake(0, 0, 150, 80);
                cell.wantsLayer = YES;
                //cell.layer.backgroundColor = [[NSColor purpleColor] CGColor];
                [self.bottomView addSubview:cell];
            }
        }
        
        int itemWidth = 150;
        int itemHeight = 80;
        float hSpace = 5;
        float vSpace = 5;
        
        int cols = 1;
        if(cnt == 4){
            cols = 2;
        }
        
        if(cnt == 9){
            cols = 3;
        }
        
        if(cnt == 16){
            cols = 4;
        }
        
        [lock lock];
        views = self.bottomView.subviews;
        for (int i=0; i<cnt; i++) {
            SettingCellView* cellView = (SettingCellView*)views[i];
            [views[i] setHidden:false];
            cellView.settingValue = [_uniformValueDict objectForKey:[NSString stringWithFormat:@"%@_%d",key,i]];
            [cellView resetValue];
//            [cellView setTitle:[NSSettingWindow getName:type withIndex:i]];
////            cellView.isIntValue = [NSSettingWindow isIntUniform:type];
////            cellView.isFloatValue = [NSSettingWindow isFloatUniform:type];
////            cellView.isBoolValue = [NSSettingWindow isBoolUniform:type];
//
//            cellView.isIntValue = cellView.settingValue.isIntValue;
//            cellView.isFloatValue = cellView.settingValue.isFloatValue;
//            cellView.isBoolValue = cellView.settingValue.isBoolValue;
            
            
            int row = i / cols;
            int col = i % cols;
            
            float x = hSpace + col * (hSpace + itemWidth);
            float y = _bottomView.frame.size.height - vSpace - itemHeight - row * (vSpace + itemHeight);
            cellView.frame = CGRectMake(x, y, itemWidth, itemHeight);
        }
        [lock unlock];
        
        int w = self.window.frame.size.width;
        int vw = hSpace + cnt/cols * (hSpace + itemWidth);
        if(w < vw){
            w = vw;
        }
        
        int h = self.window.frame.size.height;
        int vh = cnt / cols;
        if(vh * cols < cnt){
            vh ++;
        }
        vh = vh * (vSpace + itemHeight) + vSpace + 195;
        if(h < vh){
            h = vh;
        }
        
        [self.window setFrame:CGRectMake(self.window.frame.origin.x, self.window.frame.origin.y, w, h) display:false];
        [self.window setViewsNeedDisplay:true];
        
    }
}

//-(void)checkValueChanged:(NSArray*) list{
//    //检测并上报值变化
//    if(self.delegate!=nil){
//        NSArray* views = self.bottomView.subviews;
//        for(int i=0;i<views.count;i++){
//            SettingCellView* cellView = (SettingCellView*)views[i];
//            if(!cellView.isHidden){
//                [cellView updateValue];
//                //self.delegate onUniformValueChanged:<#(nonnull NSString *)#> withIndex:<#(int)#> withType:<#(int)#> withValue:<#(nonnull NSArray *)#>
//            }
//        }
//    }
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
