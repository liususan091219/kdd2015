function DFSprint(currentnode, fid, spaces)
fprintf(fid, spaces);
fprintf(fid, '%s:\t', currentnode.name);
if isempty(currentnode.topici) == 0
    for i = 1:size(currentnode.topici)
        fprintf(fid, '%s,\t', currentnode.topici{i});
    end
end
fprintf(fid, '\n');
if isempty(currentnode.children) == 0
    for i = 1:size(currentnode.children, 2)
        DFSprint(currentnode.children{i}, fid, [spaces, '\t']);
    end
end
end