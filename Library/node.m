% =======================================================================
% author: Xueqing Liu
% xliu93@illinois.edu
% =======================================================================
% Chi Wang et al., Towards Interactive Construction of Topical Hierarchy: A
% Recursive Tensor Decomposition Approach, KDD 2015.
% =======================================================================
% node structure
% =======================================================================
classdef node < handle
   properties     
   children = {}; % children of the node
   parent = []; % parent of the node
   twmati=[]; % a V-dimensional vector, the w-th dimension corresponding to p(w|i), where i is the index of this node among the node's parent's children
   twmatparent = []; % a k x V matrix, where twmatparent(z, w) is equal to p(w|z), and z is the z-th topic/node among this node's children
   topici = []; % the top-10 word w according to p(w|i), sorted in descending order.
   alpha0 = []; % input parameter of EXP
   pz = []; % topic distribution p(i) of this node
   name = []; % name of this node
   voc_V_map = []; % when the tree goes down, some of the nodes has vocabulary smaller than V, so needs a map to the original vocabulary
   voc_p_map = []; % vocabulary map to the node's parent
   end
 
   methods
      function obj=node(ti, parent, topici, name, voc_V_map)
         obj.twmati = ti;
         obj.parent = parent;
         obj.topici = topici;
         obj.name = name;
         obj.voc_V_map = voc_V_map;
      end
   end
end
