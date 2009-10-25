//function that processes pixel-matrices with a given 3x3 mask
function y = proc(pm, mask)	//parameters pixel-matrix, mask
	isize = size(pm);
	mdims = size(mask);

	// We need mask dimensions to be odd
	if (~min(modulo(mdims, 2)))
		disp('Mask dimensions have to be odd');
		exit;
	end

	mcnt = floor(mdims / 2);

	y = zeros(isize(1), isize(2));

	for i = mcnt(1)+1 : isize(1)-mcnt(1)
		for j = mcnt(2)+1 : isize(2)-mcnt(2)
			y(i, j) = y(i, j) + sum(pm(i-mcnt(1):i+mcnt(1), j-mcnt(2):j+mcnt(2)) .* mask);
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
  for i=1:(h*w)
    mfprintf(fd,"%d\n",p(i));
  end 
  mclose(fd);
  bool = %T;
endfunction

//generates a new ppm-file out of the processed rgb-matrices
function bool = gen_ppm_color(r,g,b, depth, name)
	[h w] = size(r); //same for all 'channels'

	fd2 = mopen(name,'w');

	// make header
	mfprintf(fd2, "P3\n#\n%u %u\n%u\n", h, w, depth);

	for i = 1:length(r)
		mfprintf(fd2, "%u %u %u\n", r(i), g(i), b(i));
	end

	mclose(fd2);

	bool = %T;
endfunction

function mask = gaussian_mask(dim)
	radius = 4;
	cnt = ceil(dim / 2);
	mask = zeros(dim, dim);

	for i = 1:dim
		for j = 1:dim
			x = (j - cnt) / cnt * radius;
			y = (i - cnt) / cnt * radius;
			mask(i, j) = exp(-(x^2 + y^2) / 2) / 2 / %pi;
		end
	end

	mask = mask / sum(mask);
endfunction
