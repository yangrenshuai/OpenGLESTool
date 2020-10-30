//
//  MainViewController.h
//  OpenGLESTool
//
//  Created by apple on 2020/7/22.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragFileInEditText.h"
NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : NSViewController

@property (strong) IBOutlet DragFileInEditText *vertexShaderPath;
@property (strong) IBOutlet DragFileInEditText *fragmentShaderPath;

@property (unsafe_unretained) IBOutlet NSTextView *infoListTexView;

@end

NS_ASSUME_NONNULL_END
