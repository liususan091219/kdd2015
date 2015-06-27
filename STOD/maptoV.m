% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% map a nz matrix to its original sparse matrix, size(mat,2) =
% size(voc_V_map)
% =======================================================================
function new_mat = maptoV(mat, voc_V_map, voc_size)
new_mat = zeros(size(mat, 1), voc_size);
new_mat(:, voc_V_map) = mat;
end