function merge_last_case2(node_lca, leafpath1, leafpath1idx, p_remain_1, t1_pzgw, node_t1, alphadiff1, ...
                                                                    leafpath2, leafpath2idx, p_remain_2, t2_pzgw, node_t2, alphadiff2)
global voc_size pV vocabulary
pindex_1 = leafpath1(leafpath1idx); 
pindex_2 = leafpath2(leafpath2idx);
pzgw = diag(node_lca.pz) * maptoV(node_lca.twmatparent, node_lca.voc_V_map, voc_size); %original pzgw
pzgw = bsxrdivide(pzgw, sum(pzgw));
p_remain_1 = p_remain_1 .* pzgw(pindex_1, :); 
p_remain_2 = p_remain_2 .* pzgw(pindex_2, :);
if isempty(t1_pzgw) == 0
    t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(pindex_1,:));
end 
if isempty(t2_pzgw) == 0
    t2_pzgw = bsxfun(@times, t2_pzgw, pzgw(pindex_2,:));
end
pzgw(pindex_1, :) = p_remain_1;
pzgw(pindex_2, :) = p_remain_2;
changed_index = [pindex_1 pindex_2];
alpha1 = node_lca.pz;
new_pwgz = maptoV(node_lca.twmatparent, node_lca.voc_V_map, voc_size);
newnode = node([], node_lca, [], [], []);
newnode.children = cell(1, size(node_t1.children, 2) + size(node_t2.children, 2));
changed_index = [changed_index, size(node_lca.children, 2) + 1];
newnode_pzgw = zeros(1, voc_size);
if isempty(t1_pzgw) == 0
    newnode_pzgw = newnode_pzgw + sum(t1_pzgw);
end
if isempty(t2_pzgw) == 0
    newnode_pzgw = newnode_pzgw + sum(t2_pzgw);
end
pzgw = [pzgw; newnode_pzgw];
alpha1 = [alpha1, 0];
new_pwgz = [new_pwgz; zeros(1, voc_size)];
for i = 1:size(node_t1.children, 2)    
    newnode.children{i} = node_t1.children{i};
    node_t1.children{i}.parent = newnode;
end  
for i =  1:size(node_t2.children, 2)
    newnode.children{size(node_t1.children, 2) + i} = node_t2.children{i};
    node_t2.children{i}.parent = newnode;
end
node_lca.children{end+1} = newnode;
pzgw_change = pzgw(changed_index, :); 
pwgz_change = bsxfun(@times, pzgw_change, pV);
alpha1_change = sum(pwgz_change, 2);      
alphasum = node_lca.pz(pindex_1) + node_lca.pz(pindex_2); 
alpha1_change = bsxrdivide(alpha1_change, sum(alpha1_change)) * alphasum;
pwgz_change = bsxrdivide(pwgz_change, sum(pwgz_change, 2));
alpha1(changed_index) = alpha1_change;
new_pwgz(changed_index, :) = pwgz_change;
node_lca.pz = alpha1;
node_lca.twmatparent = new_pwgz(:, node_lca.voc_V_map); % this is wrong, need build map
% compute voc_V_map of newnode
pwgz_changei = pwgz_change(3, :);
newnode.voc_V_map = find(pwgz_changei);
newnode.voc_p_map = arrayfun(@(x)find(node_lca.voc_V_map ==x,1), newnode.voc_V_map);
newnode.alpha0 = alphadiff1 + alphadiff2;
for i = 1:3
    pwgz_changei = pwgz_change(i, :);
    node_lca.children{changed_index(i)}.twmati = pwgz_changei(node_lca.children{changed_index(i)}.voc_V_map);
    if isempty(node_lca.children{changed_index(i)}.twmati) == 0
        [~, ind] = sort(node_lca.children{changed_index(i)}.twmati, 'descend');
        node_lca.children{changed_index(i)}.topici = vocabulary(node_lca.children{changed_index(i)}.voc_V_map(ind(1, 1:10)));
    end
end
if strcmp(node_t1.parent.name, node_lca.name) == 1
    node_lca.pz(pindex_1) = [];   
    node_lca.children(pindex_1) = [];
    node_lca.twmatparent(pindex_1, :) = [];
    if strcmp(node_t2.parent.name, node_lca.name) == 1 && pindex_1 < pindex_2
        pindex_2 = pindex_2 - 1;
    end
end
if strcmp(node_t2.parent.name, node_lca.name) == 1
    node_lca.pz(pindex_2) = [];
    node_lca.children(pindex_2) = [];
    node_lca.twmatparent(pindex_2, :) = [];
end
node_lca.pz = bsxrdivide(node_lca.pz, sum(node_lca.pz));
pzgw = [];
if isempty(t1_pzgw) == 0
    pzgw = [pzgw; t1_pzgw];
end
if isempty(t2_pzgw) == 0
    pzgw = [pzgw; t2_pzgw];
end
if isempty(pzgw) == 1
    node_lca.children(end) = [];
    node_lca.pz(end) = [];
    node_lca.pz = bsxrdivide(node_lca.pz, sum(node_lca.pz));
    node_lca.twmatparent(end, :) = [];
    BFSname(node_lca, node_lca.name);
    return;
end
pzgw = bsxrdivide(pzgw, sum(pzgw));
pwgz = bsxfun(@times, pzgw, pV);
alpha1 = sum(pwgz, 2);
alpha1 = bsxrdivide(alpha1, sum(alpha1));
newnode.pz = alpha1;
pwgz = bsxrdivide(pwgz, sum(pwgz, 2));
newnode.twmatparent = pwgz(:, newnode.voc_V_map);

for i = 1:size(newnode.children, 2)
    pwgzi = pwgz(i, :);
    newnode.children{i}.twmati = pwgzi(newnode.children{i}.voc_V_map);
    newnode.children{i}.voc_p_map = arrayfun(@(x)find(newnode.voc_V_map ==x,1), newnode.children{i}.voc_V_map);
    [~, ind] = sort(newnode.children{i}.twmati, 'descend');
    newnode.children{i}.topici = vocabulary(newnode.children{i}.voc_V_map(ind(1, 1:10)));
end

BFSname(node_lca, node_lca.name);
end