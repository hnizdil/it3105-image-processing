//main program
mask1=[-1 0 1;-2 0 2;-1 0 1];
mask2=[1 2 1;0 0 0;-1 -2 -1];
fd = mopen("image.asc",'r');
data = mfscanf(-1, fd, "%d");
dimension = sqrt(length(data));
//something wrong in the image rotation
data = (matrix(data,dimension,dimension));
//matrices for both masks
data_new1 = proc(data, mask1);
data_new2 = proc(data, mask2);
//add absolute values
data_new = abs(data_new1)+abs(data_new2);
//the processed image is of format PGM and named like below
gen_pgm_gray(data_new,"image_processed.pgm");
mclose('all'); //or only the file fd
