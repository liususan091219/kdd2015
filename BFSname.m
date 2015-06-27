% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =======================================================================
% re-name node's in a tree after MER or MOV
% =======================================================================

function BFSname(rootnode, rootname)
    rootnode.name = rootname;
    if isempty(rootnode.children) == 0
        for i = 1:size(rootnode.children, 2)
            BFSname(rootnode.children{i}, [rootname, num2str(i)]);
        end
    end
end