function merge_last_case1(leafpath1, leafpath1idx, p_remain, t1_pzgw, node_t1, node_t2)
global voc_size pV vocabulary
pindex = leafpath1(leafpath1idx); 
leafpath1idx = leafpath1idx - 1;
pzgw = diag(node_t2.pz) * maptoV(node_t2.twmatparent, node_t2.voc_V_map, voc_size); %original pzgw
pzgw = bsxrdivide(pzgw, sum(pzgw));
p_remain = p_remain .* pzgw(pindex, :);            
if isempty(t1_pzgw) == 0
    t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(pindex,:));
end 
pzgw(pindex, :) = p_remain; % note: theoretically it should follow sum(pzgw) + sum(t1_pzgw) 
% is a vector consists of only 0 and 1, but this fact does not hold true in reality, because 
% the word filtering in line 26 of decomp, where it is possibly true that p(z_parent|w) is nz
% while p(z_child|w) are all 0's for a word w
changed_index = [pindex];
alpha1 = node_t2.pz;
new_pwgz = maptoV(node_t2.twmatparent, node_t2.voc_V_map, voc_size);
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
alphasum = node_t2.pz(pindex); 
alpha1_change = bsxrdivide(alpha1_change, sum(alpha1_change)) * alphasum;
pwgz_change = bsxrdivide(pwgz_change, sum(pwgz_change, 2));
alpha1(changed_index) = alpha1_change;
new_pwgz(changed_index, :) = pwgz_change;
node_t2.pz = alpha1;
node_t2.twmatparent = new_pwgz(:, node_t2.voc_V_map); % this is wrong, need build map
for i = 1:size(changed_index, 2)
    pwgz_changei = pwgz_change(i, :);
    node_t2.children{changed_index(i)}.twmati = pwgz_changei(node_t2.children{changed_index(i)}.voc_V_map);
    [~, ind] = sort(node_t2.children{changed_index(i)}.twmati, 'descend');
    node_t2.children{changed_index(i)}.topici = vocabulary(node_t2.children{changed_index(i)}.voc_V_map(ind(1, 1:10)));
end
if strcmp(node_t1.parent.name, node_t2.name) == 1
    node_t2.pz(pindex) = [];
    node_t2.pz = bsxrdivide(node_t2.pz, sum(node_t2.pz));
    node_t2.children(pindex) = [];
    node_t2.twmatparent(pindex,:) = [];
end
% rename all node_t2's children in the end
BFSname(node_t2, node_t2.name);
end