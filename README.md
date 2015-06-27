**********************************************
Copyright
**********************************************

This package contains the source code and the dataset used in the following paper:

Chi Wang, Xueqing Liu, Yanglei Song, Jiawei Han. Towards Interactive Construction of Topical Hierarchy:
 A Recursive Tensor Decomposition Approach, 2014.

If you use any contents in this package, please cite:

@inproceedings{wang15,
  title={Towards Interactive Construction of Topical Hierarchy: A Recursive Tensor Decomposition Approach},
  author={Wang, Chi and Liu, Xueqing and Song, Yanglei and Han, Jiawei},
  booktitle={KDD},
  year={2015},
}

**********************************************
Code explanation
**********************************************

(1). Setting up parent folder (the same directory with this README.md):
     >> parentfolder = 'c:/Users/xliu93.UOFI/Work/kddrelease/kdd2015release';
     Setting up data folder:
     >> datafolder = 'c:/Users/xliu93.UOFI/Work/kddrelease/kdd_data';
     Data folder consists of subfolders named by data_name, two files
     should be put in folder datafolder/data_name/: data_name.corpus, which
     is document-word file (each line is in the format 'docID wordID') and
     data_name.dict, which is vocabulary file (each line is in the format 'word');
   
     See example1.m for more details.

(2)  Setting up path. Run the following two command to set up path for data
     processing and main algorithms:
     >> path([parentfolder, '/DataProcess/readdata/'], path);
     >> path([parentfolder, '/STOD/'], path);
     Notice this assumes your code is in the root directory (or the same 
     directory with this README.md), but if your code is in other directories,
     in addition to the two lines above, you should also set up the root 
     directory path using:
     >> path(parentfolder, path);

(3)  Load data:
     >> LoadData;
     Data loading takes long, so you could comment this line in case of
     repeatly running program on the same dataset;

(4)  Set parameters:
     >> SetParameters;
     To change the default parameter setting, edit the file SetParameters.m

(5)  Running EXP:
     >> EXP(t, [1], k, dwmat, options);
     t is the handle to the root of the tree, which is set to an empty node
     before running any EXP program:
     >> t.tree = node([], [], [], '1', 1:size(vocabulary, 1));
     [1] specifies the path of the leaf node to be expanded, and is set to 
     [] at the beginning;
     k is the number of children to be expanded;
     dwmat is the document word matrix, which is computed in LoadData;
     options is set in SetParameters;

     See example1.m for more details.

(6)  Running MER:
     >> MER(t, [1], [1, 1, 1, 1]);
     t is the handle to the root of the tree;
     [1] is the path that specifies the first node t1;
     [1, 1, 1, 1] is the path that specifies the second node t2;
     See example2.m and example3.m for more details.

(7). Output format:

     Output is in the same folder as input file. There are two types of generating an output:

     a) Indented tree text file: which is the tree representation of topics, where the
        hierarchical structure is represented by indentation:
     >> fid = fopen([datafolder, '/', dataname '/tree.txt'], 'w');
     >> DFSprint(t.tree, fid, '');
     >> fclose(fid);

     b) .mat file. It is the tree where each node is the same structure as 
        in node.m:
     >> matfile = [datafolder, '/', dataname '/tree.mat'];
     >> save(matfile,'t.tree')

     See example2.m for more details.

**********************************************
Data explanation
**********************************************
	
kdd_data/csabstract contains CS abstracts used in the paper;
kdd_data/dblptitle contains DBLP title short text used in our paper;
kdd_data/pubmedabstract contains pubmed abstracts used in our paper;
kdd_data/trecapnews contains ap news data used in our paper;

**** For More Questions ****

Please contact illimine.cs.illinois.edu or Chi Wang (chiw@microsoft.com)

