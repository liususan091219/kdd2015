function [p_remain, t1_pzgw, p, leafpath1idx] = merge_first(node_t1, leafpath1)
global voc_size
p = node_t1.parent;
t1_pzgw = [];
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
end