function new_mat = bsxrdivide(mat, dividebymat)
new_mat = bsxfun(@rdivide, mat, dividebymat);
[rows, cols] = find(isnan(new_mat));
if isempty(rows) == 0
    for i = 1:size(rows)
        new_mat(rows(i), cols(i)) = 0;
    end
end
end