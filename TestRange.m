function [] = TestRange(TestingVariable, MinVal, MaxVal, Name)
%TestRange This function tests whether the TestingVariable Input is boudned
%by MinVal and MaxVal or not

%   If the test fails, this function will throw an error showing which
%   variable failed and why

if TestingVariable < MinVal
   error('%s is less than it should be: %d is less than the Lower Limit of %d', Name, TestingVariable, MinVal);
end

if TestingVariable > MaxVal
   error('%s is bigger than it should be: %d is bigger than the Upper Limit of %d', Name, TestingVariable, MaxVal);
end
end

