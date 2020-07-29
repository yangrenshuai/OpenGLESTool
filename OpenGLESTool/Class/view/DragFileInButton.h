//
//  DragFileInButton.h
//  OpenGLESTool
//
//  Created by apple on 2020/7/23.
//  Copyright © 2020 apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DragFileInButtonDelegate <NSObject>
-(void)onDragFileInButtonDragInFile:(NSString*)path withTag:(NSInteger)tag;
@end

@interface DragFileInButton : NSButton

@property(nonatomic,assign)id<DragFileInButtonDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
