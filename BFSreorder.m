% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =======================================================================
% re-order each node's children such that nodes corresponding to larger
% alpha is put ahead
% =======================================================================

function BFSreorder(rootnode)
    rootalpha = [];
    if isempty(rootnode.children) == 0
        for i = 1:size(rootnode.children, 2)
            rootalpha = [rootalpha, rootnode.children{i}.alpha0];
        end
        [sortedalpha, ind] = sort(rootalpha, 'descend');
        tmp_cell = cell(1, size(rootnode.children, 2));
        for i = 1:size(rootnode.children, 2)
            tmp_cell{i} = rootnode.children{ind(i)};
        end
        rootnode.children = tmp_cell;
        rootnode.twmatparent = rootnode.twmatparent(ind, :);
        rootnode.pz = rootnode.pz(ind);
        for i = 1:size(rootnode.children, 2)
            BFSreorder(rootnode.children{i});
        end
    end
end