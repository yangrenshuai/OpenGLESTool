//
//  DragFileInEditText.h
//  OpenGLESTool
//
//  Created by apple on 2020/7/23.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DragFileInEditTextDelegate <NSObject>
-(void)onDragFileInEditTextDragInFile:(NSString*)path withTitle:(NSString*)shaderType;
@end

@interface DragFileInEditText : NSTextField

@property(nonatomic,assign)id<DragFileInEditTextDelegate>dragDelegate;

@property(nonatomic,copy)NSString* shaderType;

@end

NS_ASSUME_NONNULL_END
