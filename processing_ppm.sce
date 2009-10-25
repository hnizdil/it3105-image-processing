getf('functions.sci');

//main program
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

fd = mopen('image.ppm', 'r');

mfscanf(fd, "%s");
dimension = mfscanf(fd ,"%u %u"); //[width height]
depth = mfscanf(fd, "%u"); // color depth
data = mfscanf(-1, fd, "%u %u %u");

mclose(fd);

red = data(:,1);
green = data(:,2);
blue = data(:,3);

data = []; //clear data

//build pixel matrices
red   = matrix(red,   dimension);
green = matrix(green, dimension);
blue  = matrix(blue,  dimension);

red_new   = proc(red,   mask1);
green_new = proc(green, mask1);
blue_new  = proc(blue,  mask1);

gen_ppm_color(red_new, green_new, blue_new, depth, "image_processed.ppm");

exit;
