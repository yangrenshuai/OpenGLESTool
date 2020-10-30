//
//  OpenGLRenderer.m
//  OpenGLESTool
//
//  Created by apple on 2020/7/22.
//  Copyright © 2020 apple. All rights reserved.
//

#import "OpenGLRenderer.h"
#import "SettingCellValue.h"
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
    
    //NSDictionary* uniformDict;
    //NSArray* uniformNameArray;
    NSRecursiveLock* lock;
    
    NSMutableDictionary* textureDict;
    
}
@end

@implementation OpenGLRenderer

- (instancetype)initVertexShader:(NSString*) vertex fragmentShader:(NSString*)fragment error:(NSError**)error{
    if((self = [super init])) {
        NSLog(@"Render: %s; Version:%s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
        
        self.vertexShader = vertex;
        self.fragmentShader = fragment;
        lock = [[NSRecursiveLock alloc]init];
        textureDict = [NSMutableDictionary dictionary];
        
        [self initializeGL:error];
        
        //清除缓存
        [self clearRenderBuffer];
    }
    return self;
}

- (void)setValueDict:(NSDictionary *)valueDict{
    [lock lock];
    _valueDict = [[NSDictionary alloc]initWithDictionary:valueDict];
    [lock unlock];
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
    
    //NSLog(@"OpenGlRenderer render!");
    
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
    
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, m_InputTextureId);
//    glUniform1i(textureUniform, 0);
    
    [lock lock];
    if(_valueDict!=nil){
        for (NSString* name in self.uniformNameList) {
            SettingCellValue* value = [_valueDict objectForKey:[NSString stringWithFormat:@"%@_%d",name,0]];
            if(value!=nil){
                GLfloat* vals = (GLfloat*)malloc(sizeof(GLfloat)*value.totalCnt);
                for (int i=0; i<value.totalCnt; i++) {
                    SettingCellValue* value2 = [_valueDict objectForKey:[NSString stringWithFormat:@"%@_%d",name,i]];
                    if(value2!=nil){
                        vals[i] = value2.value;
                    }else{
                        vals[i] = 0;
                    }
                }
                [self updateUniformValue:name type:value.uniformType index:value.uniformIndex withValue:vals];
                free(vals);
            }
        }
    }else{
        
    }
    [lock unlock];
    
    [self CheckGLError:@"render 2"];
    // Draw stuff
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
    
    [self CheckGLError:@"render 3"];
    
}

-(void)updateUniformValue:(NSString*)uniformName type:(int)uniformType index:(GLint)index withValue:(GLfloat*)number{
    if(uniformName!=nil){
        switch(uniformType){
            case GL_FLOAT:
                glUniform1f(index, number[0]);
                break;
            case GL_FLOAT_VEC2:
                glUniform2f(index, number[0], number[1]);
                break;
            case  GL_FLOAT_VEC3:
                glUniform3f(index, number[0], number[1], number[2]);
                break;
            case  GL_FLOAT_VEC4:
                glUniform4f(index, number[0], number[1], number[2], number[3]);
                break;
            case GL_INT:
                glUniform1i(index, (int)roundf(number[0]));
                break;
            case  GL_INT_VEC2:
                glUniform2i(index, (int)roundf(number[0]), (int)roundf(number[1]));
                break;
            case  GL_INT_VEC3:
                glUniform3i(index, (int)roundf(number[0]), (int)roundf(number[1]), (int)roundf(number[2]));
                break;
            case  GL_INT_VEC4:
                glUniform4i(index, number[0],(int)roundf(number[0]), (int)roundf(number[1]), (int)roundf(number[2]));
                break;
            case GL_BOOL:
                glUniform1i(index, (int)roundf(number[0]));
                break;
            case GL_BOOL_VEC2:
                glUniform2i(index, (int)roundf(number[0]), (int)roundf(number[1]));
                break;
            case GL_BOOL_VEC3:
                glUniform3i(index, (int)roundf(number[0]), (int)roundf(number[1]), (int)roundf(number[2]));
                break;
            case GL_BOOL_VEC4:
                glUniform4i(index, (int)roundf(number[0]), (int)roundf(number[1]), (int)roundf(number[2]), (int)roundf(number[3]));
                break;
            case GL_FLOAT_MAT2:
                glUniformMatrix2fv(index, 4, GL_FALSE, number);
                break;
            case GL_FLOAT_MAT3:
                glUniformMatrix3fv(index, 9, GL_FALSE, number);
                break;
            case  GL_FLOAT_MAT4:
                glUniformMatrix4fv(index, 16, GL_FALSE, number);
                break;
            case  GL_SAMPLER_2D:
                glUniform1i(index, (int)roundf(number[0]));
                break;
            case GL_SAMPLER_CUBE:
                
                break;
            default:
                break;
        }
    }
}

- (void) dealloc {
    NSLog(@"OpenGLRenderer dealloc!");
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
-(void)initializeGL:(NSError**)error{
    
    m_InputTextureId = 0;
    
    // 准备 着色器程序
    [self prepareShaderProgram:error];
    
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
-(void)prepareShaderProgram:(NSError**)error {
    
    NSLog(@"prepareShaderProgram!");
    
    //NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"Shader3" ofType:@"vs"]; // 读取文件路径
    //NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"Shader3" ofType:@"frag"];
    //m_program = [self loadShaders:vertFile frag:fragFile isFile:true]; //加载shader
    if(m_program>0){
        glDeleteProgram(m_program);
        m_program = 0;
    }
    m_program = [self loadShaders:self.vertexShader frag:self.fragmentShader isFile:false error:error];
    
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
        //exit( EXIT_FAILURE );
    }
        
    //use program object
    glUseProgram(m_program);
}


-(void)getUniformVariant{
    
    if(m_program==0){
        return;
    }
    NSMutableDictionary* udict = [NSMutableDictionary dictionary];
    NSMutableArray* nameList = [NSMutableArray array];
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
        
        GLint index = glGetUniformLocation(m_program, name);
        
        int cnt = [OpenGLRenderer getUniformCnt:type];
        int typeIndex = [OpenGLRenderer getUniformType:type];
        bool isInt = typeIndex == 0;
        bool isBool = typeIndex == 1;
        bool isFloat = typeIndex == 2;
        
        [nameList addObject:[NSString stringWithFormat:@"%s",name]];
        
        for (int i=0; i<cnt; i++) {
            SettingCellValue* value = [[SettingCellValue alloc]init];
            value.uniformType = type;
            value.uniformIndex = index;
            value.totalCnt = cnt;
            value.index = i;
            value.isBoolValue = isBool;
            value.isIntValue = isInt;
            value.isFloatValue = isFloat;
            value.uniformName = [NSString stringWithFormat:@"%s_%d",name,i];
            [udict setObject:value forKey:value.uniformName];
        }
        
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
    
    [lock lock];
    self.valueDict = [[NSDictionary alloc]initWithDictionary:udict];
    self.uniformNameList = [[NSArray alloc]initWithArray:nameList];
    [lock unlock];
    
    //glGetActiveUniformsiv(
    //glGetActiveUniform 和glGetActiveUniformsiv查找
}

-(void)updateUniformValue{
    [lock lock];
    if(self.valueDict!=nil){
        NSArray* list = self.valueDict.allValues;
        if(list!=nil){
            for(SettingCellValue* value in list){
                [value updateValue];
            }
        }
    }
    [lock unlock];
}

-(bool)addTexture:(NSString*)path image:(NSImage*)image at:(int)index{
    NSNumber* key = [NSNumber numberWithInt:index];
    NSNumber* texId = [textureDict objectForKey:key];
    if(texId!=nil){
        GLuint texs[1];
        texs[0] = texId.intValue;
        glDeleteTextures(1, texs);
        
    }
    int texture = [self genTexture:image index:index];
    if(texture>0){
        [textureDict setObject:[NSNumber numberWithInt:texture] forKey:key];
        
        glActiveTexture(GL_TEXTURE0 + index);
        glBindTexture(GL_TEXTURE_2D, texture);
        
        return true;
    }else{
        [textureDict setObject:[NSNumber numberWithInt:0] forKey:key];
    }
    return false;
}

- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag isFile:(bool)isFile error:(NSError**)error {
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    
    //编译
    verShader = [self compileShader:GL_VERTEX_SHADER shader:vert isFile:isFile error:error];
    if(*error){
        return 0;
    }
    fragShader = [self compileShader:GL_FRAGMENT_SHADER shader:frag isFile:isFile error:error];
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (GLuint)compileShader:(GLenum)type shader:(NSString *)file isFile:(bool)isFile error:(NSError**)error {
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
        if(error!=nil){
            if(type == GL_VERTEX_SHADER){
                *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Compile Vertex Shader error:%s", logMsg] code:-1 userInfo:nil];
            }else{
                *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Compile Fragment Shader error:%s", logMsg] code:-1 userInfo:nil];
            }
        }
        delete [] logMsg;
        //exit(EXIT_FAILURE);
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

- (int)setImage:(NSImage*) image{
    
    if(image==nil){
        return 0;
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
    
    return m_InputTextureId;
}

- (int)genTexture:(NSImage*) image index:(int)index{
    
    if(image==nil){
        return 0;
    }
    
    int iw = [image size].width;
    int ih = [image size].height;
    
    if(index==0){
        m_nVideoW = [image size].width; // 根据第0张图确定显示比例
        m_nVideoH = [image size].height;
    }
    
    GLuint texture;
    glActiveTexture(GL_TEXTURE0 + index);
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
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
    
    return texture;
}

-(void) CheckGLError:(NSString*)pGLOperation
{
    for (GLint error = glGetError(); error; error = glGetError())
    {
        NSLog(@"CheckGLError GL Operation %@ glError (0x%x)\n", pGLOperation, error);
    }
}

+(int)getUniformType:(int)type{
    if(type == GL_INT_VEC2
    || type == GL_INT_VEC3
    || type == GL_INT_VEC4
    || type == GL_INT
    || type == GL_SAMPLER_2D
       || type == GL_SAMPLER_CUBE ){
        return 0;
    }else if(type == GL_BOOL_VEC2
       || type == GL_BOOL_VEC3
       || type == GL_BOOL_VEC4
       || type == GL_BOOL )
    {
        return 1;
    }else{
        return 2;
    }
}

+(bool)isIntUniform:(int)type{
    if(type == GL_INT_VEC2
    || type == GL_INT_VEC3
    || type == GL_INT_VEC4
    || type == GL_INT
    || type == GL_SAMPLER_2D
    || type == GL_SAMPLER_CUBE )
        return true;
    return false;
}

+(bool)isBoolUniform:(int)type{
    if(type == GL_BOOL_VEC2
       || type == GL_BOOL_VEC3
       || type == GL_BOOL_VEC4
       || type == GL_BOOL)
        return true;
    return false;
}

+(bool)isFloatUniform:(int)type{
    if(type == GL_FLOAT_VEC2
       || type == GL_FLOAT_VEC3
       || type == GL_FLOAT_VEC4
       || type == GL_FLOAT
       || type == GL_FLOAT_MAT2
       || type == GL_FLOAT_MAT3
       || type == GL_FLOAT_MAT4)
        return true;
    return false;
}

+(int)getUniformCnt:(int)type{
    int cnt = 1;
    switch(type){
        case GL_FLOAT:
            cnt = 1;
            break;
        case GL_FLOAT_VEC2:
            cnt = 2;
            break;
        case  GL_FLOAT_VEC3:
            cnt = 3;
            break;
        case  GL_FLOAT_VEC4:
            cnt = 4;
            break;
        case GL_INT:
            cnt = 1;
            break;
        case  GL_INT_VEC2:
            cnt = 2;
            break;
        case  GL_INT_VEC3:
            cnt = 3;
            break;
        case  GL_INT_VEC4:
            cnt = 4;
            break;
        case GL_BOOL:
            cnt = 1;
            break;
        case GL_BOOL_VEC2:
            cnt = 2;
            break;
        case GL_BOOL_VEC3:
            cnt = 3;
            break;
        case GL_BOOL_VEC4:
            cnt = 4;
            break;
        case GL_FLOAT_MAT2:
            cnt = 4;
            break;
        case GL_FLOAT_MAT3:
            cnt = 9;
            break;
        case  GL_FLOAT_MAT4:
            cnt = 16;
            break;
        case  GL_SAMPLER_2D:
            cnt = 1;
            break;
        case GL_SAMPLER_CUBE:
            cnt = 1;
            break;
        default:
            break;
    }
    return cnt;
}


@end
