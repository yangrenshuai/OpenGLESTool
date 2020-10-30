varying vec2 textureOut;
uniform sampler2D tex;
void main(void)
{
    gl_FragColor = texture2D(tex, textureOut);
}
