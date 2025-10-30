classdef MathOperations
    % MathOperations Simple class with math operations to demonstrate testing
    
    methods (Static)
        function result = add(a, b)
            % ADD Add two numbers or arrays element-wise
            arguments
                a {mustBeNumeric}
                b {mustBeNumeric}
            end
            result = a + b;
        end
        
        function result = multiply(a, b)
            % MULTIPLY Multiply two numbers or arrays element-wise
            arguments
                a {mustBeNumeric}
                b {mustBeNumeric}
            end
            result = a .* b;
        end
        
        function result = factorial(n)
            % FACTORIAL Calculate factorial of non-negative integer
            arguments
                n (1,1) {mustBeInteger, mustBeNonnegative}
            end
            if n == 0
                result = 1;
            else
                result = n * MathOperations.factorial(n - 1);
            end
        end
    end
end