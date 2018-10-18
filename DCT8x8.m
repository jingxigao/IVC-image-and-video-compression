function [im_c]=DCT8x8(im)
im_c=dct(dct(im,8)',8)';
end