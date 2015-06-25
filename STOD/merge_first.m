function [p_remain, t1_pzgw, p, leafpath1idx, alphadiff] = merge_first(node_t1, node_lca, leafpath1)
global voc_size
p = node_t1.parent;
t1_pzgw = [];
if isempty(node_t1.children) == 0
    t1_pzgw = diag(node_t1.pz) * maptoV(node_t1.twmatparent, node_t1.voc_V_map, voc_size);
    t1_pzgw = bsxrdivide(t1_pzgw, sum(t1_pzgw));
end
if strcmp(node_t1.parent.name, node_lca.name) == 1
    p_remain = zeros(1, voc_size); 
    p = node_t1;
    leafpath1idx = length(leafpath1);
    return;
end
pzgw = diag(p.pz) * maptoV(p.twmatparent, p.voc_V_map, voc_size);
pzgw = bsxrdivide(pzgw, sum(pzgw));
leafpath1idx = length(leafpath1);
t1index = leafpath1(leafpath1idx);
if isempty(t1_pzgw) == 0
    t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(t1index, :));
end
leafpath1idx = leafpath1idx - 1;
p.pz(t1index) = [];
p.pz = bsxrdivide(p.pz, sum(p.pz));
fprintf('changing node t2s siblings p(z)s...\n');
pzgw(t1index, :) = [];
% remove t2 from its parent
p.twmatparent(t1index, :) = []; % fix bug: change dimension of twparent of t1 or t2 which is not lca
alphadiff = p.children{t1index}.alpha0;
p.alpha0 = p.alpha0 - alphadiff;
p.children(t1index) = [];
p_remain = sum(pzgw, 1);
end