// Global uniform with viewport and tick fields
struct Global {
    camera: vec3<f32>,
    tick: u32,
    viewport: vec2<f32>,
}

@group(0) @binding(0)
var<uniform> global: Global;

// Vertex input to the shader
struct VertexInput {
    @location(0) pos: vec2<f32>,
    @location(1) uv: vec2<f32>,
};

// Output color fragment from the shader
struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(1) uv: vec2<f32>,
};

// Main vertex shader function
@vertex
fn vs_main(in: VertexInput) -> VertexOutput {
    var out: VertexOutput;
    out.position = vec4<f32>(in.pos, 0., 1.);
    out.uv = in.uv;
    return out;
}

// Bindings for the texture
@group(1) @binding(0)
var t_canvas: texture_2d<f32>;

// Sampler for the texture
@group(1) @binding(1)
var s_canvas: sampler;

// Main fragment shader function
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    if global.camera.z == 1. {
        var color: vec4<f32> = textureSample(t_canvas, s_canvas, in.uv);
        var uv: vec2<f32> = in.uv;
        color = applyZoomPulse(color, &uv, global.tick * 30);
        color = applyWavy(color, &uv);
        color = applyChromaticAberration(color, &uv);
        color = applyColorCycle(color, uv, global.tick);
        return color;
        // return vec4<f32>(1., 1., 1., 1.);
    } else {
        return quantizedTextureSample(t_canvas, s_canvas, in.uv);
    }
}

fn quantizedTextureSample(t: texture_2d<f32>, s: sampler, uv: vec2<f32>) -> vec4<f32> {
    // Zoom factor
    let zoomFactor = global.camera.z;

    // Get texture size
    let textureSize = vec2<f32>(textureDimensions(t).xy);

    // Convert UV coordinates to pixel coordinates
    var pixelCoords = uv * textureSize;

    // Quantize the pixel coordinates
    var quantizedPixelCoords = floor(pixelCoords / zoomFactor) * zoomFactor;
    quantizedPixelCoords += zoomFactor * abs(fract(global.camera.xy)); // not sure if this does much tbh

    // Convert quantized pixel coordinates back to UV coordinates
    let quantizedUV = quantizedPixelCoords / textureSize;

    // Sample the texture at the quantized UV coordinates
    let quantizedColor = textureSample(t, s, quantizedUV);

    // return quantizedColor;
    return vec4<f32>(1., 1., 1., 1.);
}

fn applyZoomPulse(color: vec4<f32>, uv: ptr<function, vec2<f32>>, tick: u32) -> vec4<f32> {
    let center: vec2<f32> = vec2<f32>(0.5, 0.5);
    let time: f32 = f32(tick) * 0.02;
    let zoom: f32 = 1.0 + 0.1 * sin(time);
    *uv = center + (*uv - center) * zoom;
    return textureSample(t_canvas, s_canvas, *uv);
}

fn applyStrobeEffect(color: vec4<f32>, uv: vec2<f32>, tick: u32) -> vec4<f32> {
    let frequency: f32 = 10.0;
    let strobe: f32 = 0.5 + 0.5 * sin(frequency * f32(tick));
    return vec4<f32>(color.rgb * strobe, color.a);
}

fn applyColorCycle(color: vec4<f32>, uv: vec2<f32>, tick: u32) -> vec4<f32> {
    let time: f32 = f32(tick) * 0.1;
    let r: f32 = 0.5 + 0.5 * sin(time + uv.x);
    let g: f32 = 0.5 + 0.5 * sin(time + uv.y + 2.0);
    let b: f32 = 0.5 + 0.5 * sin(time + uv.x + 4.0);
    return mix(vec4<f32>(r, g, b, color.a), color, 0.8);
}

fn applyChromaticAberration(color: vec4<f32>, uv: ptr<function, vec2<f32>>) -> vec4<f32> {
    let amount: vec2<f32> = vec2<f32>(0.002, 0.002);
    let rUV: vec2<f32> = *uv + amount;
    let gUV: vec2<f32> = *uv;
    let bUV: vec2<f32> = *uv - amount;
    let rColor: f32 = textureSample(t_canvas, s_canvas, rUV).r;
    let gColor: f32 = textureSample(t_canvas, s_canvas, gUV).g;
    let bColor: f32 = textureSample(t_canvas, s_canvas, bUV).b;
    return vec4<f32>(rColor, gColor, bColor, color.a);
}

fn applyWavy(color: vec4<f32>, uv: ptr<function, vec2<f32>>) -> vec4<f32> {
    let frequency: f32 = 20.0;
    let amplitude: f32 = 0.005;
    *uv = vec2<f32>((*uv).x + sin((*uv).y * frequency) * amplitude, (*uv).y);
    return textureSample(t_canvas, s_canvas, *uv);
}
