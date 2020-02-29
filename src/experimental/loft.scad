use <experimental/sweep.scad>;
   
module loft(sections) {
    function gcd(m, n) = n == 0 ? m : gcd(n, m % n);

    function lcm(m, n) = m * n / gcd(m, n);

    function inter_pts(p1, p2, n) =
        let(
            v = p2 - p1,
            dx = v[0] / n,
            dy = v[1] / n,
            dz = v[2] / n
        )
        [for(i = [1:n - 1]) p1 + [dx, dy, dz] * i];

    function _interpolate(sect, leng, n, i = 0) = 
        i == leng ? [] :
        let(
            p1 = sect[i],
            p2 = sect[(i + 1) % leng]
        )
        concat(
            [p1], 
            inter_pts(p1, p2, n),
            _interpolate(sect, leng, n, i + 1)
        );

    function interpolate(sect, n) = 
        n <= 1 ? sect : _interpolate(sect, len(sect), n);
        
    module _loft(sect1, sect2) {
        lcm_n = lcm(len(sect1), len(sect2));
        new_sect1 = interpolate(sect1, lcm_n / len(sect1));
        new_sect2 = interpolate(sect2, lcm_n / len(sect2));
        
        sweep([new_sect1, new_sect2]);
    }
        
    for(i = [0:len(sections) - 2]) {
        _loft(sections[i], sections[i + 1]);
    }
}