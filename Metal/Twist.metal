//
//  Twist.metal
//  Yomu
//
//  Created by Andrew Joe on 2025-08-14.
//

#include <metal_stdlib>
using namespace metal;

// Calculates the uv space rotation for a specified angle given in radians.
//
// - Parameter angle: an angle in radians.
//
// - Returns: a 2 by 2 matrix that rotates a point in uv space when multiplied with a given value.
float2x2 rotate(float sinAngle, float cosAngle) {
    return float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
}

// Warps some coordinates around an offset by applying a rotation based on a given points distance to the offset.
// (paraphrased from Sam Henri Gold)
//
// - Parameters:
//  - position: the user-space coordinates of the destination pixel applied to the shader (direct quote from Apple docs).
//  - size: the pixel size of the view this shader is being applied to.
//  - offset: any point on the view this shader is being applied to.
//
// - Returns: the transformed point.
//
//
// #See
// [Sam Henri Gold](https://xcancel.com/samhenrigold/status/1765220903963574290?t=f6yzllz-v9kkzkl7md9BkA&s=19#m)
[[ stitchable ]] float2 warp(float2 position, float2 size, float2 offset) {
    float2 uv = position / size;
    float2 center = uv - 0.5;
    float2 wz = offset / size;
    
    float aspectRatio = size.x / size.y;
    
    float radius = 0.5;
    float angle = pow((distance(uv, wz) / radius), 2);
    
    center.y /= aspectRatio;
    center *= rotate(sin(angle), cos(angle));
    center.y *= aspectRatio;

    return (center + 0.5) * size;
}
