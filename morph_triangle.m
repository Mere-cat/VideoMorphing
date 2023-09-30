function morphed_im = morph_triangle(im1, im2, im1_pts, im2_pts, tri, warp_frac, alpha)
% Morph image.
inter_shape_pts = warp_frac * im2_pts + (1 - warp_frac) * im1_pts;
im1_warp = affine_warp(im1, im1_pts, inter_shape_pts, tri);
im2_warp = affine_warp(im2, im2_pts, inter_shape_pts, tri);

% And then cross-dissolved according to alpha.
morphed_im = alpha * im2_warp + (1 - alpha) * im1_warp;
end