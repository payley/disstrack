%% Make array id variable
nBl = size(listBl,1);
arr_id = cell(nBl,1);
ch_id = cell(nBl,1);
for i = 1:nBl
    if listBl.exp_group(i) == 1 && ~isnan(listBl.exp_time(i))
        fOrd = contains(listBl.array_order{i}{1},listBl.reach{i});
        idxR = contains(listBA_injH.Properties.RowNames,listBl.animal_name{i});
        idxC = listBl.exp_time(i) + 1;
        n1 = size(listBA_injH{idxR,idxC}{1},1);
        n2 = size(listBA_uninjH{idxR,idxC}{1},1);
        if fOrd == 0
            arr_id{i} = [repmat("A",n1,1); repmat("B",n2,1)];
            ch_id{i} = [(1:n1)'; (n1+1:n1+n2)'];
        else
            arr_id{i} = [repmat("B",n1,1); repmat("A",n2,1)];
            ch_id{i} = [(n2+1:n2+n1)'; (1:n2)'];
        end
    elseif isnan(listBl.exp_time(i)) && ~isempty(listBl.z_mean{i})
        fOrd = contains(listBl.array_order{i}{1},listBl.reach{i});
        idxU = contains(listBl_ctrl.animal_name,listBl.animal_name{i}) & listBl_ctrl.exp_time == listBl.incl_control(i);
        n1 = size(listBl_ctrl.injH_align{idxU},1);
        n2 = size(listBl_ctrl.uninjH_align{idxU},1);
        if fOrd == 0
            arr_id{i} = [repmat("A",n1,1); repmat("B",n2,1)];
            ch_id{i} = [(1:n1)'; (n1+1:n1+n2)'];
        else
            arr_id{i} = [repmat("B",n1,1); repmat("A",n2,1)];
            ch_id{i} = [(n2+1:n2+n1)'; (1:n2)'];
        end
    end
end