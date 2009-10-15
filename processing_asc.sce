//main program
mask1=[-1 0 1;-2 0 2;-1 0 1];
mask2=[1 2 1;0 0 0;-1 -2 -1];
fd = mopen("image.asc",'r');
data = mfscanf(-1, fd, "%d");
dimension = sqrt(length(data));
data = (matrix(data,dimension,dimension))';
data_new1 = proc(data, mask1);
data_new2 = proc(data, mask2);
data_new = data_new1+data_new2;
gen_pgm_gray(data_new,"image_processed.pgm");
mclose('all'); //or only the file fd
