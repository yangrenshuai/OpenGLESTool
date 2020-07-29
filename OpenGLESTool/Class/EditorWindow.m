//
//  EditorWindow.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/28.
//  Copyright © 2020 apple. All rights reserved.
//

#import "EditorWindow.h"

@interface EditorWindow ()<NSWindowDelegate>{
    NSWindow* window;
}
@end

@implementation EditorWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)awakeFromNib{
    [super awakeFromNib];

    NSArray<NSWindow *>* windows = [NSApplication sharedApplication].windows;
    for (NSWindow *win in windows){
        if([win.title isEqualToString:_winTitle]){
            window = win;
            window.delegate = self;
            break;
        }
    }
    
    self.textField.usesSingleLineMode = false;

    
    
    
    // 关闭自动换行
    self.textView.textContainer.widthTracksTextView = false;
    self.textView.textContainer.containerSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
//    self.scrollView.documentView.frame = CGRectMake(0, 0, self.scrollView.documentView.frame.size.width*2, self.scrollView.documentView.frame.size.height);
    
    
    // self.textView.textContainer.size
    
//    self.textView.string sizeWithAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)
//    NSFontAttributeName* ss = [NSFont fontWithName:@"Helvetica(Neue) " size:12] string;
//    NSFont, default Helvetica(Neue) 12
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextFieldDidChange:) name:NSControlTextDidEndEditingNotification object:self.textField];
    
    NSMenuItem * saveItem = [[NSApp mainMenu]itemWithTitle:@"Save..."];
    NSMenuItem * saveAsItem = [[NSApp mainMenu]itemWithTitle:@"Save As..."];
    
    if(saveItem!=nil){
        [saveItem setTarget:self];
        [saveItem setAction:@selector(onSaveBtnClicked)];
    }
    if(saveAsItem!=nil){
        [saveItem setTarget:self];
        [saveItem setAction:@selector(onSaveAsBtnClicked)];
    }
}

-(void)onSaveBtnClicked{
    NSLog(@"onSaveBtnClicked");
}

-(void)onSaveAsBtnClicked{
    NSLog(@"onSaveAsBtnClicked");
}

- (void)windowDidResize:(NSNotification *)notification{
    // NSLog(@"-----NSSettingWindow----!rect:%@",NSStringFromRect(self.window.frame));
    self.textField.frame = self.window.contentView.bounds;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self.textField];
}

-(void)onTextFieldDidChange:(NSNotification *)notification{
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
    self.textField.stringValue = self.shaderSource;
}

@end
