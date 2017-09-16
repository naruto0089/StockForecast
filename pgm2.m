%
%
%
% DESCRIPTION OF MODEL
%
%An Hidden Markov model is a quintuple (K,O,π,A,B) Where:
% K is a finite set of states
% O is the observation symbol or output alphabet
% π is a vector containing the initial probabilities of each of the state
% A is  transition probability matrix
% B is a Emission probability Matrix.
%
%In the HMM model I've developed to forecast S&P index daily closing prices
% I've used following things as its parameters
%
%I've used three states in this model each state representing Flat, Uptrend
% and Downtrend based on the previous day value of the closing price.
%
%
%For 'O' I've used three symbols 1,2 and 3 . Each of these symbol means
%following:
%
% 1 -> closing proce in the range (1-0.001)*5-day moving average of closing price and 
%                                               (1-0.001)*5-day moving average
% 2 -> closing proce in the < (1-0.001)*5-day moving average of closing price
% 3 -> closing proce in the < (1-0.001)*5-day moving average of closing price
%
%For initial state probilities I've used the last three probilities I've
%obtained by calculating the posterior state probilities using hmmdecode() 
%
%To obtain the model parameters described above I've trained the model with
%the closing price from 10/16/2015 to 10/14/2016
%
%For Transition Probility and Emission probility I used  hmmestimate
%function to estimate it using the parameters I obtained from data
%
%
%
%Using this hmm model I'm predicting the closing price for 10 days that is
%from  10/15/2016 to  10/25/2016
%
% I've output the Transitional Probility Matrix , Emission Probility
% Matrix, accuracy of the model and the closing price the model predicts
% along with the graph showing the data that is the closing price and
% forecast with time as x-axis and price as y-axis
% 
% 
%This program uses function movingAvg to calculate the moving average of the
%last five closing prices and importfile to import data
%
%This program import the data from the table.csv file. This file contains
%the stock closing prices along with their respective dates for the period
%of one year
%
%
%clear everything
clear
clc

%loading data
[date ,closingPrice] = importfile('table.csv');

%fliping data to arrange data by ascending of date
closingPrice = closingPrice';
closingPrice =fliplr(closingPrice);
%closingPrice = closingPrice';
date= date';
date = fliplr(date);
%date = date';


%Generating Observation Sequence 
observationSequence = ones(1, 252); %considering firt 5 sequences are S


for n = 5:252
   fiveDayMovingAvg =  movingAvg(n, closingPrice); %calling movingAvg function to calculate Average
    a = 0.999*fiveDayMovingAvg;
    b = 1.001*fiveDayMovingAvg;
    
    if closingPrice(n)> a  && closingPrice(n) < b
        observationSequence(1,n)= 1;  % For Observable sequence S 
    elseif  closingPrice(n)< a
        observationSequence(1,n) = 2; % For Observable sequence L
    elseif  closingPrice(n)>b
        observationSequence(1,n) = 3; % For Observable sequence H
    end
end   

% For States 
states = ones(1,3); %considering first state is flat


for iter_n =2:252
    temp1 = closingPrice(iter_n-1);
    temp2 = closingPrice(iter_n);
    if temp1>temp2 
        states(1,iter_n)=2;  %Condtion of Downtrend (D)
    elseif temp1 < temp2     %Condtion of Uptrend (U)
       states(1,iter_n)=3;     
    else                                           
        states(1,iter_n)=1;   %Condtion of Flat (F)
    end
end    


%calculates the maximum likelihood estimates of Trnsionion Matrix and
%Emission Transition Matrix

[A, B] = hmmestimate(observationSequence, states);

disp('State Transition Probability Matrix');
disp(A);
disp('State Observation Probability Matrix');
disp(B);

Q = hmmviterbi(observationSequence, A, B);


Accuracy=sum(states == Q)/252;
fprintf('Accuracy is:')
disp(Accuracy);

%plotting Closing price and states

x = closingPrice;
ts1 = timeseries(x,1:length(x));

ts1.Name = 'Closing Price';
ts1.TimeInfo.Units = 'days';
ts1.TimeInfo.StartDate = '16-Oct-2015';     % Set start date.
ts1.TimeInfo.Format = 'mmm dd, yy';       % Set format for display on x-axis.

ts1.Time = ts1.Time - ts1.Time(1);        % Express time relative to the start date.
subplot(2,2,1);
plot(ts1)
title(' S&P Closing Prices ');
legend('Closing Price')
legend('Location','southeast')
legend('boxoff')


x = states;
ts1 = timeseries(x,1:length(x));

ts1.Name = '1 =F  2 =D or 3 =D';
ts1.TimeInfo.Units = 'days';
ts1.TimeInfo.StartDate = '16-Oct-2015';     % Set start date.
ts1.TimeInfo.Format = 'mmm dd, yy';       % Set format for display on x-axis.

ts1.Time = ts1.Time - ts1.Time(1);        % Express time relative to the start date.
subplot(2,2,2)
plot(ts1)
title('HMM States');
legend('State')
legend('Location','southeast')
legend('boxoff')
ylim([1 5]);


%Calculating the sequence P of posterior state probabilities for O
posteriorProbability = hmmdecode(observationSequence, A,B);




PI=zeros(3,11);    
%taking first three value of posterior probability as  initial probability
%of being in particular state

%taking the last three posterior probility as the initial probability of
%each state

PI(1,1)=posteriorProbability(250); 
PI(2,1)=posteriorProbability(251); 
PI(3,1)=posteriorProbability(252); 


PathPrediction=zeros(27,10);   % 3*3*3

for j=1:10

PathPrediction(1,j)=PI(1,j)*A(1,1)*B(1,1);
PathPrediction(2,j)=PI(1,j)*A(1,1)*B(1,2);
PathPrediction(3,j)=PI(1,j)*A(1,1)*B(1,3);

PathPrediction(4,j)=PI(2,j)*A(2,1)*B(2,1);
PathPrediction(5,j)=PI(2,j)*A(2,1)*B(2,2);
PathPrediction(6,j)=PI(2,j)*A(2,1)*B(2,3);

PathPrediction(7,j)=PI(3,j)*A(3,1)*B(3,1);
PathPrediction(8,j)=PI(3,j)*A(3,1)*B(3,2);
PathPrediction(9,j)=PI(3,j)*A(3,1)*B(3,3);


PathPrediction(10,j)=PI(1,j)*A(1,2)*B(1,1);
PathPrediction(11,j)=PI(1,j)*A(1,2)*B(1,2);
PathPrediction(12,j)=PI(1,j)*A(1,2)*B(1,3);

PathPrediction(13,j)=PI(2,j)*A(2,2)*B(2,1);
PathPrediction(14,j)=PI(2,j)*A(2,2)*B(2,2);
PathPrediction(15,j)=PI(2,j)*A(2,2)*B(2,3);

PathPrediction(16,j)=PI(3,j)*A(3,2)*B(3,1);
PathPrediction(17,j)=PI(3,j)*A(3,2)*B(3,2);
PathPrediction(18,j)=PI(3,j)*A(3,2)*B(3,3);


PathPrediction(19,j)=PI(1,j)*A(1,3)*B(1,1);
PathPrediction(20,j)=PI(1,j)*A(1,3)*B(1,2);
PathPrediction(21,j)=PI(1,j)*A(1,3)*B(1,3);

PathPrediction(22,j)=PI(2,j)*A(2,3)*B(2,1);
PathPrediction(23,j)=PI(2,j)*A(2,3)*B(2,2);
PathPrediction(24,j)=PI(2,j)*A(2,3)*B(2,3);

PathPrediction(25,j)=PI(3,j)*A(3,3)*B(3,1);
PathPrediction(26,j)=PI(3,j)*A(3,3)*B(3,2);
PathPrediction(27,j)=PI(3,j)*A(3,3)*B(3,3);


PI(1,j+1)=max(PathPrediction(1:9,j));
PI(2,j+1)=max(PathPrediction(10:18,j));
PI(3,j+1)=max(PathPrediction(19:27,j));

end



MaxSeqProbability=zeros(1,10);
for kl=2:10
  MaxSeqProbability(1,kl)=max(PathPrediction(1:3,kl));  
end    

predictedState  = ones(1,10);

PredictedSeq=zeros(1,10);

for col=1:10
for row=1:27		% 3*3 *3
if MaxSeqProbability(1,col)==PathPrediction(row,col)

    if mod(row,3)==1
       PredictedSeq(1,col)=1; 
       predictedState(1,col) =1;
    elseif mod(row,3)==2
       PredictedSeq(1,col)=2;
       predictedState(1,col)=2;
    elseif mod(row,3)==0
       PredictedSeq(1,col)=3;   
       predictedState(1,col)=3;
    end
end
end
end


predictedClosingPrice =zeros(1,15);

for n = 1:10
states(1,252+n) = predictedState(1,n);
end

for m =1:5
predictedClosingPrice(m)=closingPrice(247+m); 
end


%Getting Back Price
for n =1:10
    %fiveDayMovingAvg =  mean(predictedClosingPrice(1,n:(n+4)));
    
    fiveDayMovingAvg = movingAvg(n+4, predictedClosingPrice); %calling movingAvg function to calculate Average
    a = 0.999*fiveDayMovingAvg;
    b = 1.001*fiveDayMovingAvg;
if PredictedSeq(n)==3
   predictedClosingPrice(5+n)= b;

elseif PredictedSeq(n)==2 
    predictedClosingPrice(5+n)=a;
    
else 
    predictedClosingPrice(5+n)=(a+b);
   
end
end    


j=6; %since predicted price starts from 6th palce of predictedClosingPrice
disp('Predicted Closing prices');
for i = 253 : 262
    closingPrice(i)= predictedClosingPrice(j);
    disp(predictedClosingPrice(j))
    j=j+1;
end


%removing quotation mark
strrep( date(:,1),'"','');

x = closingPrice;
ts1 = timeseries(x,1:length(x));

ts1.Name = 'Closing Price';
ts1.TimeInfo.Units = 'days';
ts1.TimeInfo.StartDate = '16-Oct-2015';     % Set start date.
ts1.TimeInfo.Format = 'mmm dd, yy';       % Set format for display on x-axis.

ts1.Time = ts1.Time - ts1.Time(1);        % Express time relative to the start date.
subplot(2,2,3);
plot(ts1,'m')
title(' S&P Closing Prices with Predicted Prices ');
legend('Closing Price')
legend('Location','southeast')
legend('boxoff')

x = states;
ts1 = timeseries(x,1:length(x));

ts1.Name = '1 =F  2 =D or 3 =D';
ts1.TimeInfo.Units = 'days';
ts1.TimeInfo.StartDate = '16-Oct-2015';     % Set start date.
ts1.TimeInfo.Format = 'mmm dd, yy';       % Set format for display on x-axis.

ts1.Time = ts1.Time - ts1.Time(1);        % Express time relative to the start date.
subplot(2,2,4)
plot(ts1,'m')
title('HMM States with predicted states');
legend('State')
legend('Location','southeast')
legend('boxoff')
ylim([1 5]);



