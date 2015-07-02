% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =================================================
% Example 1: EXP example
% ==================================================

global vocabulary parentfolder datafolder

parentfolder = '.';
datafolder = 'data';
dataname = 'dblptitle';

path([parentfolder, '/DataProcess/readdata/'], path);
path([parentfolder, '/Library/'], path);

LoadData;
SetParameters;

t.tree = node([], [], [], '1', 1:size(vocabulary, 1));

EXP(t, [], 3, dwmat, options);

EXP(t, [2], 2, dwmat, options);

fid = fopen([datafolder, '/', dataname '/tree.txt'], 'w');
DFSprint(t.tree, fid, '');
fclose(fid);
