
function treenode = STROD(dwmat, layer, DEPTH, ALPHA0s, nodewordidx, ...
    nodewordval, nodeparent, nodedenominator, nodetwmati, nodename, d1)
% layer - current layer of topic hierarchy
% DEPTH - number of layers of the hierarchy
% ALPHA0 - summation of alpha_1, ... , alpha_T
% L - number of outer iterations, for initialization times
% N - number of inner iterations, for fixed point iteration times
% lr - the learning rate, such as 1
% folder - the place to store the intermediate data
% parentwordidx - index of parent's nonzero vocabulary
% rootW - number of words in root topic
% epsilon - smoothing parameter
global lralpha rootW epsalpha setTs smooth istrainT istrainalpha maxiteralpha
global Tupper Tlower

treenode = node(nodewordidx, nodewordval, nodedenominator, nodetwmati, nodename);
treenode.parent = nodeparent;
treenode.d1 = d1;

if layer > DEPTH
    return;
end

% start training alpha and T if isalpha = true and istrainT = true

% train T, compute U0 and D0 by the way
U0=[];
D0=[];
if istrainT == true
   % learn topic number
   fprintf('learning T for node %s\n', nodename);
   [issmalldata, iseigsuccess,childnum, U0,D0, treenode.nnz]  = fasttdldatrain(dwmat, Tupper, Tlower);
else 
   [issmalldata, iseigsuccess,childnum, U0,D0, treenode.nnz]  = fasttdldatrain(dwmat, setTs(layer), 0);
end
% if the data is small, or if eigen decomposition never success, should return directly because this dwmat can no longer be partitioned
if issmalldata == true || iseigsuccess == false || isasym == true
   disp 'data is small or cannot find a valid T or cannot find a symmetric decomposition, returning...'
   return;
end

% T is fixed, start training alpha
% initialize alpha as user specified, generate new alpha until this alpha makes a positive D1, this process applies to both istrainalpha = true and istrainalpha = false case
ALPHA0 = ALPHA0s(layer);
[isnegeig, wtmat, alpha1] = fasttdlda(dwmat,childnum, ALPHA0, U0, D0 * (ALPHA0 + 1)); 
iternum = 0;
while isnegeig == true
   ALPHA0 = ALPHA0/2;
   [isnegeig, wtmat, alpha1] = fasttdlda(dwmat,childnum, ALPHA0, U0, D0 * (ALPHA0 + 1)); 
   iternum = iternum + 1;
   % if randomly generate 10 alpha, none of them succeed in decomposing positive eigen values, then this dwmat should no longer be partitioned, return
   if iternum >= 10
      disp(['cannot find a valid alpha for node ' nodename ', returning...']);
      return;
   end
end
% if istrainalpha == true, train alpha from this initialization
if istrainalpha == true
% learn ALPHA0
  iternum = 0;
  while abs(sum(alpha1) - ALPHA0) > epsalpha && iternum < maxiteralpha
      % attempted learning rate
      attemptlralpha = lralpha;
      attemptALPHA0 = (ALPHA0 + attemptlralpha * sum(alpha1)) / (1 + attemptlralpha);
      [isnegeig, attemptwtmat, attemptalpha1] = fasttdlda(dwmat, childnum, attemptALPHA0, U0, D0 * (attemptALPHA0 + 1));
      inneriternum = 0;
      while isnegeig == true
         attemptlralpha = attemptlralpha / 2
         attemptALPHA0 = (ALPHA0 + attemptlralpha * sum(alpha1)) / (1 + attemptlralpha);
         [isnegeig, attemptwtmat, attemptalpha1] = fasttdlda(dwmat, childnum, attemptALPHA0, U0, D0 * (attemptALPHA0 + 1));
         inneriternum = inneriternum + 1;
         if inneriternum >= 10
            break;
         end
      end
      % if any small steps cannot make a positive eigen decomposition, we cannot move forward, so take current alpha
      if inneriternum >= 10
         break;
      end 
      % otherwise update alpha and move on
      disp(['attemptlralpha ' num2str(attemptlralpha) ' ALPHA0 ' num2str(ALPHA0) ' sumalpha1 ' num2str(sum(alpha1)) ' attemptALPHA0 ' num2str(attemptALPHA0)]); 
      if sum(alpha1) > 10000
         alpha1
      end
      ALPHA0 = attemptALPHA0;
      wtmat = attemptwtmat;
      alpha1 = attemptalpha1;
      iternum = iternum + 1;
  end 
end 
  
clear U0;
treenode.alpha0 = ALPHA0;
treenode.children = cell(1, childnum);

ALPHA0 = sum(alpha1);
[treenode.alpha1,ind] = sort(alpha1/ALPHA0, 'descend');
twmat = wtmat(:,ind)';

pzgw = diag(treenode.alpha1) * twmat; % p(z|w) is proportional to p(w|z)p(z)
pzgw = bsxfun(@rdivide, pzgw, sum(pzgw,1));

for i=1:childnum
    twmati = twmat(i,:);
    twmatinz = twmati >= 0.0;%twmati > 0;
    %[~, map, val] = find(twmati);
    pzgmi = pzgw(i,:);
    map = 1:rootW;
    val = twmati;
    l = size(map,2);
    newdwmat = dwmat(:,twmatinz) * sparse(1:l, 1:l, pzgmi(:,twmatinz));
    treenode.children{1,i} = STROD(newdwmat,layer + 1, DEPTH, ALPHA0s, ...
        treenode.wordidx(map), val, treenode, 1.0 + (rootW - l)*smooth, ...
        twmati, strcat(nodename, int2str(i)), D0(i,i));
end
