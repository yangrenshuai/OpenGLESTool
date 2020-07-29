//
//  OpenGLView.h
//  OpenGLESTool
//
//  Created by apple on 2020/7/22.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <GLUT/GLUT.h>
#import "OpenGLRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenGLView : NSOpenGLView{
    CVDisplayLinkRef displayLink;
}

@property (nonatomic, strong) OpenGLRenderer* renderer;

- (void)setImage:(NSImage*)img;
-(void)setVertexShader:(NSString*) vertex fragmentShader:(NSString*)fragment;
- (void) requestRender;
@end

NS_ASSUME_NONNULL_END
