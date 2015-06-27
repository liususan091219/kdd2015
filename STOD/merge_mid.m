% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =======================================================================
% subroutine of MER, compute the change to the ancestor and non-lca of
%   t1 or t2;
% =======================================================================
% merge_mid(leafpath1, leafpath1idx, p_remain, t1_pzgw, p, alpha_diff)
% Parameters: 1. leafpath1: the leafpath of node t1, which is for
%             retrieving the index path of node t1;
%             2. leafpath1idx: which position of leafpath1 we are currently
%             in;
%             3. p_remain: p(z|w) after removing the part of node t1;
%             4. t1_pzgw: p(z|w) of node t1's children;
%             5. alpha_diff: node t1's alpha0, which is saved to be subtracted by
%          its grand parents's alpha0's
% Outputs: 1. leafpath1idx: updated leafpath1idx;
%          2. p_remain: updated p_remain;
%          3. t1_pzgw: updated t1_pzgw;
% =======================================================================
% Computation steps:
% 1. compute p(z|w) for z = 1,2,...,k, w=1,2,...,V for current node p;
% 2. update p_remain, which is the remaining p(z|w) for children of current
%  node p: if the child z is on the path from node t1 to p, p'(z|p,w) =
%  p(z|p,w)- prod_{z' on the original path from t1 to p} p(z'|parent(z'), w);
%  otherwise, don't change p(z|w).  e.g., if node t1's parent is t3 and
%  grandparent is t4, then after merging p'(z_{t3}|z_{t4},w) =
% p(z_{t3}|z_{t4}, w) - p(z_{t1}|z_{t3}, w)p(z_{t3}|z_{t4},w).
% 3. normalize p'(z|w) for each w, such that all z's sum up to 1.
% 4. apply Bayesian rule p'(z|w)p(w) = p'(w|z)p'(z) to children of p, 
% compute p'(w|z) following p'(w|z) prop to p'(z|w)p(w); and
% p'(z)=sum_{w}p(z|w)p(w), where p(w) is computed previously in MER;
% =======================================================================
function [leafpath1idx, p_remain, t1_pzgw] = merge_mid(leafpath1 ,leafpath1idx, p_remain, t1_pzgw, p, alpha_diff)
global vocabulary voc_size pV
pindex = leafpath1(leafpath1idx); 
leafpath1idx = leafpath1idx - 1;
pzgw = diag(p.pz) * maptoV(p.twmatparent, p.voc_V_map, voc_size); % step 1: compute the original p(z|w)
pzgw = bsxrdivide(pzgw, sum(pzgw)); % step 1: compute the original p(z|w)
p_remain = p_remain .* pzgw(pindex, :); % step 2: update p_remain           
if isempty(t1_pzgw) == 0
    t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(pindex,:));
end 
pzgw(pindex, :) = p_remain;% note: theoretically it should follow sum(pzgw) + sum(t1_pzgw) 
% is a vector consists of only 0 and 1, but this fact does not hold true in reality, because 
% the word filtering in line 26 of decomp, where it is possibly true that p(z_parent|w) is nz
% while p(z_child|w) are all 0's for a word w
p_remain = sum(pzgw, 1);
pzgw = bsxrdivide(pzgw, sum(pzgw)); % step 3: normalie p(z|w)
pwgz = bsxfun(@times, pzgw, pV);% step 4: compute p(w|z)
pz = sum(pwgz, 2);
pz = bsxrdivide(pz , sum(pz));% p(z) = sum_w p(z|w)p(w) 
pwgz = bsxrdivide(pwgz, sum(pwgz, 2)); 
p.pz = pz;
p.alpha0 = p.alpha0 - alpha_diff; % update alpha0 of p
p.twmatparent = pwgz(:, p.voc_V_map);
% re-compute p's children's topics
for i = 1:size(p.children, 2)
    p.children{i}.twmati = pwgz(i,p.children{i}.voc_V_map);
    [~, ind] = sort(p.children{i}.twmati, 'descend');
    p.children{i}.topici = vocabulary(p.children{i}.voc_V_map(ind(1, 1:10)));
end
end