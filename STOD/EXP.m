% EXP(t, k): Discover k subtopics of a leaf topic, the leaf topic is
% specified by t.leafpath, e.g., t = t1 and k = 3 looks like this:
%
%     t1     ------>          t1
%                          /  |  \
%                         t11  t12  t13
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
   twmat = [];
   for j=1:size(currentnode.children, 2)
      twmat = [twmat;currentnode.children{1,j}.twmati];
   end
   pzgw = diag(currentnode.alpha1) * twmat; % p(z|w) is proportional to p(w|z)p(z)
   pzgw = bsxfun(@rdivide, pzgw, sum(pzgw));
   twmati = currentnode.children{1,direction}.twmati;
   twmatinz = twmati > 0;
   pzgmi = pzgw(direction,:);
   length = sum(twmatinz);
   dwmat = dwmat(:,twmatinz) * sparse(1:length, 1:length, pzgmi(:,twmatinz));
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
    [~, ind] = sort(twmati, 'descend');
    topici = vocabulary(ind(1, 1:10));
    childi = node(twmati, currentnode, topici, [currentnode.name, num2str(z)]);
    currentnode.children{z} = childi;
end

currentnode.twmatparent = twmat;

end