objectivefunction = @fitfunction;
nvars = 10;
%1         2  3   4  5   6      7        8      9           10       11      12  
%expander,Aw, A, Ag,pump,n,   thstorage,refsize,tank_volume, usecase, stateID,anual_irr
LB = [1,  5,  1, 5, 5,   50,  30        800,    1,           1,       1,      ]; %lower bound
UB = [1,  20, 10,20,10,  100, 100       2000,   10,          3,       50,     ];%upper bound
%ConstraintFunction = @constraint;
IntCon = [2,4,5,7,9,10,11];
[f,fval,output,population,scores] = ga(objectivefunction,nvars,[],[],[],[],LB,UB,[],IntCon,options);

options=optimoptions('ga','InitialPopulationMatrix',[1,5,1,5,9,90,100,6,6,3,1,3000000],'OutputFcn',...
    @outfunc,'PlotFcn',{@gaplotbestf; @gaplotbestindiv}, 'Generations', 10, 'StallGenLimit',10,...
    'PopulationSize',100,'UseParallel', true);



%usecase 1 is low, 2 is base and 3 is base
