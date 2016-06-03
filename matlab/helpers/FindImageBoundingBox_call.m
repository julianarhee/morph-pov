% �������������������������������������������������������������������
%
%                    FindImageBoundingBox_call
%         
% �������������������������������������������������������������������
%
%
%  Find the coordinates of a box that contains the image
%
%   CALLING FUNCTIONS:
%       - ResizeStimSetToMatchFrameBoundaries
%       - ResizeBlobRatStims
%
%   Author: davide
%
% �������������������������������������������������������������������

function [col_bounds, row_bounds] = FindImageBoundingBox_call(img, FlagPlotBoundaries)

% disp( '... in FindImageBoundingBox_call' );

[im_rows im_cols] = size(img);
hold on;    
% Find boundaries (pixels higher than black background)
[j, i] = find(img > 40);
i_min = min(i);
i_max = max(i);
j_min = min(j);
j_max = max(j);

if FlagPlotBoundaries
    % Plot edges of the image
    plot( [i_min i_min], [0 im_rows], 'r');
    plot( [i_max i_max], [0 im_rows], 'r');
    plot( [0 im_cols], [j_min j_min], 'g');
    plot( [0 im_cols], [j_max j_max], 'g');
end;

col_bounds = [i_min, i_max];
row_bounds = [j_min, j_max];

disp(['Image boundaries: rows = (', num2str(row_bounds(1)), ',', num2str(row_bounds(2)), ')']);
disp(['Image boundaries: cols = (', num2str(col_bounds(1)), ',', num2str(col_bounds(2)), ')']);

% disp( '... END of FindImageBoundingBox_call' );
