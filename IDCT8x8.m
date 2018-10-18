function [im]=IDCT8x8(im_c)
im=idct(idct(im_c,8)',8)';
end