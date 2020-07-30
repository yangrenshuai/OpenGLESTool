//
//  EditorWindow.h
//  OpenGLESTool
//
//  Created by apple on 2020/7/28.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditorWindow : NSWindowController

@property (nonatomic, copy) NSString* winTitle;

@property (nonatomic, copy) NSString* shaderPath; // 文件路径

@property (nonatomic, copy) NSString* shaderSource; // Shader String

@property (nonatomic, assign) bool isDefault; // 是否是默认的

@property (nonatomic, assign) bool isSaved;

@property (strong) IBOutlet NSScrollView *scrollView;
@property (strong) IBOutlet NSTextView *textView;

-(void)updateTextFile;

@end

NS_ASSUME_NONNULL_END
