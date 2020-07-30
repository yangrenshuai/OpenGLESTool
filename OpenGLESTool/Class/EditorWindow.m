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
    self.scrollView.frame = self.window.contentView.bounds;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self.textView];
}

- (void)textDidChange:(NSNotification *)notification{
    //Get glyph range for boundingRectForGlyphRange:
    NSRange range = [[self.textView layoutManager] glyphRangeForTextContainer:self.textView.textContainer];

    float textViewWidth = [[self.textView layoutManager] boundingRectForGlyphRange:range inTextContainer:self.textView.textContainer].size.width;
    NSLog(@"textViewWidth:%f",textViewWidth);
    
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

@end
