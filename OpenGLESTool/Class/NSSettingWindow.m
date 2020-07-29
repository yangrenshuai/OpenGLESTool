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

@interface NSSettingWindow ()<NSWindowDelegate>

@property (strong) IBOutlet NSScrollView *topScrollView;

@property (strong) IBOutlet NSView *bottomView;

@end

@implementation NSSettingWindow{
    NSObject* uniformObserver;
    NSObject* uniformIndexObserver;
    NSWindow* window;
    NSView* documentView;
    CVDisplayLinkRef displayLink;
    int flushFrame;
    int flushCnt;
}

-(instancetype)init{
    self = [super init];
    if(self){
        NSLog(@"NSSettingWindow init");
    }
    return self;
}

//- (instancetype)initWithFrame:(NSRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        NSLog(@"NSSettingWindow initWithFrame");
//    }
//    return self;
//}

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
    
    flushFrame = 0;
    flushCnt = 0;
    //[self updateScrollView];
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void*)self);
    
    //CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
    // Activate the display link
    CVDisplayLinkStart(displayLink);
    
    // Register to be notified when the window closes so we can stop the displaylink
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:[self window]];
    
    // char* ch = glGetString(GL_SHADING_LANGUAGE_VERSION);
        
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                      const CVTimeStamp* now,
                                      const CVTimeStamp* outputTime,
                                      CVOptionFlags flagsIn,
                                      CVOptionFlags* flagsOut,
                                      void* displayLinkContext)
{
    CVReturn result = [(__bridge NSSettingWindow*)displayLinkContext updateUniformValue];
    return result;
}

-(void)windowWillClose:(NSNotification *)notification{
    NSLog(@"NSSettingWindow windowWillClose");
    
    //    if(_delegate!=nil){
    //        [_delegate onDeleteColorDialogWillClose];
    //    }
    //    _delegate = nil;
    
    //[NSApp stop:self];
    //[NSApp stopModal];会报错啊
    
    
    
    // Stop the display link when the window is closing because default
    // OpenGL render buffers will be destroyed.  If display link continues to
    // fire without renderbuffers, OpenGL draw calls will set errors.
    CVDisplayLinkStop(displayLink);
}

-(CVReturn)updateUniformValue{
    if(flushFrame==0){ // 两次刷新一下,约30Fps
        flushFrame = 1;
        return kCVReturnSuccess;
    }
    flushFrame = 0;
    
    //flushCnt++;
    //NSLog(@"updateUniformValue:%d",flushCnt);
    
    
    // There is no autorelease pool when this method is called
    // because it will be called from a background thread.
    // It's important to create one or app can leak objects.
    @autoreleasepool {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSArray* views = self.bottomView.subviews;
            for(int i=0;i<views.count;i++){
                SettingCellView* cellView = (SettingCellView*)views[i];
                if(!cellView.isHidden){
                    [cellView updateValue];
                }
            }
        });
    }
    return kCVReturnSuccess;
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
    if(_uniformDict!=nil){
        NSUInteger maxCnt = self.uniformDict.count;
        
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
            documentView.frame = CGRectMake(0,0, self.topScrollView.frame.size.width, totalHeight);
        }
        subViews = [documentView subviews];
        for (int i=0; i<subViews.count; i++) {
            
            NSButton* imgView = (NSButton*)[subViews objectAtIndex:i];
            float y = totalHeight - vSpace - itemHeight - i * (itemHeight+vSpace);
            imgView.frame = CGRectMake(hSpace, y, itemWidth, itemHeight);
            imgView.tag = 0x2000+i;
            [imgView setTitle:self.uniformDict.allKeys[i]];
        }
        [self.topScrollView scrollToTop];
    }
}

-(void)onUniformNameClick:(NSButton*)sender{
    long selectIndex = ((NSView*)sender).tag-0x2000;
    NSLog(@"onUniformNameClick tag:%ld", selectIndex);
    
    if(self.uniformDict!=nil && self.uniformIndexDict!=nil && selectIndex<self.uniformDict.count){
        
        int type = [[self.uniformDict objectForKey:self.uniformDict.allKeys[selectIndex]] intValue];
        
        int cnt = [NSSettingWindow getUniformCnt:type];
        
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
        
        views = self.bottomView.subviews;
        for (int i=0; i<cnt; i++) {
            SettingCellView* cellView = (SettingCellView*)views[i];
            [views[i] setHidden:false];
            [cellView setTitle:[NSSettingWindow getName:type withIndex:i]];
            cellView.isIntValue = [NSSettingWindow isIntUniform:type];
            cellView.isFloatValue = [NSSettingWindow isFloatUniform:type];
            cellView.isBoolValue = [NSSettingWindow isBoolUniform:type];
            
            int row = i / cols;
            int col = i % cols;
            
            float x = hSpace + col * (hSpace + itemWidth);
            float y = _bottomView.frame.size.height - vSpace - itemHeight - row * (vSpace + itemHeight);
            cellView.frame = CGRectMake(x, y, itemWidth, itemHeight);
        }
        
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

+(bool)isIntUniform:(int)type{
    if(type == GL_INT_VEC2
    || type == GL_INT_VEC3
    || type == GL_INT_VEC4
    || type == GL_BOOL
    || type == GL_SAMPLER_2D
    || type == GL_SAMPLER_CUBE )
        return true;
    return false;
}

+(bool)isBoolUniform:(int)type{
    if(type == GL_BOOL_VEC2
       || type == GL_BOOL_VEC3
       || type == GL_BOOL_VEC4
       || type == GL_INT )
        return true;
    return false;
}

+(bool)isFloatUniform:(int)type{
    if(type == GL_FLOAT_VEC2
       || type == GL_FLOAT_VEC3
       || type == GL_FLOAT_VEC4
       || type == GL_FLOAT
       || type == GL_FLOAT_MAT2
       || type == GL_FLOAT_MAT3
       || type == GL_FLOAT_MAT4)
        return true;
    return false;
}

+(int)getUniformCnt:(int)type{
    int cnt = 1;
    switch(type){
        case GL_FLOAT:
            cnt = 1;
            break;
        case GL_FLOAT_VEC2:
            cnt = 2;
            break;
        case  GL_FLOAT_VEC3:
            cnt = 3;
            break;
        case  GL_FLOAT_VEC4:
            cnt = 4;
            break;
        case GL_INT:
            cnt = 1;
            break;
        case  GL_INT_VEC2:
            cnt = 2;
            break;
        case  GL_INT_VEC3:
            cnt = 3;
            break;
        case  GL_INT_VEC4:
            cnt = 4;
            break;
        case GL_BOOL:
            cnt = 1;
            break;
        case GL_BOOL_VEC2:
            cnt = 2;
            break;
        case GL_BOOL_VEC3:
            cnt = 3;
            break;
        case GL_BOOL_VEC4:
            cnt = 4;
            break;
        case GL_FLOAT_MAT2:
            cnt = 4;
            break;
        case GL_FLOAT_MAT3:
            cnt = 9;
            break;
        case  GL_FLOAT_MAT4:
            cnt = 16;
            break;
        case  GL_SAMPLER_2D:
            cnt = 1;
            break;
        case GL_SAMPLER_CUBE:
            cnt = 1;
            break;
        default:
            break;
    }
    return cnt;
}

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
