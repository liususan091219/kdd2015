% MER(t1, t2): Merge two topics t1 and t2 into a new topic t3 under their
% lease common ancester t, e.g., t1 = t121 and t2 = t13 looks like this:
%
%       t1                             t1
%    /  |   \                     /   |    \  
% t11  t12  (t13)     --------> t11  t12   tnew 
%      / \      | \                      /  |    \  \
%  (t121) t122 t131 t132              t1211 t1212 t131 t132
%    / \ 
% t1211 t1212
%
% another example when t1 is the parent of t2:
%
%       (t1)                             t1
%    /  |   \                     /   |    \    \    \
% t11  t12  t13     --------> t11  t12    t13   t1211 t1212
%      / \      | \                /     /   \ 
%  (t121) t122 t131 t132          t122  t131  t132
%    / \ 
% t1211 t1212
%
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% special cases: 1. if node_t1.children = empty, then don't add new nodes
% to t2's children
% 2. if t1 and t2 are siblings, then just merge their children to a new node,
% and put newnode under their parents.

function MER(t, leafpath1, leafpath2)
global vocabulary voc_size pV

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
pV = sum(bsxfun(@times, t.tree.twmatparent, t.tree.alpha1'));
%pV = pV / sum(pV);
voc_size = size(pV, 2);

% if t2 is the lca, remove t1 from its parent
if length(leafpath2) == length(lca)
    % for siblings z of t2: only change their p(z) proportionally, no change for p(w|z)
    if strcmp(node_t1.parent.name, node_t2.name) == 0
        [p_remain, t1_pzgw, p, leafpath1idx] = merge_first(node_t1, leafpath1);
        currentnode = p;
    else
        currentnode = node_t1;
    end
    while true
        p = currentnode.parent;
        if strcmp(p.name, node_t2.name)
            mergelca(p, leafpath1, leafpath1idx, p_remain, t1_pzgw, node_t1, node_t2);
            break;
        else
            [leafpath1idx, p_remain, t1_pzgw] = merge_nonlca(leafpath1 ,leafpath1idx, p_remain, t1_pzgw, p);
        end                                
        currentnode = currentnode.parent;
    end
% if none of t1 or t2 is the lca
else
    if strcmp(node_t1.parent.name, node_lca.name) == 0
        [p_remain_1, t1_pzgw, p_1, leafpath1idx] = merge_first(node_t1, leafpath1);
        currentnode_1 = p_1;
    else
        currentnode_1 = node_t1;
    end
    if strcmp(node_t2.parent.name, node_lca.name) == 0
        [p_remain_2, t2_pzgw, p_2, leafpath2idx] = merge_first(node_t2, leafpath2);
        currentnode_2 = p_2;
    else
        currentnode_2 = node_t2;
    end
    while true
        p_1 = currentnode_1.parent;
        if strcmp(p_1.name, node_lca.name)
            break;
        else
            [leafpath1idx, p_remain_1, t1_pzgw] = merge_nonlca(leafpath1 ,leafpath1idx, p_remain_1, t1_pzgw, p_1);
        end                                
        currentnode_1 = currentnode_1.parent;
    end
    while true
        p_2 = currentnode_2.parent;
        if strcmp(p_2.name, node_lca.name)
            break;
        else
            [leafpath2idx, p_remain_2, t2_pzgw] = merge_nonlca(leafpath2 ,leafpath2idx, p_remain_2, t2_pzgw, p_2);
        end                                
        currentnode_2 = currentnode_2.parent;
    end
    mergelca_twonodes(node_lca, leafpath1, leafpath1idx, p_remain_1, t1_pzgw, node_t1,...
                                                                    leafpath2, leafpath2idx, p_remain_2, t2_pzgw, node_t2);
    % if t1 and t2 are siblings
%     if length(leafpath1) == length(leafpath2) && length(leafpath1) == length(lca) + 1
%         t1index = leafpath1(end);
%         t2index = leafpath2(end);
%         p = node_t1.parent;
%         t1alpha = p.alpha(t1index);
%         t2alpha = p.alpha(t2index);
%         newalpha = t1alpha + t2alpha;
%         if isempty(node_t1.children) == 1 && isempty(node_t2.children) == 0             
%             p.children(t1index) = [];
%             node_t1.parent = [];
%             p.alpha1(t2index) = newalpha;
%             p.alpha1(t1index) = [];
%         elseif isempty(node_t1.children) == 0 && isempty(node_t2.children) == 1           
%             p.children(t2index) = [];
%             node_t2.parent = [];
%             p.alpha1(t1index) = newalpha;
%             p.alpha1(t2index) = [];
%         elseif isempty(node_t1.children) == 1 && isempty(node_t2.children) == 1     
%            p.children(t1index) = [];
%            if t1index < t2index
%                t2index = t2index - 1;
%            end
%            p.children(t2index) = [];
%            p.children{end + 1} = node([], p, [], [], []);
%            p.alpha1(t1index) = [];
%            p.alpha1(t2index) = [];
%            p.alpha1(end + 1) = newalpha;
%         end
%     else
        
%    end
end

end