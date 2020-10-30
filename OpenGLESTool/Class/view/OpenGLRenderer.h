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

@property (nonatomic,retain) NSDictionary* valueDict;
@property (nonatomic,retain) NSArray* uniformNameList;

- (instancetype)initVertexShader:(NSString*) vertex fragmentShader:(NSString*)fragment error:(NSError**)error;

- (void) resizeWithWidth:(GLuint)width AndHeight:(GLuint)height;
- (void) render;
- (void) dealloc;

- (int)setImage:(NSImage*) image;

-(void)getUniformVariant;
-(void)updateUniformValue;

-(bool)addTexture:(NSString*)path image:(NSImage*)image at:(int)index;

@end

NS_ASSUME_NONNULL_END


