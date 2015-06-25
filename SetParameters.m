% set parameters, i.e., options
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.

% parameters that are usually not tuned
options.folder = datafolder;    % output file location
options.dataname = dataname;    % output file prefix
options.N = 30;         % outer iteration times
options.n = 30;         % inner iteration times
options.lr = 1.0;       % learning rate

% options.eigen = 'approx';   % fast algorithm to compute whitening matrix
options.eigen = 'exact';  % exact eigen decomposition

% parameters that are tuned

% parameter to tune K selection, which is the proportion of 
% sum(first K topics eigenvalues) / sum(all eigenvalues), range from 0 to 1
options.proportion = 0.95; 

options.ALPHA0 = 10.0; % initial ALPHA0
% options.ALPHA0 = 2.0235;
% options.learnalpha = 20;    % the maximal # trials for searching alpha
options.learnalpha = 0;     % fix ALPHA0 by setting it to 0
options.epsalpha = 1e-3;    % the convergence threshold for alpha

% the maximal # trials to shrink alpha by half 
% in order to have enough pos eigs
options.alphaiter = 10; 

% options.ALPHA0 - summation of alpha_1, ... , alpha_T
% options.alphaiter - maximal number of shrinking alpha0 in order to find a
%                     valid alpha0
% options.learnalpha - the number of iterations to learn alpha; 0 means no
%                      learning
% options.N - number of outer iterations, for initialization times
% options.n - number of inner iterations, for fixed point iteration times
% options.lr - the learning rate, e.g., options.lr= 1
% options.epsalpha - the convergence threshold for alpha, 
%                    set to a small number,e.g., options.epsalpha = 1e-3
% options.K - the topic number if not to learn the topic number; e.g.,
%             options.K = 5
% 		    - the range of topic number if to learn the topic number,
% 			  e.g. options.K = 2:8
% options.eigen - the algorithm to compute whitening matrix, 
%                 'exact' or 'approx'