% loading data
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
global vocabulary

[dw, dwmat] = ReadEdge([datafolder '/' dataname '/' dataname '.corpus']);
name = ReadName([datafolder '/' dataname '/' dataname '.dict']);
vocabulary=name{1};