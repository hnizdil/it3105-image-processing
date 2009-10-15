//function that processes pixel-matrices with a given 3x3 mask
function y = proc(pm, mask)	//parameters pixel-matrix, mask
 img_size = size(pm);
 result = zeros(img_size(1),img_size(2));
 for i=2:(img_size(1)-1)  //rastering vertically
  for j=2:(img_size(2)-1)  //rastering horizontly
    result(i,j)= ...
    (pm(i-1,j-1)*mask(1,1)) + ...
    (pm(i,j-1)*mask(2,1)) + ...
    (pm(i+1,j-1)*mask(3,1)) + ...
    (pm(i-1,j)*mask(1,2)) + ...
    (pm(i,j)*mask(2,2)) + ...
    (pm(i+1,j)*mask(3,2)) + ...
    (pm(i-1,j+1)*mask(1,3)) + ...
    (pm(i,j+1)*mask(2,3)) + ...
    (pm(i+1,j+1)*mask(3,3));
  end
 end
 y = result;    
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
  [h w]=size(r); //same for all 'channels'
  //make header
  mfprintf(fd2,"P3\n%d %d\n%d\n",h,w,depth);
  r = r';
  g = g';
  b = b';
  for i=1:length(r)
    mfprintf(fd2,"%d %d %d\n",r(i),g(i),b(i));
  end  
  mclose(fd2);
  bool = %T;
endfunction  
