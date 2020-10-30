//
//  MainViewController.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/22.
//  Copyright © 2020 apple. All rights reserved.
//

#import "MainViewController.h"
#import "PreviewWindow.h"
#import "OpenGLView.h"
#import "NSScrollView+NSSTools.h"
#import "DragFileInButton.h"
#import "SettingCellView.h"
#import "NSSettingWindow.h"
#import "EditorWindow.h"

@interface MainViewController ()<NSWindowDelegate,DragFileInButtonDelegate,DragFileInEditTextDelegate,EditorWindowDelegate>{ //NSSettingWindowDelegate
    NSWindow * window;
    //OpenGLView* openGlView;
    //NSScrollView* rightImgScrollView;
    NSView* rightImgScrollContainerView;
    //NSMutableArray* imgPathList;
    NSMutableDictionary* imgDict;
    NSMutableArray* imgPathArray;
    NSImage* addImage;
    IBOutlet OpenGLView *openGlView;
    IBOutlet NSScrollView *rightImgScrollView;
    
    NSString* vertexShaderPath;
    NSString* fragmentShaderPath;
    
    NSString* vertexShaderString;
    NSString* fragmentShaderString;
    
//    NSMutableDictionary* uniformDict;
//    NSMutableDictionary* uniformIndexDict;
    
    NSSettingWindow* settingWindow;
    
    EditorWindow* vsEditWindow;
    EditorWindow* fsEditWindow;
    
    CVDisplayLinkRef displayLink;
    int flushFrame;
    int flushCnt;
}
@end

@implementation MainViewController{
    int imgScrollViewWidth;
    bool isInitView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    isInitView = false;
    flushFrame = 0;
    flushCnt = 0;
    vertexShaderPath = nil;
    fragmentShaderPath = nil;
    
    imgPathArray = [[NSMutableArray alloc]initWithCapacity:10];
//    uniformDict = [[NSMutableDictionary alloc]initWithCapacity:10];
//    uniformIndexDict = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    window = [NSApplication sharedApplication].windows[0];
    window.delegate = self;

    addImage = [NSImage imageNamed:@"add.png"];
    
    
    imgScrollViewWidth = 110;
//    rightImgScrollView = [[NSScrollView alloc]init];
    rightImgScrollView.backgroundColor = [NSColor colorWithWhite:0.2 alpha:1.0];
    
    [rightImgScrollView setVerticalContentSizeConstraintActive:true];
    rightImgScrollView.scrollerStyle = NSScrollerStyleOverlay;
    rightImgScrollView.hasVerticalScroller = true;
    rightImgScrollView.hasHorizontalScroller = false;
    rightImgScrollView.scrollerKnobStyle  = NSScrollerKnobStyleDark;
    rightImgScrollView.horizontalScrollElasticity = NSScrollElasticityAutomatic;
    rightImgScrollContainerView = [[NSView alloc]init];
    rightImgScrollView.documentView = rightImgScrollContainerView;
//    [self.view addSubview:rightImgScrollView];
//    openGlView = [[OpenGLView alloc]init];
//    [self.view addSubview:openGlView];
    
    
    [self.vertexShaderPath setShaderType:@"Vertex"];
    self.vertexShaderPath.dragDelegate = self;
    
    [self.fragmentShaderPath setShaderType:@"Fragement"];
    self.fragmentShaderPath.dragDelegate = self;
    
    
    self.infoListTexView.editable = false;
    
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"Shader3" ofType:@"vs"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"Shader3" ofType:@"frag"];
    
    vertexShaderString = [NSString stringWithContentsOfFile:vertFile encoding:NSUTF8StringEncoding error:nil];
    fragmentShaderString = [NSString stringWithContentsOfFile:fragFile encoding:NSUTF8StringEncoding error:nil];
    NSError* error;
    [openGlView setVertexShader:vertexShaderString fragmentShader:fragmentShaderString error:&error];
    if(error){
        self.infoListTexView.string = error.description;
    }else{
        self.infoListTexView.string = @"Compile Success!";
    }
    
    imgDict = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString* key1 = @"test.tiff";
    NSString* key2 = @"test2.png";
    [imgDict setObject:[NSImage imageNamed:key1] forKey:key1];
    [imgDict setObject:[NSImage imageNamed:key2] forKey:key2];
    [imgPathArray addObject:key1];
    [imgPathArray addObject:key2];
    [self drawRightImgList];
    
    [openGlView.renderer addTexture:key1 image:[imgDict objectForKey:key1] at:0];
    [openGlView.renderer addTexture:key2 image:[imgDict objectForKey:key2] at:1];
    
    
    
//    SettingCellView* cell = [SettingCellView viewFromNIB];
//    cell.frame = CGRectMake(0, 0, 200, 200);
//    cell.wantsLayer = YES;
//    cell.layer.backgroundColor = [[NSColor purpleColor] CGColor];
//    [self.view addSubview:cell];
    
//    NSButton* previewBtn = [[NSButton alloc] init];
//    previewBtn.frame = CGRectMake(20, 20, 60, 40);
//    previewBtn.title = @"Compile";
//    previewBtn.wantsLayer = YES;
//    //previewBtn.alternateTitle = @"Compile"; //设置开启状态时按钮名称
//    previewBtn.state  = NSControlStateValueOn; //设置按钮状态
//    //button.image = //设置按钮图片
//    //button.alternateImage = //设置按钮开言启时图片
//    //button.imagePosition = NSImageLeft; //设置图片和文字位置关系
//    //button.imageScaling = NSImageScaleNone; //图片缩放设置
//    [previewBtn setButtonType:NSButtonTypeOnOff]; //设置按钮类型
//    //[button setBordered:false]; //设置是否显示边框
//    //[button setTransparent:YES]; //设置是否透明
//    //[button highlight:YES]; //设置高亮
//    //button.keyEquivalent = //设置快捷键
//    //button.keyEquivalentModifierMask = //设置快捷键掩码
//    //button.bezelStyle = //设置按钮样式类
//    //previewBtn.tag = 10; //设置按键的tag值，这只是个标记值
//    previewBtn.layer.backgroundColor = [[NSColor whiteColor] CGColor];
//    [previewBtn setTarget:self];
//    [previewBtn setAction:@selector(onCompileBtnClicked)];
//    [self.view addSubview:previewBtn];
    
    
    
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void*)self);
    //CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
    // Activate the display link
    CVDisplayLinkStart(displayLink);
}


// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                      const CVTimeStamp* now,
                                      const CVTimeStamp* outputTime,
                                      CVOptionFlags flagsIn,
                                      CVOptionFlags* flagsOut,
                                      void* displayLinkContext)
{
    CVReturn result = [(__bridge MainViewController*)displayLinkContext updateUniformValue];
    return result;
}

-(CVReturn)updateUniformValue{
    if(flushFrame<15){ // 两次刷新一下,约30Fps
        flushFrame ++;
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
            //NSLog(@"update data!");
            [openGlView.renderer updateUniformValue];
            if(settingWindow!=nil){
                [settingWindow updateUniformValue];
            }
            [openGlView requestRender];
        });
    }
    return kCVReturnSuccess;
}

-(void)drawRightImgList{
    if(imgDict!=nil && imgDict.count>0 && imgPathArray!=nil){
        NSArray* subViews = [rightImgScrollContainerView subviews];
        NSUInteger maxCnt = imgDict.count + 1;

        int itemWidth = 90;
        int itemHeight = 90;
        float hSpace = (imgScrollViewWidth-10-itemWidth)/2.0f;
        float vSpace = 5;
        
        int totalHeight = vSpace + maxCnt * (vSpace + itemHeight);
        if(totalHeight < rightImgScrollView.frame.size.height){
           totalHeight = rightImgScrollView.frame.size.height;
        }
        
        if(subViews.count < maxCnt){
            for (NSUInteger i=subViews.count; i<maxCnt; i++) {
                float y = totalHeight - vSpace - itemHeight - i * (itemHeight+vSpace);
                DragFileInButton* imgView = [[DragFileInButton alloc] initWithFrame:CGRectMake(hSpace, y, itemWidth, itemHeight)];
                imgView.delegate = self;
                [imgView setButtonType:NSButtonTypeOnOff];
                imgView.wantsLayer = true;
                //imgView.layer.borderColor = [[NSColor colorWithWhite:0.5 alpha:1.0] CGColor];
                //imgView.layer.borderWidth = 2;
                imgView.layer.backgroundColor = [[NSColor colorWithWhite:0.5 alpha:1.0] CGColor];
                [rightImgScrollContainerView addSubview:imgView];
                [imgView setTarget:self];
                [imgView setImageScaling:NSImageScaleProportionallyUpOrDown];
                [imgView setAction:@selector(onAddImageClick:)];
            }
            //rightImgScrollView.contentSize = CGSizeMake(rightImgScrollView.frame.size.width, vSpace + maxCnt * (vSpace + itemHeight));
            rightImgScrollContainerView.frame = CGRectMake(0,0, imgScrollViewWidth-10, totalHeight);
        }
        subViews = [rightImgScrollContainerView subviews];
        for (int i=0; i<subViews.count; i++) {
            NSButton* imgView = (NSButton*)[subViews objectAtIndex:i];
            float y = totalHeight - vSpace - itemHeight - i * (itemHeight+vSpace);
            imgView.frame = CGRectMake(hSpace, y, itemWidth, itemHeight);
            imgView.tag = 0x1000+i;
            if(i<imgPathArray.count){
                NSString* path = imgPathArray[i]; // imgDict.allKeys[i];
                if([path isEqualToString:@"NULL"]){
                    [imgView setImage:addImage];
                }else{
                    [imgView setImage:imgDict[path]];
                }
            }else{
                [imgView setImage:addImage];
            }
        }
        [rightImgScrollView scrollToTop];
    }
}


-(void)onAddImageClick:(id)sender{
    long selectIndex = ((NSView*)sender).tag-0x1000;
    NSLog(@"onAddImageClick tag:%ld", selectIndex);
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"png",@"PNG",@"JPG",@"jpg",@"TIFF", @"tiff"]];
    [panel setAllowsOtherFileTypes:NO];
    [panel setMessage:@"Select an Image"];
    
    
    __weak __typeof(self) weakSelf = self; //1.使用__weak __typeof是在编译的时候,另外创建一个weak对象来操作self.
    // Display the panel attached to the document's window.
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) // NSModalResponseOK  NSFileHandlingPanelOKButton
        {
            __strong __typeof(weakSelf)strongSelf = weakSelf;  //__strong __typeof在编译的时候,实际是对weakSelf的强引用.
            if(strongSelf!=nil){
                NSArray* subViews = [strongSelf->rightImgScrollContainerView subviews];
                NSButton* selBtn = nil;
                for (NSView* view in subViews) {
                    if(view.tag==0x1000+selectIndex){
                        selBtn = (NSButton*)view;
                         break;
                    }
                }
                
                if(panel.URLs.count > 0){
                    NSString* path = [((NSURL*)panel.URLs[0]) path];
                    NSLog(@"SelPath:%@",path);
                    NSImage* img = [[NSImage alloc]initWithContentsOfFile:path];
                    if(img!=nil){
                        if(selectIndex < strongSelf->imgPathArray.count){
                            NSString* key = strongSelf->imgPathArray[selectIndex];
                            [strongSelf->imgDict removeObjectForKey:key];
                            [strongSelf->imgDict setObject:img forKey:path];
                            [strongSelf->imgPathArray removeObjectAtIndex:selectIndex];
                            [strongSelf->imgPathArray insertObject:path atIndex:selectIndex];
                            if(![strongSelf->openGlView.renderer addTexture:path image:img at:(int)selectIndex]){
                                strongSelf->_infoListTexView.string = [NSString stringWithFormat:@"%@ \nload texture:%@ failure!",strongSelf->_infoListTexView.string,path];
                            }
                        }else{
                            [strongSelf->imgPathArray addObject:path];
                            [strongSelf->imgDict setObject:img forKey:path];
                            
                            if(![strongSelf->openGlView.renderer addTexture:path image:img at:(int)strongSelf->imgPathArray.count]){
                                strongSelf->_infoListTexView.string = [NSString stringWithFormat:@"%@ \nload texture:%@ failure!",strongSelf->_infoListTexView.string,path];
                            }
                        }
                        //strongSelf->imgPathList[selectIndex] = path;
                        // 指针连带关系self的引用计数还会增加.但是你这个是在block里面,生命周期也只在当前block的作用域.
                        // 所以,当这个block结束, strongSelf随之也就被释放了.同时也不会影响block外部的self的生命周期.
                        //[selBtn setImage:[[NSImage alloc]initWithContentsOfFile:path]];
                        [strongSelf drawRightImgList];
                    }
                }else{
//                    if(selectIndex<strongSelf->imgPathList.count-1){
//                        strongSelf->imgPathList[selectIndex] = @"NULL";
//                    }else{
//                        [strongSelf->imgPathList removeLastObject];
//                    }
                }
                
            }
        }
    }];
}

-(void)onDragFileInButtonDragInFile:(NSString*)path withTag:(NSInteger)tag{
    long selectIndex = tag-0x1000;
    NSLog(@"-----onDragFileInButtonDragInFile----!path:%@",path);
    NSImage* img = [[NSImage alloc]initWithContentsOfFile:path];
    if(img!=nil){
        //imgPathList[selectIndex] = path;
        
        if(selectIndex < imgPathArray.count){
            NSString* key = imgPathArray[selectIndex];
            [imgDict removeObjectForKey:key];
            [imgDict setObject:img forKey:path];
            
            [imgPathArray removeObjectAtIndex:selectIndex];
            [imgPathArray insertObject:path atIndex:selectIndex];
            
            if(![openGlView.renderer addTexture:path image:img at:(int)selectIndex]){
                _infoListTexView.string = [NSString stringWithFormat:@"%@ \n load texture:%@ failure!",_infoListTexView.string,path];
            }
        }else{
            [imgPathArray addObject:path];
            [imgDict setObject:img forKey:path];
            if(![openGlView.renderer addTexture:path image:img at:(int)imgPathArray.count]){
                _infoListTexView.string = [NSString stringWithFormat:@"%@ \n load texture:%@ failure!",_infoListTexView.string,path];
            }
        }
        
        [self drawRightImgList];
    }
}

-(void)onDragFileInEditTextDragInFile:(NSString*)path withTitle:(NSString*)title{
    NSError* error;
    NSStringEncoding code = NSUTF8StringEncoding;
    NSString* str = [[NSString alloc]initWithContentsOfFile:path usedEncoding:&code error:&error];
    if([title isEqualToString:@"Vertex"]){
        NSLog(@"onDragFileInEditTextDragInFile Vertex:%@",path);
        if(error!=nil){
            NSLog(@"Load Vertex Shader from %@ error:%@",path, error.description);
        }else{
            vertexShaderPath = path;
            vertexShaderString = str;
            [self.vertexShaderPath setStringValue:path];
        }
    }else{
        NSLog(@"onDragFileInEditTextDragInFile Fragment:%@",path);
        if(error!=nil){
            NSLog(@"Load Fragment Shader from %@ error:%@",path, error.description);
        }else{
            fragmentShaderPath = path;
            [self.fragmentShaderPath setStringValue:path];
            fragmentShaderString = str;
        }
    }
}

- (IBAction)selectVertexShaderFile:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    //[panel setAllowedFileTypes:@[@"png",@"PNG",@"JPG",@"jpg",@"TIFF", @"tiff"]];
    //[panel setAllowedFileTypes:@[@"*"]];
    [panel setAllowsOtherFileTypes:true];
    [panel setAllowsOtherFileTypes:NO];
    [panel setMessage:@"Select Vertex Shader File"];
    __weak __typeof(self) weakSelf = self; //1.使用__weak __typeof是在编译的时候,另外创建一个weak对象来操作self.
    // Display the panel attached to the document's window.
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) // NSModalResponseOK  NSFileHandlingPanelOKButton
        {
            __strong __typeof(weakSelf)strongSelf = weakSelf;  //__strong __typeof在编译的时候,实际是对weakSelf的强引用.
            if(strongSelf!=nil){
                if(panel.URLs.count > 0){
                    NSString* path = [((NSURL*)panel.URLs[0]) path];
                    NSLog(@"selectVertexShaderFile:%@",path);
                    NSError* error;
                    NSStringEncoding code = NSUTF8StringEncoding;
                    NSString* str = [[NSString alloc]initWithContentsOfFile:path usedEncoding:&code error:&error];
                    if(error!=nil){
                        NSLog(@"Load Vertex Shader from %@ error:%@",path, error.description);
                    }else{
                        strongSelf->vertexShaderPath = path;
                        strongSelf->vertexShaderString = str;
                        [self.vertexShaderPath setStringValue:path];
                    }
                }
            }
        }
    }];
    
}

- (IBAction)selectFragmentShaderFile:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    //[panel setAllowedFileTypes:@[@"png",@"PNG",@"JPG",@"jpg",@"TIFF", @"tiff"]];
    //[panel setAllowedFileTypes:@[@"*"]];
    [panel setAllowsOtherFileTypes:true];
    [panel setMessage:@"Select Fragment Shader File"];
    __weak __typeof(self) weakSelf = self; //1.使用__weak __typeof是在编译的时候,另外创建一个weak对象来操作self.
    // Display the panel attached to the document's window.
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) // NSModalResponseOK  NSFileHandlingPanelOKButton
        {
            __strong __typeof(weakSelf)strongSelf = weakSelf;  //__strong __typeof在编译的时候,实际是对weakSelf的强引用.
            if(strongSelf!=nil){
                if(panel.URLs.count > 0){
                    NSString* path = [((NSURL*)panel.URLs[0]) path];
                    NSLog(@"selectVertexShaderFile:%@",path);
                    NSError* error;
                    NSStringEncoding code = NSUTF8StringEncoding;
                    NSString* str = [[NSString alloc]initWithContentsOfFile:path usedEncoding:&code error:&error];
                    if(error!=nil){
                        NSLog(@"Load Fragment Shader from %@ error:%@",path, error.description);
                    }else{
                        strongSelf->fragmentShaderPath = path;
                        strongSelf->fragmentShaderString = str;
                        [self.fragmentShaderPath setStringValue:path];
                    }
                }
            }
        }
    }];
}

-(void)onEditorWindowShaderSaved:(NSString*)winTitle path:(NSString*)path shaderString:(NSString*)shaderStr{
    //NSLog(@"onEditorWindowShaderSaved:%@", winTitle);
    if([winTitle isEqualToString:@"VertexShader"]){
        self.vertexShaderPath.stringValue = path;
        vertexShaderPath = path;
        vertexShaderString = shaderStr;
    }else{
        self.fragmentShaderPath.stringValue = path;
        fragmentShaderPath = path;
        fragmentShaderString = shaderStr;
    }
    
    NSError* error;
    [openGlView setVertexShader:vertexShaderString fragmentShader:fragmentShaderString error:&error];
    if(error){
        //self.infoListTexView.string = error.description;
        _infoListTexView.string = [NSString stringWithFormat:@"%@ \n%@",_infoListTexView.string,error.description];
    }else{
        [self onCompileBtnClicked:nil];
        //self.infoListTexView.string = @"Compile Success!";
        _infoListTexView.string = [NSString stringWithFormat:@"%@ \nCompile Success!",_infoListTexView.string];
    }
}

- (IBAction)openVertexShader:(id)sender {

    if(vsEditWindow==nil){
        vsEditWindow = [[EditorWindow alloc] initWithWindowNibName:@"EditorWindow"];  // DialogName 为你的xib文件名，不需要后缀
        vsEditWindow.winTitle = @"VertexShader";
        vsEditWindow.window.title = @"VertexShader";
        vsEditWindow.delegate = self;
        
        [vsEditWindow loadWindow];
        //Mac中对话框显示方法有两种，一种跟windows的对话框一样，另一种为Sheet（卷帘式）对话框。
        //windows风格的对话框，分模态和非模态
    }
    [vsEditWindow.window setFrame:CGRectMake(vsEditWindow.window.frame.origin.x, vsEditWindow.window.frame.origin.y, 400, 480) display:false];
    vsEditWindow.shaderPath = vertexShaderPath;
    vsEditWindow.shaderSource = vertexShaderString;
    if(vertexShaderPath==nil){
        vsEditWindow.isDefault = true;
    }else{
        vsEditWindow.isDefault = false;
    }
    vsEditWindow.isSaved = false;
    [vsEditWindow updateTextFile];
    
    // 非模态：
    [[vsEditWindow window] makeKeyAndOrderFront:nil];
    //模态：
    //[NSApp runModalForWindow:[settingWindow window]];
    
}

- (IBAction)openFragmentShader:(id)sender {
    if(fsEditWindow==nil){
        fsEditWindow = [[EditorWindow alloc] initWithWindowNibName:@"EditorWindow"];  // DialogName 为你的xib文件名，不需要后缀
        fsEditWindow.winTitle = @"FragmentShader";
        fsEditWindow.window.title = @"FragmentShader";
        fsEditWindow.delegate = self;
        [fsEditWindow loadWindow];
        //Mac中对话框显示方法有两种，一种跟windows的对话框一样，另一种为Sheet（卷帘式）对话框。
        //windows风格的对话框，分模态和非模态
        
    }
    fsEditWindow.shaderPath = fragmentShaderPath;
    fsEditWindow.shaderSource = fragmentShaderString;
    if(vertexShaderPath==nil){
        fsEditWindow.isDefault = true;
    }else{
        fsEditWindow.isDefault = false;
    }
    fsEditWindow.isSaved = false;
    [fsEditWindow updateTextFile];
    [fsEditWindow.window setFrame:CGRectMake(fsEditWindow.window.frame.origin.x, fsEditWindow.window.frame.origin.y, 400, 480) display:false];
    
    // 非模态：
    [[vsEditWindow window] makeKeyAndOrderFront:nil];
    //模态：
    //[NSApp runModalForWindow:[settingWindow window]];
}

- (void)windowDidResize:(NSNotification *)notification{
    NSLog(@"-----windowDidResize----!rect:%@",NSStringFromRect(self.view.frame));
    //openGlView.frame = CGRectMake(0, 0, self.view.frame.size.width - imgScrollViewWidth, self.view.frame.size.height);
    //rightImgScrollView.frame = CGRectMake(self.view.frame.size.width-imgScrollViewWidth, 0, imgScrollViewWidth, self.view.frame.size.height);
    //rightImgScrollView.verticalScroller.frame = CGRectMake(0, 0, 10, rightImgScrollView.frame.size.height);
    //rightImgScrollView.documentView.frame = rightImgScrollView.bounds;
    
//    if(!isInitView){
//        isInitView = true;
//        [self drawRightImgList];
//    }
}

- (BOOL)windowShouldClose:(NSWindow *)sender{
    CVDisplayLinkStop(displayLink);
    NSLog(@"-----windowShouldClose----!cls:%@",sender.className);
    return true;
}

//- (void)reshape
//{
//    [super reshape];
//    NSLog(@"-----windowDidResize----!rect:%@",NSStringFromRect(self.view.frame));
//}
- (IBAction)onCompileBtnClicked:(id)sender {
    [openGlView requestRender];
    [openGlView.renderer getUniformVariant];
    
    if(settingWindow!=nil){
        settingWindow.uniformValueDict = openGlView.renderer.valueDict;
        settingWindow.uniformNameArray = openGlView.renderer.uniformNameList;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_SHADER_UNIFORM" object:nil];
        [settingWindow onUniformUpdate:nil];
    }
    
}

- (IBAction)onSettingBtnClicked:(id)sender {
    
    [openGlView.renderer getUniformVariant];
    
    if(settingWindow==nil){
        settingWindow = [[NSSettingWindow alloc] initWithWindowNibName:@"NSSettingWindow"];  // DialogName 为你的xib文件名，不需要后缀
        //previewWindow = [[PreviewWindow alloc] init];  // DialogName 为你的xib文件名，不需要后缀
        //dialogCtl.delegate = self;
        [settingWindow loadWindow];
        //Mac中对话框显示方法有两种，一种跟windows的对话框一样，另一种为Sheet（卷帘式）对话框。
        //windows风格的对话框，分模态和非模态
        settingWindow.window.title = [NSSettingWindow className];
        settingWindow.uniformValueDict = openGlView.renderer.valueDict;
        settingWindow.uniformNameArray = openGlView.renderer.uniformNameList;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_SHADER_UNIFORM" object:nil];
        //[settingWindow onUniformUpdate:nil];
    }
    [settingWindow updateScrollView];
    // 非模态：
    [[settingWindow window] makeKeyAndOrderFront:nil];
    //模态：
    //[NSApp runModalForWindow:[settingWindow window]];
}

//-(void)windowWillClose:(NSNotification *)notification{
//
//    NSLog(@"MainViewController windowWillClose");
//    [NSApp stop:self];
//    //[NSApp stopModal];会报错啊
//}

@end
