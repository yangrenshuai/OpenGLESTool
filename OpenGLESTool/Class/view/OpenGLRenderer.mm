//
//  OpenGLRenderer.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/22.
//  Copyright © 2020 apple. All rights reserved.
//

#import "OpenGLRenderer.h"
//#include "glUtil.h"
//#include "imageUtil.h"
//#include "sourceUtil.h"

// https://www.jianshu.com/p/dda8c00592c4

#ifndef NULL
#define NULL 0
#endif

//#define ScreenWidth      CGRectGetWidth([UIScreen mainScreen].applicationFrame)
//#define ScreenHeight     CGRectGetHeight([UIScreen mainScreen].applicationFrame)

@interface OpenGLRenderer ()
{
    GLuint m_program;
    GLuint m_vertexBuffer;
    GLuint textureUniform;
    GLuint vertexBuffer;
    GLuint vertextAttribute;
    GLuint textureAttribute;
        
    GLuint id_tex;
    
    int m_nVideoW;
    int m_nVideoH;
    int m_nViewW;
    int m_nViewH;
    unsigned char* m_pBufYuv420p;
    unsigned char* m_pBuffer;
    
    GLuint m_InputTextureId;
    
}
@end

@implementation OpenGLRenderer

- (instancetype)initVertexShader:(NSString*) vertex fragmentShader:(NSString*)fragment{
    if((self = [super init])) {
        NSLog(@"Render: %s; Version:%s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
        
        self.vertexShader = vertex;
        self.fragmentShader = fragment;
        
        [self initializeGL];
        
        //清除缓存
        [self clearRenderBuffer];
    }
    return self;
}

- (void)resizeWithWidth:(GLuint)width AndHeight:(GLuint)height {

    NSLog(@"OpengGLRenderer resizeWithWidth glViewport w:%d h:%d",width, height);
    
    glViewport(0, 0, width, height);
    
    m_nViewW = width;
    m_nViewH = height;
    if (m_nViewW==0) {
        //m_nViewW = 2*iScreenWidth/3;
        m_nViewW = 100;
    }
    if (m_nViewH==0) {
        //m_nViewH = 2*iScreenHeight/3;
        m_nViewH = 100;
    }
    
    //清除缓存
    [self clearRenderBuffer];
}

- (void) render {
    
    NSLog(@"OpenGlRenderer render!");
    
    [self clearRenderBuffer];
    
    //glColor4f(1.0, 0.0, 0.0, 1.0);
    
    float x,y;
    float wRatio = (float)m_nViewW/m_nVideoW;
    float hRatio = (float)m_nViewH/m_nVideoH;
    float minRatio = wRatio<hRatio ? wRatio : hRatio;
    y = m_nVideoH * minRatio/m_nViewH;
    x = m_nVideoW * minRatio/m_nViewW;
        
    float vertexPoints[] ={
        -x, -y,  0.0f,  1.0f,
         x, -y,  1.0f,  1.0f,
        -x,  y,  0.0f,  0.0f,
         x,  y,  1.0f,  0.0f,
    };
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 4 * 4 * sizeof(float), vertexPoints, GL_STATIC_DRAW);
    [self CheckGLError:@"render 1"];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_InputTextureId);
    glUniform1i(textureUniform, 0);
    
    [self CheckGLError:@"render 2"];
    // Draw stuff
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
    
    [self CheckGLError:@"render 3"];
    
}

- (void) dealloc {
    if(m_program>0){
        glDeleteProgram(m_program);
    }
    m_program = 0;
}

-(void)clearRenderBuffer {
    //清除缓存
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
}

#pragma mark init methdos
-(void)initializeGL {
    
    m_InputTextureId = 0;
    
    // 准备 着色器程序
    [self prepareShaderProgram];
    
    textureUniform = glGetUniformLocation(m_program, "tex");
    
    // Create a interleaved triangle (vec3 position, vec3 color)
    float vertexPoints[] ={
        -1.0f, -1.0f,  0.0f, 1.0f,
         1.0f, -1.0f,  1.0f, 1.0f,
        -1.0f,  1.0f,  0.0f, 0.0f,
         1.0f,  1.0f,  1.0f, 0.0f,
    };
        
    //glGenVertexArrays(1, &m_vertexBuffer);
    //glBindVertexArray(m_vertexBuffer);
    glGenVertexArraysAPPLE(1, &m_vertexBuffer);
    glBindVertexArrayAPPLE(m_vertexBuffer);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 4 * 4 * sizeof(float), vertexPoints, GL_STATIC_DRAW);
    vertextAttribute = glGetAttribLocation(m_program, "vertexIn");
    textureAttribute = glGetAttribLocation(m_program, "textureIn");
    glEnableVertexAttribArray(vertextAttribute);
    glVertexAttribPointer(vertextAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(float)*4, (const GLvoid *)0);
    glEnableVertexAttribArray(textureAttribute);
    glVertexAttribPointer(textureAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(float)*4, (const GLvoid *)(sizeof(float)*2));
    
    //extern void glVertexAttribPointer (GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid *pointer)
    
    //Init Texture
//    glGenTextures(1, &id_tex);
//    glBindTexture(GL_TEXTURE_2D, id_tex);
//    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
}
-(void)prepareShaderProgram {
    
    NSLog(@"prepareShaderProgram!");
    
    //NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"Shader3" ofType:@"vs"]; // 读取文件路径
    //NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"Shader3" ofType:@"frag"];
    //m_program = [self loadShaders:vertFile frag:fragFile isFile:true]; //加载shader
    
    m_program = [self loadShaders:self.vertexShader frag:self.fragmentShader isFile:false];
    
    //链接
    //glBindFragDataLocation(m_program, 0, "fragColor");
    glBindFragDataLocationEXT(m_program, 0, "fragColor");
    
    glLinkProgram(m_program);
    
    GLint  linked;
    glGetProgramiv(m_program, GL_LINK_STATUS, &linked );
    if ( !linked ) {
        NSLog(@"Shader program failed to link");
        GLint  logSize;
        glGetProgramiv(m_program, GL_INFO_LOG_LENGTH, &logSize);
        char* logMsg = new char[logSize];
        glGetProgramInfoLog(m_program, logSize, NULL, logMsg );
        NSLog(@"Link Error: %s", logMsg);
        delete [] logMsg;
            
        exit( EXIT_FAILURE );
    }
        
    //use program object
    glUseProgram(m_program);
}


-(void)getUniformVariant:(NSMutableDictionary*) dict withUniformIndexDict:(NSMutableDictionary*)uniformIndexDict{
    
    if(m_program==0){
        return;
    }
    // textureUniform = glGetUniformLocation(m_program, "tex");
    GLint activeUniforms=0;
    glGetProgramiv(m_program,GL_ACTIVE_UNIFORMS,&activeUniforms);
    NSLog(@"GL_ACTIVE_UNIFORMS:%d",activeUniforms);
    
    for(int i=0;i<activeUniforms;i++){
        GLsizei length;
        GLint size;
        GLenum type;
        GLchar *name = new char[256];
        glGetActiveUniform(m_program, i, 256, &length, &size, &type, name);
        //extern void glGetActiveUniform (GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLint *size, GLenum *type, GLchar *name)
        
        NSLog(@"glGetActiveUniform name:%s type:%u", name, type);

        [dict setValue:[NSNumber numberWithInt:type] forKey:[NSString stringWithFormat:@"%s",name]];
        
        [uniformIndexDict setValue:[NSNumber numberWithInt:i] forKey:[NSString stringWithFormat:@"%s",name]];
        
        delete [] name;
        
        //program 指定要查询的程序对象。
        //index 指定要查询的统一变量的索引。
        //bufSize 指定允许OpenGL在由name指示的字符缓冲区中写入的最大字符数。
        //length 如果传递NULL以外的值，则返回由name指示的字符串中的OpenGL实际写入的字符数（不包括空终止符）。
        //size 返回统一变量的大小。
        //type 返回统一变量的数据类型。
        //name 返回包含统一变量名称的以null结尾的字符串。
        //type参数将返回指向统一变量数据类型的指针。可以返回符号常数GL_FLOAT，GL_FLOAT_VEC2，GL_FLOAT_VEC3，GL_FLOAT_VEC4，GL_INT_GLEC_VEC2，GL_INT_VEC3，GL_INT_VEC4，GL_BOOL，GL_BOOL_VEC2，GL_BOOL_VEC3，GL_BOOL_VEC4，GL_FLOAT_MAT2，GL_FLOAT_MAT3，GL_FLOAT_MAT4，GL_SAMPLER_2D或GL_SAMPLER_CUBE。
        
        //GLAPI void APIENTRY glGetActiveUniformName (GLuint program, GLuint uniformIndex, GLsizei bufSize, GLsizei *length, GLchar *uniformName) OPENGL_DEPRECATED(10.5, 10.14);
    }
    
    //glGetActiveUniformsiv(
    //glGetActiveUniform 和glGetActiveUniformsiv查找
}

- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag isFile:(bool)isFile{
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    
    //编译
    verShader = [self compileShader:GL_VERTEX_SHADER shader:vert isFile:isFile];
    fragShader = [self compileShader:GL_FRAGMENT_SHADER shader:frag isFile:isFile];
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (GLuint)compileShader:(GLenum)type shader:(NSString *)file isFile:(bool)isFile{
    //读取字符串
    const GLchar* source = nil;
    if(isFile){
        NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
        source = (GLchar *)[content UTF8String];
    }else{
        source = (GLchar *)[file UTF8String];
    }
    
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);

    glCompileShader(shader);
    
    //错误分析
    GLint  compiled;
    glGetShaderiv( shader, GL_COMPILE_STATUS, &compiled );
    if ( !compiled ) {
        GLint  logSize;
        glGetShaderiv( shader, GL_INFO_LOG_LENGTH, &logSize );
        char* logMsg = new char[logSize];
        glGetShaderInfoLog( shader, logSize, NULL, logMsg );
        NSLog(@"Shader compile log:%s\n", logMsg);
        delete [] logMsg;
        exit(EXIT_FAILURE);
    }
    return shader;
}

//NSImage 转换为 CGImageRef
- (CGImageRef)NSImageToCGImageRef:(NSImage*)image{
    
    NSData * imageData = [image TIFFRepresentation];
    
    CGImageRef imageRef;
    
    if(imageData){
        
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        
        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
        
    }
    
    return imageRef;
    
}

- (void)setImage:(NSImage*) image{
    
    if(image==nil){
        return;
    }
    
    int iw = [image size].width;
    int ih = [image size].height;
    
    m_nVideoW = [image size].width;
    m_nVideoH = [image size].height;
    
    
    
    if(m_InputTextureId!=0){
        glDeleteTextures(1, &m_InputTextureId);
    }
    
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &m_InputTextureId);
    glBindTexture(GL_TEXTURE_2D, m_InputTextureId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    

    // 1. Error
    //CGImageRef newImageSource = [self NSImageToCGImageRef:image];
    //CFDataRef dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
    //GLubyte* imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [image size].width, [image size].height, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    
    // 2. Error
    //NSData *imageData = [image TIFFRepresentation];
    //GLubyte* rgbaData = (GLubyte*)imageData.bytes;
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [image size].width, [image size].height, 0, GL_RGBA, GL_UNSIGNED_BYTE, rgbaData);

    // 3. Right
    CGImageRef newImageSource = [self NSImageToCGImageRef:image];
    GLubyte* imageData = (GLubyte *)calloc(1, (size_t)iw * (size_t)ih * 4);
    CGColorSpaceRef RGBColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(imageData,
                                                      (size_t)iw, (size_t)ih,
                                                      8,
                                                      (size_t)iw * 4, RGBColorSpace,
                                                      kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(imageContext, CGRectMake(0, 0, iw, ih), newImageSource);
    CGContextRelease(imageContext);
    CGColorSpaceRelease(RGBColorSpace);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, iw, ih, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    free(imageData);
    
}

-(void) CheckGLError:(NSString*)pGLOperation
{
    for (GLint error = glGetError(); error; error = glGetError())
    {
        NSLog(@"CheckGLError GL Operation %@ glError (0x%x)\n", pGLOperation, error);
    }
}

@end
