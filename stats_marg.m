function PMF = stats_marg( im, range )
PMF = hist(im(:),range);  % change range
PMF = PMF/sum(PMF);
end