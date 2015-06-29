% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =================================================
% EXP(t, leafpath, k, dwmat, options): discover k topics of a leaf node t
% See Algorithm 1 in paper.
% Parameters: 1. t: root node of the tree;
%             2. leafpath: specify the leaf node with its path ,for example
%             o/1/2's path is [1 2];
%             3. k: the number of topic expanded to leaf node, same as
%             parameter k in Algorithm 1
%             4. dwmat: document-word matrix of root node, for computing
%             fractional dwmat of current leaf node
% =================================================

function EXP(t, leafpath, k, dwmat, options)
global vocabulary

options.K = k;
tree = t.tree;
currentnode = tree;

if isempty(leafpath) == 1
    currentnode.alpha0 = options.ALPHA0;
end

% Compute the fractional document-word matrix for leaf node t. The reason
% for recomputing instead of saving the document-word matrix for each node,
% either in memory or storage, is because the space cost is tree height's exponential
% times of original data size.
for i=1:size(leafpath, 2)
   direction = leafpath(i);
   if size(currentnode.children, 2) < direction
      error('invalid leaf path\n');
   end
   twmat = currentnode.twmatparent;
   pzgw = diag(currentnode.pz) * twmat; % pzgw is p(z|w), z=1,2,...,k, which is proportional to p(w|z)p(z)
   pzgw = bsxfun(@rdivide, pzgw, sum(pzgw));
   twmati = currentnode.children{1,direction}.twmati;
   voc_p_mapi = currentnode.children{1, direction}.voc_p_map;
   pzgmi = pzgw(direction,:); % pzgmi is p(z_i|w)
   length = size(twmati, 2);
   dwmat = dwmat(:, voc_p_mapi) * sparse(1:length, 1:length, pzgmi(:, voc_p_mapi)); % dwmat(d,w) is c(d,w) of current node. c_{z_i}(d,w) = c_parent(d,w) * p(z_i|w)
   currentnode = currentnode.children{1,direction};
end

if isempty(currentnode.children) == false
    error('invalid leaf path\n');
end

issuccess = 0;
while issuccess == 0
    options.ALPHA0 = currentnode.alpha0;
    [issuccess, inferred] = learnTopic(dwmat, options);
    if issuccess == 0
        disp('STOD failed with negative eigen values, this is either because alpha0 is too large, or because k is too large.');
        prompt = 'To fix this, choose from option 1: change alpha0 of root; 2: change k of current node:';
        useroption = input(prompt);
        if useroption ~= 1 && useroption ~= 2
            error('Invalid option, returning....');
        elseif useroption == 1
            error('Please set options.ALPHA0 in SetParameters.m and rerun the program again, see example1.m. Returning...');
        elseif useroption == 2
            prompt = 'Please input the value of new k:';
            userinput = input(prompt);
            if strcmp(class(userinput), 'double') == 1 && rem(userinput, 1) == 0
                if userinput <= 1
                    error('Invalid value of k, returning...');
                end
                options.K = userinput;
                k = userinput;
            else
                error('Invalid value of k, returning...');
            end
        end
    end
end

twmat = inferred.twmat;
currentnode.children = cell(1, k);
currentnode.pz = bsxrdivide(inferred.alpha, sum(inferred.alpha));

for z=1:k
	twmati = twmat(z,:);
    twmatinz = twmati > 0;
    voc_V_mapi = currentnode.voc_V_map(twmatinz);
    [~, ind] = sort(twmati, 'descend');
    topici = vocabulary(currentnode.voc_V_map(ind(1, 1:10)));
    childi = node(twmati(twmatinz), currentnode, topici, [currentnode.name, num2str(z)], voc_V_mapi);
    childi.alpha0 = inferred.alpha(z);
    childi.voc_p_map = find(twmatinz);
    currentnode.children{z} = childi;
    currentnode.twmatparent = twmat;
end

end