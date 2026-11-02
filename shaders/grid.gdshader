shader_type spatial; 
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

// Allows changing colors and sizes in the Godot Inspector
uniform vec4 bg_color : source_color = vec4(0.15, 0.15, 0.15, 1.0); // Dark grey background
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // White grid lines
uniform float grid_size = 1.0;       // Size of each grid square in meters
uniform float line_thickness = 0.05; // Thickness of the grid line

// Forces the shader to project the grid perfectly on stretched surfaces
varying vec3 world_position;

void vertex() {
    // Collects the real-world 3D coordinates of the block
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Calculates where the pixel is relative to the grid size
    vec3 grid = abs(fract(world_position / grid_size - 0.5) - 0.5) / fwidth(world_position / grid_size);
    
    // Checks how close the pixel is to the border of a grid line
    float min_dist = min(min(grid.x, grid.y), grid.z);
    float line_mask = 1.0 - smoothstep(0.0, line_thickness * 20.0, min_dist);
    
    // Blends the background color and the line color together
    ALBEDO = mix(bg_color.rgb, line_color.rgb, line_mask);
}
