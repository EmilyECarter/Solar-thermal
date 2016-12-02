function [state,options,optchanged] =outfunc(options,state,flag)
optchanged=false;
parsave('garun.mat',state.Generation,state.Score,state.Population);
end