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
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.

function MER(t, leafpath1, leafpath2)
global vocabulary

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

if isequal(lca, leafpath1) == 0  
   for i = 1:size(node_t1.children, 2)
       node_lca.children{1, size(node_lca.children, 2) + 1} = node_t1.children{1, i};
       node_t1.children{1, i}.parent = node_lca;             
   end
   node1childidx = leafpath1(end);
   node_t1.parent.children(node1childidx) = [];
   if size(leafpath1, 2) == size(leafpath2, 2)
       % if leafpath1 and leafpath2 are siblings
       if isequal(leafpath1(1:end-1), leafpath2(1:end-1)) == 1 && leafpath1(end) < leafpath2(end)
           leafpath2(end) = leafpath2(end) - 1;
       end
   end
end

if isequal(lca, leafpath2) == 0  
    for i = 1:size(node_t2.children, 2)
        node_lca.children{1, size(node_lca.children, 2) + 1} = node_t2.children{1, i};
        node_t2.children{1, i}.parent = node_lca;        
    end
    node2childidx = leafpath2(end);
    node_t2.parent.children(node2childidx) = [];
end

end