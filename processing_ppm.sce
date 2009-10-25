getf('functions.sci');

pgm_from_ascii('1.seg', [128 128]);
exit;

// main program
mask1 = [
	-1 0 1;
	-2 0 2;
	-1 0 1
];

mask2 = [
	 1  2  1;
	 0  0  0;
	-1 -2 -1
];

ppm = ppm_read('image.ppm');

red = ppm(1);
grn = ppm(2);
blu = ppm(3);

dimension = ppm(4);
depth = ppm(4);

// build pixel matrices
red = matrix(red, dimension);
grn = matrix(grn, dimension);
blu = matrix(blu, dimension);

// Edge enhancement
enh_red = proc(red, mask1) + proc(red, mask2);
enh_grn = proc(grn, mask1) + proc(grn, mask2);
enh_blu = proc(blu, mask1) + proc(blu, mask2);
gen_ppm_color(enh_red, enh_grn, enh_blu, depth, "image_enhanced.ppm");

// gaussian blur 5
gauss = gaussian_mask(5);
ga5_red = proc(red, gauss);
ga5_grn = proc(grn, gauss);
ga5_blu = proc(blu, gauss);
gen_ppm_color(ga5_red, ga5_grn, ga5_blu, depth, "image_gauss5.ppm");

// gaussian blur 9
gauss = gaussian_mask(9);
ga9_red = proc(red, gauss);
ga9_grn = proc(grn, gauss);
ga9_blu = proc(blu, gauss);
gen_ppm_color(ga9_red, ga9_grn, ga9_blu, depth, "image_gauss9.ppm");

// difference between gaussians
gen_ppm_color( ...
	abs(ga5_red - ga9_red), ...
	abs(ga5_grn - ga9_grn), ...
	abs(ga5_blu - ga9_blu), ...
	depth, ...
	"image_gaussdiff.ppm" ...
);

exit;
