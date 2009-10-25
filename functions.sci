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

function data = ppm_read(filename)
	fd = mopen(filename, 'r');

	// skip the magic number and comment lines
	mfscanf(fd, "%s %s");

	dims  = mfscanf(fd, "%u %u");
	depth = mfscanf(fd, "%u");
	data  = mfscanf(-1, fd, "%u %u %u");

	mclose(fd);

	// reformat data to three columns
	data = matrix(data, prod(size(data))/3, 3);
	data = list(    ...
		data(:, 1), ...
		data(:, 2), ...
		data(:, 3), ...
		dims,       ...
		depth       ...
	);
endfunction

function bool = ppm_from_ascii(base, dims)
	ppm = zeros(prod(dims), 3);

	// red
	temp = fscanfMat(base + '.red.asc');
	ppm(:, 1) = matrix(temp, prod(dims), 1);

	// green
	temp = fscanfMat(base + '.grn.asc');
	ppm(:, 2) = matrix(temp, prod(dims), 1);

	// blue
	temp = fscanfMat(base + '.blu.asc');
	ppm(:, 3) = matrix(temp, prod(dims), 1);

	header = [
		'P3',
		'#',
		sprintf('%u %u', dims(1), dims(2)),
		sprintf('%u', max(ppm))
	];

	fprintfMat(base + '.ppm', ppm, '%12.0f', header);

	bool = %T;
endfunction

function bool = pgm_from_ascii(base, dims)
	// gray
	pgm = fscanfMat(base + '.asc');
	pgm = matrix(pgm($:-1:1,:), prod(dims), 1);

	header = [
		'P2',
		'#',
		sprintf('%u %u', dims(1), dims(2)),
		sprintf('%u', max(pgm))
	];

	fprintfMat(base + '.pgm', pgm, '%12.0f', header);

	bool = %T;
endfunction
