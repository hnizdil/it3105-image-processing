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
		matrix(data(:, 1), dims), ...
		matrix(data(:, 2), dims), ...
		matrix(data(:, 3), dims), ...
		depth       ...
	);
endfunction

function bool = ppm_from_ascii(base, dims)
	ppm = zeros(prod(dims), 3);

	// red
	temp = fscanfMat(base + '.red.asc');
	temp = temp($:-1:1, :);
	fprintfMat('temp.red.asc', temp);
	ppm(:, 1) = matrix(temp', prod(dims), 1);

	// green
	temp = fscanfMat(base + '.grn.asc');
	//ppm(:, 2) = matrix(temp', prod(dims), 1);

	// blue
	temp = fscanfMat(base + '.blu.asc');
	//ppm(:, 3) = matrix(temp', prod(dims), 1);

	header = [
		'P3',
		'#',
		sprintf('%u %u', dims(1), dims(2)),
		sprintf('%u', max(ppm))
	];
	fprintfMat('temp.red.asc.proc', ppm);

	fprintfMat(base + '.ppm', ppm, '%0.0f', header);

	bool = %T;
endfunction

function bool = pgm_from_ascii(base, dims)
	// gray
	pgm = fscanfMat(base + '.asc');
	pgm = matrix(pgm', prod(dims), 1);

	header = [
		'P2',
		'#',
		sprintf('%u %u', dims(1), dims(2)),
		sprintf('%u', max(pgm))
	];

	fprintfMat(base + '.pgm', pgm($:-1:1,:), '%0.0f', header);

	bool = %T;
endfunction

function data = pgm_read(filename)
	fd = mopen(filename, 'r');

	// skip the magic number and comment lines
	mfscanf(fd, "%s %s");

	dims  = mfscanf(fd, "%u %u");
	depth = mfscanf(fd, "%u");
	data  = mfscanf(-1, fd, "%u");

	mclose(fd);

	data = list(             ...
		matrix(data, dims)', ...
		depth                ...
	);
endfunction

function bool = pgm_write(filename, data, depth)
	header = [
		'P2',
		'#',
		sprintf('%u %u', size(data)),
		sprintf('%u', depth)
	];

	fprintfMat(filename, data, '%0.0f', header);

	bool = %T;
endfunction

function thres = thres_otsu_get(data)
	top  = max(data);
	area = size(data, '*');
	prob = zeros(1, top+1);
	wcv  = zeros(1, top+1);

	// count intensity level probabilities
	for l = 0 : top, prob(l+1) = sum(data == l), end

	for t = 0 : top
		plow  = prob(1:t);
		phigh = prob(t+1:$);

		llow  = [0:t-1];
		lhigh = [t:top];

		// weights
		wb = sum(plow) / area;
		wf = 1 - wb;

		// means
		mb = meanf(llow, plow);
		mf = meanf(lhigh, phigh);

		// variances
		vb = meanf((llow - mb)^2, plow);
		vf = meanf((lhigh - mf)^2, phigh);

		wcv(t+1) = wb*vb + wf*vf;
	end

	thres = floor(mean(find(wcv == min(wcv)) - 1));
endfunction

function thres = thres_cr_get(data)
	// initial threshold
	thres = floor(max(data) / 2);

	while %T do
		nt = floor((mean(data(data < thres)) + mean(data(data >= thres))) / 2);
		if (nt == thres), break, else, thres = nt, end
	end
endfunction

function data = thres_gray_apply(data, thres, depth)
	tmin = min(thres);
	tmax = max(thres);
	count = size(thres, '*');
	thres = gsort(thres, 'g', 'i');

	for i = 1 : size(data, 1)
		for j = 1 : size(data, 2)
			if (data(i, j) < tmin)
				data(i, j) = 0;
			elseif (data(i, j) >= tmax)
				data(i, j) = depth;
			elseif (count > 1)
				for t = thres(1, 2:$)
					if (data(i, j) < t)
						data(i, j) = t-40;
						break;
					end
				end
			end
		end
	end
endfunction

function bcms = bcms_bi_get(data)
	// Normalize matrix
	data = data / max(data);

	dims = size(data);

	// x center
	xcnt = floor(mean(find(data>0) / dims(1)));

	// y center
	ycnt = floor(mean(modulo(find(data>0), dims(1))));

	// body centered moment
	u = zeros(4, 4);
	u(1,1) = bcm_get(data, xcnt, ycnt, 0, 0);

	for p = 0 : 3
		for q = 0 : 3
			u(p+1, q+1) = bcm_get(data, xcnt, ycnt, p, q) / (u(1,1)^((p+q)/2+1));
		end
	end

	// h1 = u20 + u02
	h1 = u(3,1) + u(1,3);

	// h2 = (u20 - u02)^2 + 4*u11^2
	h2 = (u(3,1) - u(1,3))^2 + 4*u(2,2)^2

	// h3 = (u30 - 3*u12)^2 + (3*u21 - u03)^2
	h3 = (u(4,1) - 3*u(2,3))^2 + (3*u(3,2) - u(1,4))^2;

	// h4 = (u30 + u12)^2 + (u21 + u03)^2
	h4 = (u(4,1) + u(2,3))^2 + (u(3,2) + u(1,4))^2

	bcms = [h1, h2, h3, h4];
endfunction

function bcm = bcm_get(data, xcnt, ycnt, p, q)
	bcm = 0;
	for i = 1 : dims(1)
		for j = 1 : dims(2)
			bcm = bcm + (i-xcnt)^p * (j-ycnt)^q * data(i, j);
		end
	end
endfunction
