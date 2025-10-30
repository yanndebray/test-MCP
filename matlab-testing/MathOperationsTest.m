classdef MathOperationsTest < matlab.unittest.TestCase
    % MathOperationsTest Unit tests for MathOperations class
    
    methods (Test)
        function testAddScalars(testCase)
            % Test addition of scalar values
            actual = MathOperations.add(2, 3);
            expected = 5;
            testCase.verifyEqual(actual, expected);
        end
        
        function testAddVectors(testCase)
            % Test addition of vectors
            a = [1, 2, 3];
            b = [4, 5, 6];
            actual = MathOperations.add(a, b);
            expected = [5, 7, 9];
            testCase.verifyEqual(actual, expected);
        end
        
        function testMultiplyScalars(testCase)
            % Test multiplication of scalar values
            actual = MathOperations.multiply(2, 3);
            expected = 6;
            testCase.verifyEqual(actual, expected);
        end
        
        function testMultiplyVectors(testCase)
            % Test multiplication of vectors
            a = [1, 2, 3];
            b = [4, 5, 6];
            actual = MathOperations.multiply(a, b);
            expected = [4, 10, 18];
            testCase.verifyEqual(actual, expected);
        end
        
        function testFactorialZero(testCase)
            % Test factorial of 0
            actual = MathOperations.factorial(0);
            expected = 1;
            testCase.verifyEqual(actual, expected);
        end
        
        function testFactorialPositive(testCase)
            % Test factorial of positive number
            actual = MathOperations.factorial(5);
            expected = 120;
            testCase.verifyEqual(actual, expected);
        end
        
        function testFactorialError(testCase)
            % Test that factorial errors on negative input
            testCase.verifyError(@() MathOperations.factorial(-1), ...
                'MATLAB:validators:mustBeNonnegative');
        end
    end
end