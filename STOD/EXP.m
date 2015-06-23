% EXP(t, k): Discover k subtopics of a leaf topic, the leaf topic is
% specified by t.leafpath
%
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.

function EXP(t, leafpath, k, dwmat, options)
global vocabulary

options.K = k;
tree = t.tree;
currentnode = tree;

for i=1:size(leafpath, 2)
   direction = leafpath(i);
   if size(currentnode.children, 2) < direction
      error('invalid leaf path\n');
   end
   twmat = currentnode.twmatparent;
   pzgw = diag(currentnode.alpha1) * twmat; % p(z|w) is proportional to p(w|z)p(z)
   pzgw = bsxfun(@rdivide, pzgw, sum(pzgw));
   twmati = currentnode.children{1,direction}.twmati;
   voc_p_mapi = currentnode.children{1, direction}.voc_p_map;
   pzgmi = pzgw(direction,:);
   length = size(twmati, 2);
   dwmat = dwmat(:, voc_p_mapi) * sparse(1:length, 1:length, pzgmi(:, voc_p_mapi));
   currentnode = currentnode.children{1,direction};
end

if isempty(currentnode.children) == false
    error('invalid leaf path\n');
end

inferred = STOD_learn(dwmat, options);

twmat = inferred.twmat;
currentnode.children = cell(1, k);
currentnode.alpha1 = inferred.alpha;

for z=1:k
	twmati = twmat(z,:);
    twmatinz = twmati > 0;
    voc_V_mapi = currentnode.voc_V_map(find(twmatinz));
    [~, ind] = sort(twmati, 'descend');
    topici = vocabulary(currentnode.voc_V_map(ind(1, 1:10)));
    childi = node(twmati(twmatinz), currentnode, topici, [currentnode.name, num2str(z)], voc_V_mapi);
    childi.voc_p_map = find(twmatinz);
    currentnode.children{z} = childi;
    currentnode.twmatparent = twmat;
end

end