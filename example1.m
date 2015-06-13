% example program for interactively constructing a topic hierarchy
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =================================================
% Example 1:
% (1) EXP(t1, 3)
%     
%     t1     ------>          t1
%                          /  |  \
%                         t11  t12  t13
% (2) EXP(t12, 2)
%
%     t1     ------>          t1
%  /  |  \                 /  |  \
% t11 t12 t13             t11 t12 t13
%                            / \
%                           t121 t131
%    
% ==================================================

% read data
global vocabulary parentfolder datafolder

parentfolder = 'c:/Users/xliu93.UOFI/Work/kddrelease/kddrelease';
datafolder = 'c:/Users/xliu93.UOFI/Work/kddrelease/kdd_data';
dataname = 'dblptitle';

path([parentfolder, '/DataProcess/readdata/'], path);
path([parentfolder, '/STOD/'], path);

LoadData;
SetParameters;

t.tree = node([], [], [], '1');

EXP(t, [], 3, dwmat, options);

EXP(t, [2], 2, dwmat, options);

fid = fopen([datafolder, '/', dataname '/tree.txt'], 'w');
DFSprint(t.tree, fid, '');
fclose(fid);