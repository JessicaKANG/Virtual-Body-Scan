function [R,t] = decomposeP2(P,K)
temp = K\P;
R = temp(:,1:3);
t = temp(:,4);