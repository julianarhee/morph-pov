% �������������������������������������������������������������������
%
%                    PasteImageIntoBackground_call
%         
% �������������������������������������������������������������������
%
%
%  Place an image in the center of a user defined black background
%
%   INPUTS:
%
%   1) img: image (bitmap)
%   2) Nrows_bck: # of rows in the background
%   3) Ncols_bck: # of cols in the background
%
%   Author: davide
%
% �������������������������������������������������������������������

function [img_new] = PasteImageIntoBackground_call( img, Nrows_bck, Ncols_bck )

% disp( '... in PasteImageIntoBackground_call' );

[im_rows im_cols] = size(img);
disp(['Image size = (', num2str(im_rows), 'x', num2str(im_cols), ')']);

% Sanity check on the background dimensions
if im_rows > Nrows_bck | im_cols > Ncols_bck
    disp(['ERROR! the size of the background is smaller than the size of the image (', ...
        num2str(im_rows), 'x', num2str(im_cols), ')']);
    return;
end;

% if the # of rows (columns) in the image is even, so must be the # of rows
% (colums) in the background (to place the image exactly in the middle)
% if rem(im_rows,2) == 0
%     if rem(Nrows_bck,2) ~= 0
%         Nrows_bck = Nrows_bck+1;
%         disp(['NOTE: the # of rows of the background was increased of 1. It is now = ', num2str(Nrows_bck)]);
%     end; 
% else
%     if rem(Nrows_bck,2) == 0
%         Nrows_bck = Nrows_bck+1;
%         disp(['NOTE: the # of rows of the background was increased of 1. It is now = ', num2str(Nrows_bck)]);
%     end; 
% end;
% if rem(im_cols,2) == 0
%     if rem(Ncols_bck,2) ~= 0
%         Ncols_bck = Ncols_bck+1;
%         disp(['NOTE: the # of columns of the background was increased of 1. It is now = ', num2str(Ncols_bck)]);
%     end; 
% else
%     if rem(Ncols_bck,2) == 0
%         Ncols_bck = Ncols_bck+1;
%         disp(['NOTE: the # of columns of the background was increased of 1. It is now = ', num2str(Ncols_bck)]);
%     end; 
% end;

% Create background and add image in its center
img_new = zeros( Nrows_bck, Ncols_bck );
img_new = uint8(img_new);
D_rows = Nrows_bck - im_rows;
D_cols = Ncols_bck - im_cols;
% img_new( ceil(D_rows/2+1):ceil(D_rows/2+im_rows), D_cols/2+1:D_cols/2+im_cols ) = img;
img_new( round(D_rows/2+1):round(D_rows/2+im_rows), D_cols/2+1:D_cols/2+im_cols ) = img;


% figure;
% imshow(img_new);
% 
% disp( '... END of PasteImageIntoBackground_call' );



