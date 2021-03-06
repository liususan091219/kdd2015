% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =================================================
% STOD_learn(dwmat, options): try to execute scalable and robust fast
% tensor decomposition LDA to dwmat
% Parameters: 1. dwmat - document word matrix
% Outputs: 1. issuccess: 0 if tensor decomposition is not success. This is
% because depending on parameter alpha0 and k, some eigen value can be
% negative, which will produce imaginary results. If this happens, the user
% can either change alpha0 of the root node or the k of current node
%          2. inferred.alpha: inferred topic distribution p(z) * parent's
%          alpha0, which is set to the default alpha0 of the z-th child.
%             inferred.twmat: k x V matrix which is topic word distribution
% =================================================

function [issuccess, inferred] = STOD_learn(dwmat, options)
tic0 = tic;
if length(options.K)>1
   % learn topic number
   disp('learning number of topics');
end
if strcmp(options.eigen,'exact')
    disp 'computing whitening matrix using exact algorithm...';
    [issmalldata,iseigsuccess,isasym,k,U0,D0]=decomp0(dwmat, ...
        options);   
else
    disp 'computing whitening matrix using approximate algorithm...';
    [issmalldata,iseigsuccess,isasym,k,U0,D0]=decomp0_lowdim(...
        dwmat,options);
end

disp(['finished computing whitening matrix in ' num2str(toc(tic0)) ' seconds']);
disp '-------------------------';
% if the data is small, or if eigen decomposition never succeeds, 
% should return directly because this dwmat can no longer be partitioned
if issmalldata == true || iseigsuccess == false || isasym == true
   disp 'data is small or cannot find a valid k or E2 asymmetric'
   return;
end

% initialize alpha as user specified, generate new alpha until this alpha 
% makes a positive D1. this process applies regardless of istrainalpha 
ALPHA0 = options.ALPHA0;
tic1 = tic;
%disp 'started learning alpha...';
%for iternum = 1:options.alphaiter
[isnegeig, wtmat, alpha1] = decomp(dwmat,k,ALPHA0,U0,D0*(ALPHA0+1),...
        options);  
if isnegeig
    issuccess = 0;
    inferred = [];
    return;
else
    issuccess = 1;
end
  
clear U0;
%inferred.alpha0 = ALPHA0;

%ALPHA0 = sum(alpha1);
[inferred.alpha,ind] = sort(bsxrdivide(alpha1, sum(alpha1)) * ALPHA0, 'descend');
inferred.twmat = wtmat(:,ind)';

