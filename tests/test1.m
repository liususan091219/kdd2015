% test program 1
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% ==================================================
% MER case 1.1: t2 is the parent of t1
% ==================================================

global vocabulary parentfolder datafolder

parentfolder = 'c:/Users/xliu93.UOFI/Work/kddrelease/kdd2015release';
datafolder = 'c:/Users/xliu93.UOFI/Work/kddrelease/kdd_data';
dataname = 'dblptitle';

path(parentfolder, path);
path([parentfolder, '/DataProcess/readdata/'], path);
path([parentfolder, '/STOD/'], path);

%LoadData;
SetParameters;

t.tree = node([], [], [], '1', 1:size(vocabulary, 1));

EXP(t, [], 2, dwmat, options);

EXP(t, [1], 2, dwmat, options);
EXP(t, [1, 1], 2, dwmat, options);

fid = fopen([datafolder, '/', dataname '/tree_before.txt'], 'w');
DFSprint(t.tree, fid, '');
fclose(fid);

MER(t, [1], [1, 1]);

fid = fopen([datafolder, '/', dataname '/tree_after.txt'], 'w');
DFSprint(t.tree, fid, '');
fclose(fid);