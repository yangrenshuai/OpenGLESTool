//#version 320
attribute vec4 vertexIn;
attribute vec2 textureIn;
varying vec2 textureOut;
uniform mat4 trans;

//attribute vec4 position;
//attribute vec4 inputTextureCoordinate;
//varying vec2 textureCoordinate;

void main(void)
{
    gl_Position = vertexIn;
    textureOut = (vec4(textureIn,1.0,1.0)*trans).xy;
    textureOut = textureIn;
//    gl_Position = position;
//    textureCoordinate = inputTextureCoordinate.xy;
}
