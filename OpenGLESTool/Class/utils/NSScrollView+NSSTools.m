//
//  NSScrollView+tools.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/23.
//  Copyright © 2020 apple. All rights reserved.
//

#import "NSScrollView+NSSTools.h"

@implementation NSScrollView (NSSTools)

-(void)scrollToTop {
    NSView* documentView = self.documentView;
    if(documentView.isFlipped){
        [documentView scrollPoint:CGPointMake(0, 0)];
    }else{
        int maxHeight = self.bounds.size.height > documentView.bounds.size.height ? self.bounds.size.height : documentView.bounds.size.height;
        [documentView scrollPoint:CGPointMake(0,maxHeight)];
    }
}

@end
