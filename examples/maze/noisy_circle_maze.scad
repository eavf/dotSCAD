use <hull_polyline2d.scad>;
use <util/rand.scad>;
use <maze/mz_blocks.scad>;
use <maze/mz_square_walls.scad>;
use <ptf/ptf_circle.scad>;
use <noise/nz_perlin2.scad>;

module noisy_circle_maze(start, r_blocks, block_width, wall_thickness, origin_offset, noisy_factor) {
    double_r_blocks = r_blocks * 2;
    blocks = mz_blocks(
        start,  
        double_r_blocks, double_r_blocks
    );

    width = double_r_blocks * block_width;
    walls = mz_square_walls(blocks, double_r_blocks, double_r_blocks, block_width);
    
    half_width =  width / 2;
    rect_size = is_undef(origin_offset) ? [width, width] : [width, width] - origin_offset * 2;

    noisy_f = is_undef(noisy_factor) ? 1 : noisy_factor;
    
    seed = rand(0, 256);
    for(wall = walls) {
        for(i = [0:len(wall) - 2]) {
            p0 = ptf_circle(rect_size, wall[i]);
            p1 = ptf_circle(rect_size, wall[i + 1]);
            pn00 = nz_perlin2(p0[0], p0[1], seed) * noisy_f;
            pn01 = nz_perlin2(p0[0] + seed, p0[1] + seed, seed) * noisy_f;
            pn10 = nz_perlin2(p1[0], p1[1], seed) * noisy_f;
            pn11 = nz_perlin2(p1[0] + seed, p1[1] + seed, seed) * noisy_f;
            hull_polyline2d([p0 + [pn00, pn01], p1 + [pn10, pn11]], width = wall_thickness);
        }
    } 
}

noisy_circle_maze(
    start = [1, 1], 
    r_blocks = 8, 
    block_width = 5, 
    wall_thickness = 2,
    noisy_factor = 2
);