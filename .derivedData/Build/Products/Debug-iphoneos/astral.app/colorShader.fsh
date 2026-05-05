void main()
{
    vec4 textureColor = texture2D(u_texture, v_tex_coord);
    gl_FragColor = u_color * textureColor;
}
