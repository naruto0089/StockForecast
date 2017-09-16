function [avg] = movingAvg(pos,inputData)
    s =0;
    n=1;
while n <= 5
    s = s + inputData(pos);
    n = n+1;
    pos = pos -1;
end

avg = s/5;
    