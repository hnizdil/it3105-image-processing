//function that processes pixel-matrices with a given 3x3 mask
function y = proc(pm, mask)	//parameters pixel-matrix, mask
	img_size = size(pm);
	y = zeros(img_size(1), img_size(2));
	for i = 2:(img_size(1)-1)  //rastering vertically
		for j = 2:(img_size(2)-1)  //rastering horizontly
			y(i, j) = ...
				pm(i-1, j-1) * mask(1,1) + ...
				pm(i,   j-1) * mask(1,2) + ...
				pm(i+1, j-1) * mask(1,3) + ...
				pm(i-1, j)   * mask(2,1) + ...
				pm(i,   j)   * mask(2,2) + ...
				pm(i+1, j)   * mask(2,3) + ...
				pm(i-1, j+1) * mask(3,1) + ...
				pm(i,   j+1) * mask(3,2) + ...
				pm(i+1, j+1) * mask(3,3);
		end
	end
	y = round(abs(y));
endfunction

//generates a new grayscale pgm-file out of the pixel matrix p
function bool = gen_pgm_gray(p,name)
  fd = mopen(name, 'w');
  [h w]=size(p);
  depth = max(p);
  //make header
  mfprintf(fd,"P2\n%d %d\n%d\n",h,w,depth);
  p = p';
  for i=1:(h*w)
    mfprintf(fd,"%d\n",p(i));
  end 
  mclose(fd);
  bool = %T;
endfunction

//generates a new ppm-file out of the processed rgb-matrices
function bool = gen_ppm_color(r,g,b, depth, name)
	fd2 = mopen(name,'w');
	[h w] = size(r); //same for all 'channels'

	//make header
	mfprintf(fd2, "P3\n#\n%u %u\n%u\n", h, w, depth);

	for i = 1:length(r)
		mfprintf(fd2, "%u %u %u\n", r(i), g(i), b(i));
	end

	mclose(fd2);

	bool = %T;
endfunction

function mask = gaussian_mask(dim)
	radius = 4;
	center = ceil(dim / 2);
	mask = zeros(dim, dim);

	for i = 1:dim
		for j = 1:dim
			x = (j - center) / center * radius;
			y = (i - center) / center * radius;
			mask(i, j) = exp(-(x^2 + y^2) / 2) / 2 / %pi;
		end
	end
endfunction
