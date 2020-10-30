//
//  EditorWindow.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/28.
//  Copyright © 2020 apple. All rights reserved.
//

#import "EditorWindow.h"

@interface EditorWindow ()<NSWindowDelegate,NSTextViewDelegate>{
    NSWindow* window;
    float widthDiff;
}
@end

@implementation EditorWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)awakeFromNib{
    [super awakeFromNib];

    widthDiff == 0;
    NSArray<NSWindow *>* windows = [NSApplication sharedApplication].windows;
    for (NSWindow *win in windows){
        if([win.title isEqualToString:_winTitle]){
            window = win;
            window.delegate = self;
            break;
        }
    }
    
    
    // 关闭自动换行
    self.textView.textContainer.widthTracksTextView = false;
    self.textView.textContainer.containerSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    self.textView.delegate = self;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextFieldDidChange:) name:NSControlTextDidChangeNotification object:self.textField];
    
    widthDiff = self.scrollView.frame.size.width - self.scrollView.contentView.frame.size.width;
    
    if(self.shaderPath!=nil){
        self.window.title = [NSString stringWithFormat:@"%@",self.self.shaderPath];
    }

    NSMenuItem * fileMenu = [[NSApp mainMenu]itemWithTitle:@"File"];
    if(fileMenu!=nil){
        NSLog(@"Find fileItem!");
    
        NSMenuItem * saveItem = [fileMenu.submenu itemWithTitle:@"Save…"];
        NSMenuItem * saveAsItem = [fileMenu.submenu itemWithTitle:@"Save As…"];
        if(saveItem!=nil){
            [saveItem setTarget:self];
            [saveItem setAction:@selector(onSaveBtnClicked)];
            saveItem.enabled = YES;
        }
        if(saveAsItem!=nil){
            [saveAsItem setTarget:self];
            [saveAsItem setAction:@selector(onSaveAsBtnClicked)];
            saveAsItem.enabled = YES;
        }
    
    }
    
//    unichar arrowKey = 'r';
//    NSString *refresh = [NSString stringWithCharacters:&arrowKey length:1];
//    unichar arrowKey2 = 'o';
//    NSString *homePage = [NSString stringWithCharacters:&arrowKey2 length:1];
//    unichar arrowKey3 = 27;
//    NSString *esc = [NSString stringWithCharacters:&arrowKey3 length:1];
//    NSMenuItem *item= [NSApp.mainMenu insertItemWithTitle:@"111" action:nil keyEquivalent:@"" atIndex:1];
//    NSMenu *submenu=[[NSMenu alloc] initWithTitle:@"ww"];
//    item.submenu=submenu;
//    [submenu addItemWithTitle:@"1" action:@selector(dd) keyEquivalent:homePage];//返回首页
//    [submenu addItemWithTitle:@"2" action:@selector(dd) keyEquivalent:refresh];//刷新
//    [submenu addItemWithTitle:@"3" action:@selector(dd) keyEquivalent:esc];//exit
    
}

-(void)onSaveBtnClicked{
    NSLog(@"onSaveBtnClicked");
    if(_shaderPath==nil){
        [self onSaveAsBtnClicked];
    }else{
        
        self.isSaved = true;
        
        self.shaderSource = self.textView.string;
        
        NSError* error;
        [self.shaderSource writeToFile:self.shaderPath atomically:true encoding:NSUTF8StringEncoding error:&error];
        if(error){
            NSLog(@"Save Filure:%@", error.description);
        }else{
            if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(onEditorWindowShaderSaved:path:shaderString:)]){
                [self.delegate onEditorWindowShaderSaved:self.winTitle path:self.shaderPath shaderString:self.shaderSource];
            }
        }
    }
}

-(void)onSaveAsBtnClicked{
    NSLog(@"onSaveAsBtnClicked");
    
    NSSavePanel* panel = [NSSavePanel savePanel];
    [panel setTitle:[NSString stringWithFormat:@"Save %@ Shader File",self.winTitle]];
    panel.nameFieldLabel = @"FileName:";
    panel.nameFieldStringValue = [NSString stringWithFormat:@"%@.gles",self.winTitle];
    [panel setAllowsOtherFileTypes:true];
    //[panel setMessage:[NSString stringWithFormat:@"Save %@ Shader File",self.winTitle]];
    __weak __typeof(self) weakSelf = self; //1.使用__weak __typeof是在编译的时候,另外创建一个weak对象来操作self.
    // Display the panel attached to the document's window.
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) // NSModalResponseOK  NSFileHandlingPanelOKButton
        {
            __strong __typeof(weakSelf)strongSelf = weakSelf;  //__strong __typeof在编译的时候,实际是对weakSelf的强引用.
            if(strongSelf!=nil){
                if(panel.URL != nil){
                    strongSelf.shaderPath = panel.URL.path;
                    if(strongSelf.shaderPath!=nil){
                        strongSelf.shaderSource = strongSelf.textView.string;
                        NSError* error;
                        [strongSelf.shaderSource writeToFile:strongSelf.shaderPath atomically:true encoding:NSUTF8StringEncoding error:&error];
                        if(error){
                            NSLog(@"Save Filure:%@", error.description);
                        }else{
                            if(strongSelf.delegate!=nil && [strongSelf.delegate respondsToSelector:@selector(onEditorWindowShaderSaved:path:shaderString:)]){
                                [strongSelf.delegate onEditorWindowShaderSaved:strongSelf.winTitle path:strongSelf.shaderPath shaderString:strongSelf.shaderSource];
                            }
                        }
                        strongSelf.window.title = [NSString stringWithFormat:@"%@",self.self.shaderPath];
                    }
                }
            }
        }
    }];
    
}

- (void)windowDidResize:(NSNotification *)notification{
    // NSLog(@"-----NSSettingWindow----!rect:%@",NSStringFromRect(self.window.frame));
    self.scrollView.frame = self.window.contentView.bounds;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self.textView];
}

- (void)textDidChange:(NSNotification *)notification{
    //Get glyph range for boundingRectForGlyphRange:
    NSRange range = [[self.textView layoutManager] glyphRangeForTextContainer:self.textView.textContainer];

    float textViewWidth = [[self.textView layoutManager] boundingRectForGlyphRange:range inTextContainer:self.textView.textContainer].size.width;
    //NSLog(@"textViewWidth:%f",textViewWidth);
    
    textViewWidth = textViewWidth + 10;
    if(textViewWidth < self.scrollView.frame.size.width - widthDiff){
        textViewWidth = self.scrollView.frame.size.width - widthDiff;
    }
    self.scrollView.documentView.frame = CGRectMake(0, 0, textViewWidth, self.scrollView.contentView.frame.size.height);
    
    self.isSaved = false;
    
}

-(void)updateTextFile{
    if(self.shaderPath!=nil){
        NSError* error;
        self.shaderSource = [NSString stringWithContentsOfFile:self.shaderPath encoding:NSUTF8StringEncoding error:&error];
        if(error){
            self.shaderSource = error.description;
        }
    }else if(self.shaderSource!=nil){
        
    }else{
        self.shaderSource = @"";
    }
    self.textView.string = self.shaderSource;
}


//-(void)rightMouseDown:(NSEvent *)event{
//    //创建Menu
//    NSMenu *theMenu = [[NSMenualloc] initWithTitle:@"Contextual Menu"];
//    //自定义的NSMenuItem
//    NSMenuItem *item3 = [[NSMenuItemalloc]init];
//    self.customView.wantsLayer =YES;
//    self.customView.layer.backgroundColor = [NSColorredColor].CGColor;
//    item3.title = @"Item 3";
//    item3.view = self.customView;
//    item3.target = self;
//    item3.action = @selector(beep:);
//    [theMenu insertItemWithTitle:@"Item 1"action:@selector(beep:)keyEquivalent:@""atIndex:0];
//    [theMenu insertItemWithTitle:@"Item 2"action:@selector(beep:)keyEquivalent:@""atIndex:1];
//    [theMenu insertItem:item3 atIndex:2];
//    [NSMenu popUpContextMenu:theMenuwithEvent:event forView:self.view];
//}
//
//-(void)beep:(NSMenuItem *)menuItem{
//    NSLog(@"_____%@", menuItem);
//}
//- (void)setRepresentedObject:(id)representedObject {
//    [super setRepresentedObject:representedObject];
//    // Update the view, if already loaded.
//}


@end
