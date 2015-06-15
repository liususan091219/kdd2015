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

% compute p(1), p(2), ..., p(V) for future use
pV = sum(bsxfun(@times, t.tree.twmatparent, t.tree.alpha1'));
%pV = pV / sum(pV);
voc_size = size(pV, 2);

% if t2 is the lca, remove t1 from its parent
t1_pzgw = [];
if length(leafpath2) == length(lca)
    % for siblings z of t2: only change their p(z) proportionally, no change for p(w|z)
    p = node_t1.parent;
    if isempty(node_t1.children) == 0
        t1_pzgw = diag(node_t1.alpha1) * maptoV(node_t1.twmatparent, node_t1.voc_V_map, voc_size);
        t1_pzgw = bsxrdivide(t1_pzgw, sum(t1_pzgw));
    end
    pzgw = diag(p.alpha1) * maptoV(p.twmatparent, p.voc_V_map, voc_size);
    pzgw = bsxrdivide(pzgw, sum(pzgw));
    leafpath1idx = length(leafpath1);
    t1index = leafpath1(leafpath1idx);
    if isempty(t1_pzgw) == 0
        t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(t1index, :));
    end
    leafpath1idx = leafpath1idx - 1;
    p.alpha1(t1index) = [];
    p.alpha1 = p.alpha1 / sum(p.alpha1);
    fprintf('changing node t2s siblings p(z)s...\n');
    pzgw(t1index, :) = [];
    % remove t2 from its parent
    p.children(t1index) = [];
    p_remain = sum(pzgw, 1);
    currentnode = p;
    while isempty(currentnode.parent)== 0
        p = currentnode.parent;
        pindex = leafpath1(leafpath1idx); 
        leafpath1idx = leafpath1idx - 1;
        pzgw = diag(p.alpha1) * maptoV(p.twmatparent, p.voc_V_map, voc_size); %original pzgw
        pzgw = bsxrdivide(pzgw, sum(pzgw));
        p_remain = p_remain .* pzgw(pindex, :);            
        if isempty(t1_pzgw) == 0
            t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(pindex,:));
        end 
        pzgw(pindex, :) = p_remain;
        if strcmp(p.name, node_t2.name)
            changed_index = [pindex];
            alpha1 = p.alpha1;
            new_pwgz = maptoV(p.twmatparent, p.voc_V_map, voc_size);
            for i = 1:size(node_t1.children, 2)
                node_t1.children{i}.parent = node_t2;
                node_t2.children{end + 1} = node_t1.children{i};
                changed_index = [changed_index, size(node_t2.children, 2)];
                pzgw = [pzgw; t1_pzgw(i, :)];
                alpha1 = [alpha1, 0];
                new_pwgz = [new_pwgz; zeros(1, voc_size)];
            end   
            pzgw_change = pzgw(changed_index, :);
            pwgz_change = bsxfun(@times, pzgw_change, pV);
            alpha1_change = sum(pwgz_change, 2);      
            alphasum = node_t2.alpha1(pindex); 
            alpha1_change = alpha1_change / sum(alpha1_change) * alphasum;
            pwgz_change = bsxrdivide(pwgz_change, sum(pwgz_change, 2));
            alpha1(changed_index) = alpha1_change;
            new_pwgz(changed_index, :) = pwgz_change;
            node_t2.alpha1 = alpha1;
            node_t2.twmatparent = new_pwgz(:, node_t2.voc_V_map); % this is wrong, need build map
            for i = 1:size(changed_index, 2)
                pwgz_changei = pwgz_change(i, :);
                node_t2.children{changed_index(i)}.twmati = pwgz_changei(node_t2.children{changed_index(i)}.voc_V_map);
                [~, ind] = sort(node_t2.children{changed_index(i)}.twmati, 'descend');
                node_t2.children{changed_index(i)}.topici = vocabulary(node_t2.children{changed_index(i)}.voc_V_map(ind(1, 1:10)));
            end
            break;
        end                         
        p_remain = sum(pzgw, 1);
        pzgw = bsxrdivide(pzgw, sum(pzgw));
        pwgz = bsxfun(@times, pzgw, pV);
        alpha1 = sum(pwgz, 2);
        alpha1 = alpha1 / sum(alpha1);
        pwgz = bsxrdivide(pwgz, sum(pwgz, 2));
        p.alpha1 = alpha1;
        p.twmatparent = pwgz(:, p.voc_V_map);
        for i = 1:size(p.children, 2)
            p.children{i}.twmati = pwgz(i,p.children{i}.voc_V_map);
            [~, ind] = sort(p.children{i}.twmati, 'descend');
            p.children{i}.topici = vocabulary(p.children{i}.voc_V_map(ind(1, 1:10)));
        end
        currentnode = currentnode.parent;
    end
% if none of t1 or t2 is the lca
else
    % if t1 and t2 are siblings
    if length(leafpath1) == length(leafpath2) && length(leafpath1) == length(lca) + 1
        t1index = leafpath1(end);
        t2index = leafpath2(end);
        p = node_t1.parent;
        t1alpha = p.alpha(t1index);
        t2alpha = p.alpha(t2index);
        newalpha = t1alpha + t2alpha;
        if isempty(node_t1.children) == 1 && isempty(node_t2.children) == 0             
            p.children(t1index) = [];
            node_t1.parent = [];
            p.alpha1(t2index) = newalpha;
            p.alpha1(t1index) = [];
        elseif isempty(node_t1.children) == 0 && isempty(node_t2.children) == 1           
            p.children(t2index) = [];
            node_t2.parent = [];
            p.alpha1(t1index) = newalpha;
            p.alpha1(t2index) = [];
        elseif isempty(node_t1.children) == 1 && isempty(node_t2.children) == 1     
           p.children(t1index) = [];
           if t1index < t2index
               t2index = t2index - 1;
           end
           p.children(t2index) = [];
           p.children{end + 1} = node([], p, [], [], []);
           p.alpha1(t1index) = [];
           p.alpha1(t2index) = [];
           p.alpha1(end + 1) = newalpha;
        end
    end
end

end