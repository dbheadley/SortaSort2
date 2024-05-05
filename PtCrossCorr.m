function [cc, relBins, refInds] = PtCrossCorr(st1,st2,binStep,ccWind)
    % Calculates the cross-correlation of two point processes
    % INPUTS
    % st1, the times for the other point process. Should be sorted in
    % ascending order and integers.
    % st2, the times for the reference point process. Should be sorted in
    % ascending order and integers.
    % binStep, the number of integer steps to count as a bin.
    % ccWind, a vector specifying the number of bins for either edge of the
    % cross correlation function.
    
    % OUTPUTS
    % cc, the cross-correlation counts.
    % relBins, the edges of the bins for cc. 
    % refInds, the indices for st2 that contributed to each cc bin.
    % EXAMPLE
    % calculate cross correlation function with 1ms bins and a window of
    % -20 to 20 ms
    
    %     st1 = sort(round(rand(1000,1)*1000)); % times in milliseconds
    %     st2 = sort(round(rand(1000,1)*1000)); % times in milliseconds
    %     [cc, binEdges] = CrossCorrPt(st1,st2,1,[-20 20]);
    
    % calculate cross correlation function with 5ms bins and a window of
    % -40 to 40 ms
    
    %     st1 = sort(round(rand(1000,1)*1000)); % times in milliseconds
    %     st2 = sort(round(rand(1000,1)*1000)); % times in milliseconds
    %     [cc, binEdges] = CrossCorrPt(st1,st2,5,[-8 8]);
        
    if nargout() > 2
        refIndsYes = true;
    else
        refIndsYes = false;
    end
    
    
    bEdge = ccWind(1)*binStep;
    tEdge = ccWind(2)*binStep;
 
    % Had to get rid of flipping, screwed up refInds and caused subtle
    % shifts in binning
%     if numel(st1) >= numel(st2)
        stRef = st2;
        stOth = st1;
%         flipCC = false;
%     else
%         stRef = st1;
%         stOth = st2;
%         flipCC = true;
%         bTemp = -bEdge;
%         bEdge = -tEdge;
%         tEdge = bTemp;
%     end

    ccTemp = zeros((tEdge-bEdge),1);
    refTemp = zeros(numel(stRef),tEdge-bEdge);
    
    bInd = 1; tInd = 1; rInd = 1;
    lenRef = numel(stRef);
    lenOth = numel(stOth);
    while (rInd <= lenRef) % iterate over all reference spikes
        
        % find index of first spike in other train that is after bottom edge of CC
        % window for current reference spike
        while ((bInd <= lenOth) && (stOth(bInd) <= (stRef(rInd)+bEdge))) 
            bInd = bInd + 1;
        end

        % if you run out of reference spikes stop building CC
        if (bInd > lenOth)
            break;
        end
        
        % if the first other spike after the bottom edge is also past the top
        % edge of the CC window than move to the next reference spike
        if (stOth(bInd) > (stRef(rInd)+tEdge))
            rInd = rInd + 1;
            continue;
        end

        % find index of last spike in other train that is before the bottom
        % edge of the CC window for current reference spike
        while ((tInd <= lenOth) && (stOth(tInd) < (stRef(rInd)+tEdge)))
            tInd = tInd + 1;
        end

        % accumulate the number of spikes in the windowed other train at different
        % delays from the current reference spike
        
        if refIndsYes
            for subInd = bInd:(tInd-1)
                ccInd = (stOth(subInd)-stRef(rInd))-bEdge;
                refTemp(rInd,ccInd) = refTemp(rInd,ccInd)+1;
            end
        else
            for subInd = bInd:(tInd-1)
                ccInd = (stOth(subInd)-stRef(rInd))-bEdge;
                ccTemp(ccInd) = ccTemp(ccInd) + 1;
            end
        end
        rInd = rInd + 1;
    end
    
    if refIndsYes
        ccTemp = sum(refTemp,1);
    end
    % bin accumulated spike counts by the CC step size
    if binStep == 1
        cc = ccTemp;
    else
        binInds = 0:(binStep):(tEdge-bEdge);
        cc = zeros(length(binInds)-1,1);
        for ccInd = 1:(length(binInds)-1)
            cc(ccInd) = sum(ccTemp((binInds(ccInd)+1):binInds(ccInd+1)));
        end
        
        if refIndsYes
            refInds = zeros(numel(stRef),length(binInds)-1);
            for ccInd = 1:(length(binInds)-1)
                refInds(:,ccInd) = sum(refTemp(:,(binInds(ccInd)+1):binInds(ccInd+1)),2);
            end
        end
    end
    
%     if flipCC
%         cc = cc(end:-1:1);
%         if refIndsYes
%             refInds = refInds(:,end:-1:1);
%         end
%     end
    
    relBins = (bEdge:binStep:tEdge)';