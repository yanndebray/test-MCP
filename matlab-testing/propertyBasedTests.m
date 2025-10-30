function tests = propertyBasedTests
    % PROPERTYBASEDTESTS Property-based tests for MathOperations class
    tests = functiontests(localfunctions);
end

function testAddCommutative(testCase)
    % Test that addition is commutative: a + b = b + a
    for i = 1:100
        a = randn;
        b = randn;
        actual1 = MathOperations.add(a, b);
        actual2 = MathOperations.add(b, a);
        testCase.verifyEqual(actual1, actual2, 'AbsTol', 1e-12);
    end
end

function testAddAssociative(testCase)
    % Test that addition is associative: (a + b) + c = a + (b + c)
    for i = 1:100
        a = randn;
        b = randn;
        c = randn;
        actual1 = MathOperations.add(MathOperations.add(a, b), c);
        actual2 = MathOperations.add(a, MathOperations.add(b, c));
        testCase.verifyEqual(actual1, actual2, 'AbsTol', 1e-12);
    end
end

function testMultiplyCommutative(testCase)
    % Test that multiplication is commutative: a * b = b * a
    for i = 1:100
        a = randn;
        b = randn;
        actual1 = MathOperations.multiply(a, b);
        actual2 = MathOperations.multiply(b, a);
        testCase.verifyEqual(actual1, actual2, 'AbsTol', 1e-12);
    end
end

function testMultiplyDistributive(testCase)
    % Test distributive property: a * (b + c) = (a * b) + (a * c)
    for i = 1:100
        a = randn;
        b = randn;
        c = randn;
        actual1 = MathOperations.multiply(a, MathOperations.add(b, c));
        actual2 = MathOperations.add(MathOperations.multiply(a, b), ...
                                   MathOperations.multiply(a, c));
        testCase.verifyEqual(actual1, actual2, 'AbsTol', 1e-12);
    end
end

function testFactorialPositiveInteger(testCase)
    % Test factorial properties for random positive integers
    for i = 1:20  % Limited range to avoid long computation times
        n = randi([0, 10]);  % Random integer between 0 and 10
        result = MathOperations.factorial(n);
        
        % Verify result is positive
        testCase.verifyGreaterThan(result, 0);
        
        % Verify result is integer
        testCase.verifyEqual(result, floor(result));
        
        % Verify n! = n * (n-1)! for n > 0
        if n > 0
            expected = n * MathOperations.factorial(n - 1);
            testCase.verifyEqual(result, expected);
        end
    end
end