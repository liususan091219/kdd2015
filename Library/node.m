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
   children = {};
   parent = [];
   twmati=[];
   twmatparent = [];
   topici = [];
   alpha0 = [];
   pz = [];
   name = [];
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
