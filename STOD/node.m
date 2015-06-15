classdef node < handle
   properties
%       wordidx=[];% vocabulary map
%       wordval=[];% vocabulary * 1 array, word distribution given current topic, p(w|z), w is word, z is topic,normalized
%       parent=[];% parent node
%       children={};% 1 * childnum cell
%       denominator=[]; 
%       alpha0= [];
%       alpha1= [];% childnum * 1 array, topic prior distribution p(child=z|current topic), normalized
%       d1 =[];
%       nnz=[];
%       twmati=[];
%       name= []; % name of the topic/node
%       time =[];
%       phrases = []; % n*7: [length, id, freq, ..., ranking_score]      
   children = {};
   parent = [];
   dwmat = [];
   twmati=[];
   twmatparent = [];
   topici = [];
   alpha1 = [];
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
