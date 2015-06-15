function [leafpath1idx, p_remain, t1_pzgw] = mergelca(p, leafpath1, leafpath1idx, p_remain, t1_pzgw, node_t1, node_t2)
global voc_size pV vocabulary
pindex = leafpath1(leafpath1idx); 
leafpath1idx = leafpath1idx - 1;
pzgw = diag(p.alpha1) * maptoV(p.twmatparent, p.voc_V_map, voc_size); %original pzgw
pzgw = bsxrdivide(pzgw, sum(pzgw));
p_remain = p_remain .* pzgw(pindex, :);            
if isempty(t1_pzgw) == 0
    t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(pindex,:));
end 
pzgw(pindex, :) = p_remain;
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
end