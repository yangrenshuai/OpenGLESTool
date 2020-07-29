varying vec2 textureOut;
uniform sampler2D tex;
void main(void)
{
    gl_FragColor = texture2D(tex, textureOut);
    //gl_FragColor = vec4(textureOut.x,0.0,0.0,1.0);
    
//    if(textureOut.r<0.5){
//        gl_FragColor = vec4(1.0,0.0,0.0,1.0);
//    }else{
//      gl_FragColor = texture2D(tex, textureOut);
//    }
}
