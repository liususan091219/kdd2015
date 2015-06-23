function BFSname(rootnode, rootname)
    rootnode.name = rootname;
    if isempty(rootnode.children) == 0
        for i = 1:size(rootnode.children, 2)
            BFSname(rootnode.children{i}, [rootname, num2str(i)]);
        end
    end
end