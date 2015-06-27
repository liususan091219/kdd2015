% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =======================================================================
% subroutine of MER, compute the change to the parent of t1 or t2 (if
%   it is not lca);
% =======================================================================
% merge_first(node_t1, node_lca, leafpath1)
% Parameters: 1. node_t1: the non lca node(s) of t1 and t2;
%             2. node_lca: the lca node of t1 and t2, which is either t1/t2
%             (if one of them is the lca) or none of t1/t2;
%             3. leafpath1: the leafpath of node t1, which is for
%             retrieving the index path of node t1
% Outputs: 1. p_remain: remaining p(z|w) after removing the part of node t1
%          2. t1_pzgw: p(z|w) of node t1's children;
%          3. p: if node t1's parent is not lca, p is set to node t1's
%          parent; if otherwise, p is set to node t1;
%          4. leafpath1idx: which position of leafpath1 we are currently in
%          5. alphadiff: node t1's alpha0, which is saved to be subtracted by
%          its grand parents's alpha0's
% =======================================================================
% Computation steps:
% 1. compute p(z|w) for z = 1,2,...,k, w=1,2,...,V for node t1's parent;
% 2. remove node t1 from its parent;
% 3. p'(z|w) = p(z|w) / (1 - p(z_{t1}|w)) for z neq t1;
% 4. apply Bayesian rule p'(z|w)p(w) = p'(w|z)p'(z), for each z=1,2,...,k,
% compute p'(w|z) following p'(w|z) prop to p'(z|w)p(w); and
% p'(z)=sum_{w}p(z|w)p(w), where p(w) is computed previously in MER;
% =======================================================================
function [p_remain, t1_pzgw, p, leafpath1idx, alphadiff] = merge_first(node_t1, node_lca, leafpath1)
global voc_size pV vocabulary
p = node_t1.parent;
t1_pzgw = [];
if isempty(node_t1.children) == 0
    t1_pzgw = diag(node_t1.pz) * maptoV(node_t1.twmatparent, node_t1.voc_V_map, voc_size);
    t1_pzgw = bsxrdivide(t1_pzgw, sum(t1_pzgw, 1));
end
if strcmp(node_t1.parent.name, node_lca.name) == 1
    p_remain = zeros(1, voc_size); 
    p = node_t1;
    leafpath1idx = length(leafpath1);
    return;
end
pzgw = diag(p.pz) * maptoV(p.twmatparent, p.voc_V_map, voc_size); % step 1: compute the original p(z|w)
pzgw = bsxrdivide(pzgw, sum(pzgw, 1));% step 1: compute the original p(z|w)
leafpath1idx = length(leafpath1);
t1index = leafpath1(leafpath1idx);
if isempty(t1_pzgw) == 0
    t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(t1index, :));
end
leafpath1idx = leafpath1idx - 1;
pzgw(t1index, :) = [];
pzgw = bsxrdivide(pzgw, sum(pzgw, 1));% step 3: compute p'(z|w)
pwgz = bsxfun(@times, pzgw, pV); % step 4: apply baysian rule and compute p'(w|z)
pz = sum(pwgz, 2); % step 4: compute p'(z)
pz = bsxrdivide(pz , sum(pz));
p.pz = pz;
pwgz = bsxrdivide(pwgz, sum(pwgz, 2));
p.twmatparent = pwgz(:, p.voc_V_map);
alphadiff = p.children{t1index}.alpha0;
p.alpha0 = p.alpha0 - alphadiff;
p.children(t1index) = [];
p_remain = sum(pzgw, 1);

for i = 1:size(p.children, 2)
    p.children{i}.twmati = pwgz(i,p.children{i}.voc_V_map);
    [~, ind] = sort(p.children{i}.twmati, 'descend');
    p.children{i}.topici = vocabulary(p.children{i}.voc_V_map(ind(1, 1:10)));
end

end