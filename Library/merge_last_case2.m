% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =======================================================================
% subroutine of MER, compute the change to the lca, when the lca is
%   neither t1 nor t2;
% =======================================================================
% merge_last_case2(node_lca, leafpath1, leafpath1idx, p_remain_1, t1_pzgw, node_t1, alphadiff1,
% leafpath2, leafpath2idx, p_remain_2, t2_pzgw, node_t2, alphadiff2)
% Parameters: 1. node_lca: the lca of node t1 and t2;
%             2. leafpath1: the leafpath of node t1, which is for
%             retrieving the index path of node t1;
%             3. leafpath1idx: which position of leafpath1 we are currently
%             in;
%             4. p_remain_1: p(z|w) after removing the part of node t1;
%             5. t1_pzgw: p(z|w) of node t1's children;
%             6. node_t1: node t1
%             7. alphadiff1: node t1's alpha0
%             8. leafpath2: the leafpath of node t2, which is for
%             retrieving the index path of node t2;
%             9. leafpath2idx: which position of leafpath2 we are currently
%             in;
%             10. p_remain_2: p(z|w) after removing the part of node t2;
%             11. t2_pzgw: p(z|w) of node t2's children;
%             12. node_t2: node t2
%             13. alphadiff1: node t2's alpha0
% =======================================================================
% Computation steps:
% 1. compute p(z|w) for z = 1,2,...,k, w=1,2,...,V for current node t2;
% 2. update the remaining p(z|w) for children of lca: if the child z is
% on the path from node t1(or t2) to their lca, then p'(z|w) = p(z|w) -
% prod_{z' on the path from t1/t2 to z} p(z'|parent(z'), w); otherwise,
% don't change p(z|w)
% 3. create a new node and add it to the children of lca; move node t1 and
% t2's children to be under the new node;
% 4. apply Bayesian rule p'(z|w)p(w) = p'(w|z)p'(z) to children of node
% lca, but only to 3 nodes: z corresponding to the new node, and the z on the path
% from node t1/t2 to lca. 
% 5. update the p(z|w) for z=1,2,...,k, w=1,2,...,V. This is done by two
% steps: first, p(z|w)= prod_{z' on the original path from z to lca} p(z'|parent(z'), w)
% second, normalize all p(z|w) such that they sum up to 1.
% 6. apply Bayesian rule  p'(z|w)p(w) = p'(w|z)p'(z) to children of new
% nodes, compute p'(w|z) following p'(w|z) prop to p'(z|w)p(w); and
% p'(z)=sum_{w}p(z|w)p(w), where p(w) is computed previously in MER;
% =======================================================================
function merge_last_case2(node_lca, leafpath1, leafpath1idx, p_remain_1, t1_pzgw, node_t1, alphadiff1, ...
                                                                    leafpath2, leafpath2idx, p_remain_2, t2_pzgw, node_t2, alphadiff2)
global voc_size pV vocabulary
pindex_1 = leafpath1(leafpath1idx); 
pindex_2 = leafpath2(leafpath2idx);
pzgw = diag(node_lca.pz) * maptoV(node_lca.twmatparent, node_lca.voc_V_map, voc_size);% step 1: compute the original p(z|w)
pzgw = bsxrdivide(pzgw, sum(pzgw));% step 1: compute the original p(z|w)
p_remain_1 = p_remain_1 .* pzgw(pindex_1, :); % step 2: update the remaining p(z|w) of node t1 
p_remain_2 = p_remain_2 .* pzgw(pindex_2, :); % step 2: update the remaining p(z|w) of node t2 
if isempty(t1_pzgw) == 0
    t1_pzgw = bsxfun(@times, t1_pzgw, pzgw(pindex_1,:));
end 
if isempty(t2_pzgw) == 0
    t2_pzgw = bsxfun(@times, t2_pzgw, pzgw(pindex_2,:));
end
pzgw(pindex_1, :) = p_remain_1;
pzgw(pindex_2, :) = p_remain_2;
changed_index = [pindex_1 pindex_2];
pz = node_lca.pz;
new_pwgz = maptoV(node_lca.twmatparent, node_lca.voc_V_map, voc_size);
newnode = node([], node_lca, [], [], []);
newnode.children = cell(1, size(node_t1.children, 2) + size(node_t2.children, 2));
changed_index = [changed_index, size(node_lca.children, 2) + 1];
newnode_pzgw = zeros(1, voc_size); %newnode_pzgw is the p(z|w) of new node, which is the sum of p(z|w) of t1's children and t2's children
if isempty(t1_pzgw) == 0
    newnode_pzgw = newnode_pzgw + sum(t1_pzgw);
end
if isempty(t2_pzgw) == 0
    newnode_pzgw = newnode_pzgw + sum(t2_pzgw);
end
pzgw = [pzgw; newnode_pzgw];
pz = [pz, 0];
new_pwgz = [new_pwgz; zeros(1, voc_size)];
for i = 1:size(node_t1.children, 2)    % step 3: move t1's children to be under new node
    newnode.children{i} = node_t1.children{i};
    node_t1.children{i}.parent = newnode;
end  
for i =  1:size(node_t2.children, 2)     % step 3: move t2's children to be under new node
    newnode.children{size(node_t1.children, 2) + i} = node_t2.children{i};
    node_t2.children{i}.parent = newnode;
end
node_lca.children{end+1} = newnode; % add new node to lca's children list
pzgw_change = pzgw(changed_index, :); 
pwgz_change = bsxfun(@times, pzgw_change, pV); % step 4: apply bayes rule to children of node lca
pz_change = sum(pwgz_change, 2);      
pzsum = node_lca.pz(pindex_1) + node_lca.pz(pindex_2); 
pz_change = bsxrdivide(pz_change, sum(pz_change)) * pzsum; % normalize p(z) such that sum of the original 
% branch of t1 and t2 stay unchanged, i.e., p(z_1) + p(z_2) = p'(z_1) +
% p'(z_2) + p(new node), where z_1 and z_2 are lca's children on the path
% from t1 to lca and t2 to lca, respectively
pwgz_change = bsxrdivide(pwgz_change, sum(pwgz_change, 2));
pz(changed_index) = pz_change;
new_pwgz(changed_index, :) = pwgz_change;
node_lca.pz = pz;
node_lca.twmatparent = new_pwgz(:, node_lca.voc_V_map); 
% compute the voc_V_map and voc_p_map of newnode
pwgz_changei = pwgz_change(3, :);
newnode.voc_V_map = find(pwgz_changei);
newnode.voc_p_map = arrayfun(@(x)find(node_lca.voc_V_map ==x,1), newnode.voc_V_map);
newnode.alpha0 = alphadiff1 + alphadiff2; % compute new node's alpha0, which is equal to the sum of t1 and t2's alpha0
% (re-)compute topic of each of lca's children that are changed
for i = 1:3
    pwgz_changei = pwgz_change(i, :);
    node_lca.children{changed_index(i)}.twmati = pwgz_changei(node_lca.children{changed_index(i)}.voc_V_map);
    if isempty(node_lca.children{changed_index(i)}.twmati) == 0
        [~, ind] = sort(node_lca.children{changed_index(i)}.twmati, 'descend');
        node_lca.children{changed_index(i)}.topici = vocabulary(node_lca.children{changed_index(i)}.voc_V_map(ind(1, 1:10)));
    end
end
% handle the special case when t1's parent is their lca, when t1's branch
% is therefore to be removed
if strcmp(node_t1.parent.name, node_lca.name) == 1
    node_lca.pz(pindex_1) = [];   
    node_lca.children(pindex_1) = [];
    node_lca.twmatparent(pindex_1, :) = [];
    if strcmp(node_t2.parent.name, node_lca.name) == 1 && pindex_1 < pindex_2
        pindex_2 = pindex_2 - 1;
    end
end
% handle the special case when t2's parent is their lca, when t2's branch
% is therefore to be removed
if strcmp(node_t2.parent.name, node_lca.name) == 1
    node_lca.pz(pindex_2) = [];
    node_lca.children(pindex_2) = [];
    node_lca.twmatparent(pindex_2, :) = [];
end
node_lca.pz = bsxrdivide(node_lca.pz, sum(node_lca.pz));
pzgw = [];  % pzgw is the p(z|w) of new node
if isempty(t1_pzgw) == 0
    pzgw = [pzgw; t1_pzgw];
end
if isempty(t2_pzgw) == 0
    pzgw = [pzgw; t2_pzgw];
end
% handle special case where t1 and t2 both doesn't have children, when
% there is no new nodes.
if isempty(pzgw) == 1
    node_lca.children(end) = [];
    node_lca.pz(end) = [];
    node_lca.pz = bsxrdivide(node_lca.pz, sum(node_lca.pz));
    node_lca.twmatparent(end, :) = [];
    BFSname(node_lca, node_lca.name);
    return;
end
pzgw = bsxrdivide(pzgw, sum(pzgw)); % step 5: compute p(z|w) for children of new node
pwgz = bsxfun(@times, pzgw, pV); % step 6: apply Bayesian rule to get p(w|z)
pz = sum(pwgz, 2); % p(z) = sum_w p(z|w)p(w)
pz = bsxrdivide(pz, sum(pz)); % normalize to get p(z)
newnode.pz = pz;
pwgz = bsxrdivide(pwgz, sum(pwgz, 2)); % normalize to get p(w|z)
newnode.twmatparent = pwgz(:, newnode.voc_V_map);
% compute the topic for each children of new node
for i = 1:size(newnode.children, 2)
    pwgzi = pwgz(i, :);
    newnode.children{i}.twmati = pwgzi(newnode.children{i}.voc_V_map);
    % update the voc_p_map of new node's children, because their parent has
    % changed
    newnode.children{i}.voc_p_map = arrayfun(@(x)find(newnode.voc_V_map ==x,1), newnode.children{i}.voc_V_map);
    [~, ind] = sort(newnode.children{i}.twmati, 'descend');
    newnode.children{i}.topici = vocabulary(newnode.children{i}.voc_V_map(ind(1, 1:10)));
end

BFSname(node_lca, node_lca.name);
end