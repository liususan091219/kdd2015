% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =================================================
% Example 2: MER case 1: t2 is identical to the lca of t1 and t2
% ==================================================

global vocabulary parentfolder datafolder

parentfolder = '.';
datafolder = 'data';
dataname = 'dblptitle';

path([parentfolder, '/DataProcess/readdata/'], path);
path([parentfolder, '/Library/'], path);

%LoadData;
SetParameters;

t.tree = node([], [], [], '1', 1:size(vocabulary, 1));

EXP(t, [], 2, dwmat, options);

EXP(t, [1], 2, dwmat, options);
EXP(t, [1, 1], 2, dwmat, options);

EXP(t, [1, 1,  1], 2, dwmat, options);
EXP(t, [1, 1,  1, 1], 2, dwmat, options);

MER(t, [1], [1, 1, 1, 1]);

fid = fopen([datafolder, '/', dataname '/tree.txt'], 'w');
DFSprint(t.tree, fid, '');
fclose(fid);

matfile = [datafolder, '/', dataname '/tree.mat'];
save(matfile,'t');