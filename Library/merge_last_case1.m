% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =======================================================================
% subroutine of MER, compute the change to the lca, when the lca
%   is the same as t2;
% =======================================================================
% merge_last_case1(leafpath1, leafpath1idx, p_remain, t1_pzgw, node_t1, node_t2)
% Parameters: 1. leafpath1: the leafpath of node t1, which is for
%             retrieving the index path of node t1;
%             2. leafpath1idx: which position of leafpath1 we are currently
%             in;
%             3. p_remain: p(z|w) after removing the part of node t1;
%             4. t1_pzgw: p(z|w) of node t1's children;
%             5. node_t1: node t1
%             6. node_t2: node t2
% =======================================================================
% Computation steps:
% 1. compute p(z|w) for z = 1,2,...,k, w=1,2,...,V for current node t2;
% 2. update the remaining p(z|w) for children of node t2: if the child z is
% on the path from node t1 to node t2, p'(z|w) = p(z|w) - prod_{z' on the
% path from t1 to z} p(z'|parent(z'), w); otherwise, don't change p(z|w)
% 3. move node t1's children to be under t2;
% 4. apply Bayesian rule p'(z|w)p(w) = p'(w|z)p'(z) to children of node t2, but only to those z
% corresponding to previously node t1's children, and the z on the path
% from node t1 to node t2. e.g., t1's children are t2 and t3, t1's parent
% is t4 and t4's parent is t5, and we want to merge t1 and t5, then after
% t2 and t3 becomes children of t1, p(z|w) only changes for those z
% corresponding to t4, t2 and t3. compute p'(w|z) following p'(w|z) prop to p'(z|w)p(w); and
% p'(z)=sum_{w}p(z|w)p(w), where p(w) is computed previously in MER;
% =======================================================================
function merge_last_case1(leafpath1, leafpath1idx, p_remain, t1_pzgw, node_t1, node_t2)
global voc_size pV vocabulary
pindex = leafpath1(leafpath1idx); 
leafpath1idx = leafpath1idx - 1;
pzgw = diag(node_t2.pz) * maptoV(node_t2.twmatparent, node_t2.voc_V_map, voc_size); %step 1: compute original pzgw
pzgw = bsxrdivide(pzgw, sum(pzgw)); %step 1: compute original pzgw
p_remain = p_remain .* pzgw(pindex, :);   % step 2: update the remaining p(z|w) of node t2 
if isempty(t1_pzgw) == 0 
    t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(pindex,:));
end 
pzgw(pindex, :) = p_remain; % note: theoretically it should follow sum(pzgw) + sum(t1_pzgw) 
% is a vector consists of only 0 and 1, but this fact does not hold true in reality, because 
% the word filtering in line 26 of decomp, where it is possibly true that p(z_parent|w) is nz
% while p(z_child|w) are all 0's for a word w
changed_index = [pindex];
pz = node_t2.pz;
new_pwgz = maptoV(node_t2.twmatparent, node_t2.voc_V_map, voc_size);
for i = 1:size(node_t1.children, 2)
    node_t1.children{i}.parent = node_t2;
    node_t2.children{end + 1} = node_t1.children{i}; % step 3: move node t1's children to node t2
    % update the original children of node t2, because their parent has
    % changed
    node_t2.children{end}.voc_p_map = arrayfun(@(x)find(node_t2.voc_V_map ==x,1), node_t2.children{end}.voc_V_map);
    changed_index = [changed_index, size(node_t2.children, 2)];
    pzgw = [pzgw; t1_pzgw(i, :)];
    pz = [pz, 0];
    new_pwgz = [new_pwgz; zeros(1, voc_size)];
end   
pzgw_change = pzgw(changed_index, :);
pwgz_change = bsxfun(@times, pzgw_change, pV); % step 4: apply Bayesian rule
pz_change = sum(pwgz_change, 2);     % p(z) = sum_w p(z|w)p(w) 
pzsum = node_t2.pz(pindex); 
pz_change = bsxrdivide(pz_change, sum(pz_change)) * pzsum;%normalize p(z) such that p'(z_1) + sum_{z' is t2's children} p(z') = p(z_1), where
% z_1 is t2's child on the path from t1 to t2
pwgz_change = bsxrdivide(pwgz_change, sum(pwgz_change, 2));
pz(changed_index) = pz_change;
new_pwgz(changed_index, :) = pwgz_change;
node_t2.pz = pz;
node_t2.twmatparent = new_pwgz(:, node_t2.voc_V_map);
% re-compute the topic for each changed children of t2
for i = 1:size(changed_index, 2)
    pwgz_changei = pwgz_change(i, :);
    node_t2.children{changed_index(i)}.twmati = pwgz_changei(node_t2.children{changed_index(i)}.voc_V_map);
    [~, ind] = sort(node_t2.children{changed_index(i)}.twmati, 'descend');
    node_t2.children{changed_index(i)}.topici = vocabulary(node_t2.children{changed_index(i)}.voc_V_map(ind(1, 1:10)));
end
% handle the special case where t1 is the child of t2
if strcmp(node_t1.parent.name, node_t2.name) == 1
    node_t2.pz(pindex) = [];
    node_t2.pz = bsxrdivide(node_t2.pz, sum(node_t2.pz));
    node_t2.children(pindex) = [];
    node_t2.twmatparent(pindex,:) = [];
end
% rename all node_t2's children in the end
BFSname(node_t2, node_t2.name);
end