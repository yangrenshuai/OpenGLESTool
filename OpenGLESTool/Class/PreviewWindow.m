//
//  PreviewWindow.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/22.
//  Copyright © 2020 apple. All rights reserved.
//

#import "PreviewWindow.h"

@interface PreviewWindow ()

@end

@implementation PreviewWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    NSButton* previewBtn = [[NSButton alloc] init];
    previewBtn.frame = CGRectMake(20, 20, 60, 40);
    previewBtn.title = @"TTT";
    previewBtn.wantsLayer = YES;
    previewBtn.alternateTitle = @"TTT";
    previewBtn.state  = NSControlStateValueOn;
    [previewBtn setButtonType:NSButtonTypeOnOff];
    previewBtn.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    [self.window.contentView addSubview:previewBtn];
    
}

//- (IBAction)onDialogConfirmBtnClicked:(id)sender {
//    if(_delegate!=nil){
//        int index = 0;
//        if(selectView!=nil){
//            index = (int)(selectView.index-0x1000);
//        }
//        [_delegate onDeleteColorDialogConfirmClicked:index];
//    }
//    //[NSApp stopModal];会报错啊
//    //[NSApp stop:self];
//    [self close];
//}
//
//- (IBAction)onDialogCancelBtnClick:(id)sender {
//    if(_delegate!=nil){
//        [_delegate onDeleteColorDialogCancelClicked];
//    }
//    //[NSApp stopModal];会报错啊
//    //[NSApp stop:self];
//    [self close];
//}

-(void)windowWillClose:(NSNotification *)notification{
    NSLog(@"PreviewWindow windowWillClose");
    
//    if(_delegate!=nil){
//        [_delegate onDeleteColorDialogWillClose];
//    }
//    _delegate = nil;
    [NSApp stop:self];
    //[NSApp stopModal];会报错啊
}


@end
