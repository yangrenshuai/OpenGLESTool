attribute vec4 vertexIn;
attribute vec2 textureIn;
varying vec2 textureOut;
//uniform mat4 trans;

void main(void)
{
    gl_Position = vertexIn;
    //textureOut = (vec4(textureIn,1.0,1.0)*trans).xy;
    textureOut = textureIn;
}
