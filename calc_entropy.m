function [H]=calc_entropy(pmf)
H=-sum(pmf.*log2(pmf));
end