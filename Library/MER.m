% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =======================================================================
% MER(t, leafpath1, leafpath2): merge two nodes into one node
% Parameters: 1. t: root node of the tree;
%             2. leafpath1: specify t1 with its path, for example
%             o/1/2's path is [1 2];
%             3. leafpath2: specify t2 with its path, for example
%             o/1/2's path is [1 2];
% =======================================================================
% MER contains 4 subroutines which specifies its 3 stages:
%   stage 1: merge_first: compute the change to the parent of t1 or t2 (if
%   it is not lca);
%   stage 2: merge_mid: compute the change to the ancestor and non-lca of
%   t1 or t2;
%   stage 3: merge_last_case1: compute the change to the lca, when the lca
%   is the same as t2;
%   stage 3: merge_last_case2: compute the change to the lca, when the lca
%   is neither t1 nor t2;
% =======================================================================
% MER special cases:
%   case 1: t2 is the lca of t1 and t2
%   case 1.1: t2 is the parent of t1
%   case 1.2: t1's children is empty
%   case 2: neither of t1 and t2 is their lca
%   case 2.1: lca is the parent of t1 or t2 (or both)
%   case 2.2: t1's or t2's (or both's) children is empty
% ======================================================================

function MER(t, leafpath1, leafpath2)
global voc_size pV

% merge the deeper node first, so don't need to change leafpath2 since
% leafpath2 is the parent node, after this swap, the only case leafpath2
% needs to change is when leafpath1 and leafpath2 are siblings
if size(leafpath1, 2) < size(leafpath2, 2)
    tmp = leafpath1;
    leafpath1 = leafpath2;
    leafpath2 = tmp;
end

lca = [];
for i = 1:min(size(leafpath1, 2), size(leafpath2, 2))
    if leafpath1(i) == leafpath2(i)
        lca = [lca leafpath1(i)];
    else
        break
    end
end

node_lca = t.tree;

for i = 1:size(lca, 2)
    node_lca = node_lca.children{lca(i)};
end

node_t1 = t.tree;
for i = 1:size(leafpath1, 2)
    node_t1 = node_t1.children{leafpath1(i)};
end

node_t2 = t.tree;
for i = 1:size(leafpath2, 2)
    node_t2 = node_t2.children{leafpath2(i)};
end

% compute p(1), p(2), ..., p(V) for future use
pV = sum(bsxfun(@times, t.tree.twmatparent, t.tree.pz'));
%pV = pV / sum(pV);
voc_size = size(pV, 2);

% case 1: t2 is the lca of t2 and t1
if length(leafpath2) == length(lca)
    [p_remain, t1_pzgw, p, leafpath1idx, alphadiff] = merge_first(node_t1, node_t2, leafpath1);
    currentnode = p;
    while true
        p = currentnode.parent;
        if strcmp(p.name, node_t2.name)
            merge_last_case1(leafpath1, leafpath1idx, p_remain, t1_pzgw, node_t1, node_t2);
            break;
        else
            [leafpath1idx, p_remain, t1_pzgw] = merge_mid(leafpath1 ,leafpath1idx, p_remain, t1_pzgw, p, alphadiff);
        end                                
        currentnode = currentnode.parent;
    end
% case 2: none of t1 and t2 is their lca
else
    [p_remain_1, t1_pzgw, p_1, leafpath1idx, alphadiff1] = merge_first(node_t1, node_lca, leafpath1);
    [p_remain_2, t2_pzgw, p_2, leafpath2idx, alphadiff2] = merge_first(node_t2, node_lca, leafpath2);
    currentnode_1 = p_1;
    currentnode_2 = p_2;
    while true
        p_1 = currentnode_1.parent;
        if strcmp(p_1.name, node_lca.name)
            break;
        else
            [leafpath1idx, p_remain_1, t1_pzgw] = merge_mid(leafpath1 ,leafpath1idx, p_remain_1, t1_pzgw, p_1, alphadiff1);
        end                                
        currentnode_1 = currentnode_1.parent;
    end
    while true
        p_2 = currentnode_2.parent;
        if strcmp(p_2.name, node_lca.name)
            break;
        else
            [leafpath2idx, p_remain_2, t2_pzgw] = merge_mid(leafpath2 ,leafpath2idx, p_remain_2, t2_pzgw, p_2, alphadiff2);
        end                                
        currentnode_2 = currentnode_2.parent;
    end
    merge_last_case2(node_lca, leafpath1, leafpath1idx, p_remain_1, t1_pzgw, node_t1, alphadiff1, ...
                                                                    leafpath2, leafpath2idx, p_remain_2, t2_pzgw, node_t2, alphadiff2);
end

BFSreorder(t.tree);

end