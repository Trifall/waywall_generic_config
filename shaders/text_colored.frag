precision highp float;

#define RGB8(r,g,b)   (vec4((r)/255.0, (g)/255.0, (b)/255.0, 1.0))
#define RGBA8(r,g,b,a) (vec4((r)/255.0, (g)/255.0, (b)/255.0, (a)/255.0))

//------------------------------------------------------------------------------------------------

varying vec2 f_src_pos;

uniform sampler2D u_texture;

const float threshold = 0.04;

// Text colors from the debug screen percentage display
const vec3 ecounter      = vec3(0.867, 0.867, 0.867);       // #DDDDDD (white/gray text labels)
const vec3 entities      = vec3(0.882, 0.271, 0.761);       // #E145C2 (pink - entities %)
const vec3 blockentities = vec3(0.914, 0.427, 0.302);       // #E96D4D (orange - blockentities %)
const vec3 unspecified   = vec3(0.271, 0.796, 0.396);       // #45CB65 (green - unspecified %)
const vec3 mob_spawner   = vec3(0.306, 0.890, 0.800);       // #4EE3CC (cyan - mob_spawner %)
const vec3 chest         = vec3(0.773, 0.427, 0.894);       // #C56DE4 (purple - chest %)

void main() {
    vec4 color = texture2D(u_texture, f_src_pos);

    bool is_ecounter = all(lessThan(abs(color.rgb - ecounter), vec3(threshold)));
    bool is_entities = all(lessThan(abs(color.rgb - entities), vec3(threshold)));
    bool is_blockentities = all(lessThan(abs(color.rgb - blockentities), vec3(threshold)));
    bool is_unspecified = all(lessThan(abs(color.rgb - unspecified), vec3(threshold)));
    bool is_mob_spawner = all(lessThan(abs(color.rgb - mob_spawner), vec3(threshold)));
    bool is_chest = all(lessThan(abs(color.rgb - chest), vec3(threshold)));

    if ( is_ecounter || is_entities || is_blockentities || is_unspecified || is_mob_spawner || is_chest ) {
        // Preserve the original text color
        gl_FragColor = color;
    }
    else {
        // Make everything else (game background) fully transparent
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}

// vim:ft=glsl
