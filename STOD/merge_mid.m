function [leafpath1idx, p_remain, t1_pzgw] = merge_mid(leafpath1 ,leafpath1idx, p_remain, t1_pzgw, p)
global vocabulary voc_size pV
pindex = leafpath1(leafpath1idx); 
leafpath1idx = leafpath1idx - 1;
pzgw = diag(p.alpha1) * maptoV(p.twmatparent, p.voc_V_map, voc_size); %original pzgw
pzgw = bsxrdivide(pzgw, sum(pzgw));
p_remain = p_remain .* pzgw(pindex, :);            
if isempty(t1_pzgw) == 0
    t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(pindex,:));
end 
pzgw(pindex, :) = p_remain;% note: theoretically it should follow sum(pzgw) + sum(t1_pzgw) 
% is a vector consists of only 0 and 1, but this fact does not hold true in reality, because 
% the word filtering in line 26 of decomp, where it is possibly true that p(z_parent|w) is nz
% while p(z_child|w) are all 0's for a word w
p_remain = sum(pzgw, 1);
pzgw = bsxrdivide(pzgw, sum(pzgw));
pwgz = bsxfun(@times, pzgw, pV);
alpha1 = sum(pwgz, 2);
alpha1 = bsxrdivide(alpha1 , sum(alpha1));
pwgz = bsxrdivide(pwgz, sum(pwgz, 2));
p.alpha1 = alpha1;
p.twmatparent = pwgz(:, p.voc_V_map);
for i = 1:size(p.children, 2)
    p.children{i}.twmati = pwgz(i,p.children{i}.voc_V_map);
    [~, ind] = sort(p.children{i}.twmati, 'descend');
    p.children{i}.topici = vocabulary(p.children{i}.voc_V_map(ind(1, 1:10)));
end
end