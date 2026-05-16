precision highp float;

// Helper for 0..255 RGB(A) to 0..1 vec4
#define RGB8(r,g,b)   (vec4((r)/255.0, (g)/255.0, (b)/255.0, 1.0))
#define RGBA8(r,g,b,a) (vec4((r)/255.0, (g)/255.0, (b)/255.0, (a)/255.0))

// Borders (pie chart ring)   = #666666
// const vec4 border_color  = RGB8(159.0, 163.0, 178.0);
// const vec4 border_color  = RGB8(255.0, 255.0, 255.0);
// const vec4 border_color  = RGB8(0.0, 0.0, 0.0);
const vec4 border_color  = RGB8(102.0, 102.0, 102.0);

// Pie Chart 1 (entities)     = #E446C4 (hot pink)
const vec4 pie1_color    = RGB8(228.0, 70.0, 196.0);

// Pie Chart 2 (unspecified)   = #46CE66 (green)
const vec4 pie2_color    = RGB8(70.0, 206.0, 102.0);

// Pie Chart 3 (blockentities) = #EC6E4E (orange)
const vec4 pie3_color    = RGB8(236.0, 110.0, 78.0);

// Text                     = #F2F2F7
const vec4 text_color    = RGB8(242.0, 242.0, 247.0);

// Text Background          = #0A0A12
const vec4 text_bg_color = RGB8(10.0, 10.0, 18.0);

