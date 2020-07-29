//
//  OpenGLRenderer.h
//  OpenGLESTool
//
//  Created by apple on 2020/7/22.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
//#include "glUtil.h"
#import <GLUT/GLUT.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreGraphics/CGContext.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLRenderer : NSObject

@property (nonatomic) GLuint defaultFBOName;

@property (nonatomic,copy) NSString* vertexShader;
@property (nonatomic,copy) NSString* fragmentShader;

- (instancetype)initVertexShader:(NSString*) vertex fragmentShader:(NSString*)fragment;

- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
- (void) render;
- (void) dealloc;

- (void)setImage:(NSImage*) image;

-(void)getUniformVariant:(NSMutableDictionary*) dict withUniformIndexDict:(NSMutableDictionary*)uniformIndexDict;

@end

NS_ASSUME_NONNULL_END


