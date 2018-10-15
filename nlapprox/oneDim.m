function [beta_out,lambdas] = oneDim(y,x,index,thresh,innerIter, ...
    outerIter, outerThresh, minFrac, ...
    nlam,lambdas,gamma,verbose, ...
    step,reset,alpha)
if(isempty(lambdas))
    lambdas = [1, 2, 3];
    % not yet implemented:
    %lambdas = betterPathCalc(data = data, index = index, alpha=alpha, min.frac = min.frac, nlam = nlam, type = "linear")
end
nlam1 = length(lambdas);
if nlam1~=nlam
    %warning('number of lambdas specified and the length of lambda vector is not the same. nlam set to the length of lambda vetor');
    nlam = nlam1;
end
X = x;
y = y;
[n,p] = size(X);
nrow = n;
ncol = p;
%_ Set up the group lasso _%

[~,ord] = sort(index);
index = index(ord);
X = X(:,ord);
[~,unOrd]=ismember(1:length(ord),ord);

%_ preparing for C++ _%
groups = unique(index);
numGroup = length(groups);

rangeGroupInd = zeros((numGroup+1),1);
for i = 1:numGroup
    rangeGroupInd(i,:) = find(index == groups(i), 1 ) - 1;
end
rangeGroupInd(numGroup+1) = p;
groupLen = diff(rangeGroupInd);

%_Loop through Lambdas_%
for k = 1:nlam
    eta = zeros(n,1);
    lambda1 = lambdas(k)*alpha;
    lambda2 = lambdas(k)*(1-alpha);
    
    [beta, betaIsZero] = c_linNest_mex(X, y, int32(index), int32(nrow), int32(ncol), ...
        int32(numGroup), int32(rangeGroupInd), int32(groupLen), lambda1, ...
        lambda2, int32(innerIter), int32(outerIter), thresh, ...
        outerThresh, eta, gamma, step, int32(reset));
    beta_new(:,k)  = beta';
    if(verbose)
        disp(['*** Lambda - ', num2str(k), ' ***']);
    end
end

beta_out = beta_new(unOrd,:);
lambdas = lambdas;




