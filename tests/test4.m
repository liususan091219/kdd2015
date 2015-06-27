% test program 4
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =================================================
% MER case 2.1: lca is the parent of t1 or t2
% ==================================================

global vocabulary parentfolder datafolder

parentfolder = 'c:/Users/xliu93.UOFI/Work/kddrelease/kdd2015release';
datafolder = 'c:/Users/xliu93.UOFI/Work/kddrelease/kdd_data';
dataname = 'dblptitle';

path([parentfolder, '/DataProcess/readdata/'], path);
path([parentfolder, '/STOD/'], path);

%LoadData;
%SetParameters;

t.tree = node([], [], [], '1', 1:size(vocabulary, 1));

EXP(t, [], 3, dwmat, options);

EXP(t, [1], 2, dwmat, options);
EXP(t, [3], 2, dwmat, options);

EXP(t, [1, 1], 2, dwmat, options);

MER(t, [1, 1], [3]);

fid = fopen([datafolder, '/', dataname '/tree.txt'], 'w');
DFSprint(t.tree, fid, '');
fclose(fid);