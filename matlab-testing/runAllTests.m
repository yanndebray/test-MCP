%% Running Tests Example
% This script demonstrates how to run both unit tests and property-based tests
% for the MathOperations class.

%% Run Unit Tests
disp('Running unit tests...');
results = run(MathOperationsTest);
disp(['Passed: ' num2str(sum([results.Passed]))]);
disp(['Failed: ' num2str(sum([results.Failed]))]);

%% Run Property-Based Tests
disp('Running property-based tests...');
results = run(propertyBasedTests);
disp(['Passed: ' num2str(sum([results.Passed]))]);
disp(['Failed: ' num2str(sum([results.Failed]))]);

%% Display Test Coverage (if you have MATLAB Coverage Reports)
try
    import matlab.unittest.plugins.CodeCoveragePlugin
    import matlab.unittest.plugins.codecoverage.CoverageReport
    
    runner = testrunner;
    reportFolder = 'coverage';
    plugin = CodeCoveragePlugin.forFolder('.',...
        'Producing',CoverageReport(reportFolder));
    runner.addPlugin(plugin);
    
    % Run all tests with coverage
    disp('Running tests with coverage...');
    results = runner.run([...
        testsuite('MathOperationsTest'),...
        testsuite('propertyBasedTests')]);
    
    disp(['Coverage report generated in: ' fullfile(pwd, reportFolder)]);
catch
    disp('Note: Code Coverage Report requires Matlab Testing Framework');
end