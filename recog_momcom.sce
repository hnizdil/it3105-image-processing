getf('functions.sci');

//
// get reference images and do the threshold
//

// function for converting ascii to pgm
function fnames = patt_ascii_to_pgm(patt)
	clr = 'red';
	path = 'recog/';
	fnames = list();
	for i = 1 : 3
		fname = path + patt + string(i) + '.' + clr;
		pgm_from_ascii(fname, [128 128]);
		fnames($+1) = fname + '.pgm';
	end
endfunction

// do conversions
pattsc = patt_ascii_to_pgm('circle');
pattss = patt_ascii_to_pgm('square');
pattst = patt_ascii_to_pgm('triangle');

// threshold
for fname = lstcat(pattsc, pattss, pattst)
	pgm = pgm_read(fname);
	thres = thres_otsu_get(pgm(1));
	pgm(1) = thres_gray_apply(pgm(1), thres, pgm(2));
	pgm_write(fname, pgm(1), pgm(2));
end

//
// calculate moment combinations
//

function fname = momcom_calc(fnames, patt)
	fname = patt + '_momcom.txt';

	combos = zeros(size(fnames), 4);

	for i = 1 : size(fnames)
		pgm = pgm_read(fnames(i));
		combos(i, :) = bcms_bi_get(pgm(1));
	end

	fprintfMat(fname, combos);
endfunction

momcom_calc(pattsc, 'circle');
momcom_calc(pattss, 'square');
momcom_calc(pattst, 'triangle');

exit;
