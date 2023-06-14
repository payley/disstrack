%% Plots of custom arrays for stim evoked connectivity assays
function plot_array(plot,C,nI,nm)
% runs through both arrays and all channels
% currently configured to work only with stim workflow
% needs to be reworked to also use with other workflows
%
% INPUT: 
% plot; a string input for setting the case: 
% 'lat' for plotting latency using a multicolored patch plot
% 'amp' for plotting amplitude of the response using the same plot type
% 'both' for plotting latency and amplitude of response
% 'map' for plotting map data related to SEC assays
% C; a table of blocks selected and their respective stimulation array/channel
% nI; an optional table of ICMS-evoked movements reorganized by plotting order
% nm; an optional string for the corresponding map dates
%
%
% OUTPUT:
% only figures at this point

%% Set variables
switch plot
    case 'lat'
        low_lim = 0.8; % low end of latency data for color scale
        up_lim = 20; % high end of latency data for color scale
        mid = 4; % sets a midpoint for color values to transition
        cut_off = 0.8; % grays out values when the blanking window may be too large to consider acute responses
        transp = 0.005; % set to p-value for significance threshold
        type = 'patch';
    case 'amp'
        low_lim = 1;
        up_lim = 100;
        mid = 10;
        cut_off = [];
        transp = 0.005;
        type = 'patch';
    case 'both'
        low_lim = 0.8;
        up_lim = 20;
        mid = 4;
        cut_off = 0.8; 
        type = 'circ';
    case 'map'
        type = 'circ';
end
%% Plot figures
switch plot
    case {'lat','amp'} % plot either latency or amplitude as a patch figure
        for i = 1:size(C.Blocks,1)
            [fig,pat,ax,xc,yc] = create_array_fig(type,C.Probe_Flip(i));
            hold on
            reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 ...
                24 25 26 17 18 19 20 36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 ...
                60 61 62 63 64 53 54 55 56 57 58 49 50 51 52]'; % key for spatially plotting channels
            id = reArr(1:32) - 1; % actual channel titles
            id = [id;id];
            txt_id = compose('Ch%03d',id);
            txt_id2 = compose('Ch_%03d',id);
            txt = text(xc,yc,txt_id,'Interpreter','none');
            text(5,7,char(C.Blocks(i)),'Interpreter','none','FontSize',18); % not sure why title call is not working
            if C.Probe_Flip(i) == 1 % flip arrays
                text(10,6.5,'P1','FontSize',14);
                text(3,6.5,'P2','FontSize',14);
            else
                text(3,6.5,'P1','FontSize',14);
                text(10,6.5,'P2','FontSize',14);
            end
            % gets table of channels stats
            [chPlot] = channel_stats(C,i,reArr,txt_id,txt_id2);
            % assign patch colors based on latency
            pat.FaceColor = 'flat';
            switch plot
                case 'lat'
                    if ~isempty(cut_off)
                        cond = sum(chPlot.blank_win > cut_off);
                        if cond > 0
                            chPlot.pk_latency(chPlot.blank_win > 0.8) = 0;
                        end
                    end
                    pat.FaceVertexCData = chPlot.pk_latency;
                    if ~isempty(transp)
                        t = ones(64,1);
                        idxT = chPlot.rand_sig > transp;
                        nidxT = find(~idxT);
                        for ii = 1:size(nidxT)
                            tt = nidxT(ii);
                            txt(tt).FontWeight = 'bold';
                        end
                        t(idxT) = 0.5;
                        set(pat,'FaceVertexAlphaData',t,'FaceAlpha','flat','AlphaDataMapping','none');
                    end
                case 'amp'
                    if ~isempty(cut_off)
                        cond = sum(chPlot.blank_win > cut_off);
                        if cond > 0
                            chPlot.pk_rate(chPlot.blank_win > 0.8) = 0;
                        end
                    end
                    pat.FaceVertexCData = chPlot.pk_rate;
                    if ~isempty(transp)
                        t = ones(64,1);
                        idxT = find(chPlot.rand_sig > transp);
                        nidxT = find(~idxT);
                        for ii = 1:size(nidxT)
                            tt = nidxT(ii);
                            txt(tt).FontWeight = 'bold';
                        end
                        t(idxT) = 0.5;
                        txt(~idxT).FontWeight = 'bold';
                        set(pat,'FaceVertexAlphaData',t,'FaceAlpha','flat','AlphaDataMapping','none');
                    end
            end
            [cmap,bound] = set_colormap(low_lim,up_lim,mid,cut_off);
            colormap(cmap);
            colorbar;
            caxis(bound);
            % id stim channel and label
            idxP = C.Stim_Probe(i);
            idxCh = C.Stim_Ch(i);
            if idxP == 1
                pr_list = (1:32);
                stCh = pr_list(idxCh);
            elseif idxP == 2
                pr_list = (33:64);
                stCh = pr_list(idxCh);
            end
            iCh = find(reArr == stCh);
            tStim = text(xc(iCh),yc(iCh),'X','Fontweight','bold','Fontsize',32);
        end
    case 'both' % plots both latency and amplitude using circles made with scatter
        for i = 1:size(C.Blocks,1)
            % gets table of channels stats
            reArr = [4 3 2 1 10 9 8 7 6 5 16 15 14 13 12 11 27 28 29 30 31 32 21 22 23 ...
                24 25 26 17 18 19 20 36 35 34 33 42 41 40 39 38 37 48 47 46 45 44 43 59 ...
                60 61 62 63 64 53 54 55 56 57 58 49 50 51 52]'; % key for spatially plotting channels
            id = reArr(1:32) - 1; % actual channel titles
            id = [id;id];
            txt_id = compose('Ch%03d',id);
            txt_id2 = compose('Ch_%03d',id);
            [chPlot] = channel_stats(C,i,reArr,txt_id,txt_id2);
            % set color to represent latency; size for spike rate of peak
            if ~isempty(cut_off)
                cond = sum(chPlot.blank_win > cut_off);
                if cond > 0
                    chPlot.pk_latency(chPlot.blank_win > 0.8) = 0;
                end
            end
            color = chPlot.pk_latency;
            radii = zeros(64,1);
            radii(chPlot.pk_rate >= 20) = 3000;
            radii(chPlot.pk_rate < 20 & chPlot.pk_rate > 10) = 1500;
            radii(chPlot.pk_rate < 10 & chPlot.pk_rate > 5) = 750;
            radii(chPlot.pk_rate < 5) = 300;
            [fig,circ,ax,xc,yc,add] = create_array_fig(type,C.Probe_Flip(i),color,radii);
            hold on
            text(4,8.5,char(C.Blocks(i)),'Interpreter','none','FontSize',18); % title
            if C.Probe_Flip(i) == 1 % flip arrays
                text(9,7.5,'P1','FontSize',14);
                text(2,7.5,'P2','FontSize',14);
            else
                text(2,7.5,'P1','FontSize',14);
                text(9,7.5,'P2','FontSize',14);
            end
            [cmap,bound] = set_colormap(low_lim,up_lim,mid,cut_off);
            colormap(cmap);
            colorbar;
            caxis(bound);
            % id stim channel and label scatterpoint with an outline
            idxP = C.Stim_Probe(i);
            idxCh = C.Stim_Ch(i);
            if idxP == 1
                pr_list = (1:32);
                stCh = pr_list(idxCh);
            elseif idxP == 2
                pr_list = (33:64);
                stCh = pr_list(idxCh);
            end
            iCh = find(reArr == stCh);
            set(add,'XData',xc(iCh),'YData',yc(iCh),'SizeData',radii(iCh),'CData',color(iCh))
        end
    case 'map'
            color = nI.(nm{1});
            sz = nI.(nm{2});
            radii = zeros(numel(sz),1);
            radii(sz == 80) = 100;
            radii(sz < 80 & sz >= 60) = 800;
            radii(sz < 60 & sz >= 40) = 1500;
            radii(sz < 40 & sz >= 20) = 2200;
            radii(sz < 20 & sz >= 0) = 2900;
            [fig,circ,ax,xc,yc,add] = create_array_fig(type,0,color,radii); % flip set to zero as it is accounted for earlier
            hold on
            delete(add);
            set(ax,'XColor','none','YColor','none')
            text(4,8.5,char(nm{1}),'Interpreter','none','FontSize',18); % title
            % set colors for map so that 0=NR;1=dFl;2=pFl;3=trunk/neck;4=face;5=whiskers
            cmap = [0 0 0;
                0.6350 0.0780 0.1840;
                0.8500 0.3250 0.0980;
                0.4940 0.1840 0.5560;
                0.3010 0.7450 0.9330;
                0 0.4470 0.7410];
            colormap(cmap);
            caxis ([0 6]);
            colorbar('Ticks',[0.5,1.5,2.5,3.5,4.5,5.5],...
                'TickLabels',{'No Response','Distal Forelimb','Proximal Forelimb','Trunk/Neck','Face','Vibrissa'})
end