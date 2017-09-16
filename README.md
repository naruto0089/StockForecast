DESCRIPTION OF MODEL

An Hidden Markov model is a quintuple (K,O,Ï€,A,B) Where:
 K is a finite set of states
 O is the observation symbol or output alphabet
 Ï€ is a vector containing the initial probabilities of each of the state
 A is  transition probability matrix
 B is a Emission probability Matrix.

In the HMM model I've developed to forecast S&P index daily closing prices
 I've used following things as its parameters

I've used three states in this model each state representing Flat, Uptrend
 and Downtrend based on the previous day value of the closing price.


For 'O' I've used three symbols 1,2 and 3 . Each of these symbol means
following:

 1 -> closing proce in the range (1-0.001)*5-day moving average of closing price and 
                                               (1-0.001)*5-day moving average
 2 -> closing proce in the < (1-0.001)*5-day moving average of closing price
 3 -> closing proce in the < (1-0.001)*5-day moving average of closing price

For initial state probilities I've used the last three probilities I've
obtained by calculating the posterior state probilities using hmmdecode() 

To obtain the model parameters described above I've trained the model with
the closing price from 10/16/2015 to 10/14/2016

For Transition Probility and Emission probility I used  hmmestimate
function to estimate it using the parameters I obtained from data



Using this hmm model I'm predicting the closing price for 10 days that is
%from  10/15/2016 to  10/25/2016

 I've output the Transitional Probility Matrix , Emission Probility
 Matrix, accuracy of the model and the closing price the model predicts
 along with the graph showing the data that is the closing price and
 forecast with time as x-axis and price as y-axis
 
 
This program uses function movingAvg to calculate the moving average of the
last five closing prices and importfile to import data

This program import the data from the table.csv file. This file contains
the stock closing prices along with their respective dates for the period
of one year
