# Parsergen Test
Run tests for parsergen

JSON test cases from [JSON Schema Test Suite](https://github.com/json-schema-org/JSON-Schema-Test-Suite)

## How to run
```
ecs -- "-S 5000" ./test_driver.ecs <FOLDER OF TESTS>
```
Output of `test_driver.ecs`
+ `result.csv`: test results, contains two columns of data presenting the performance boost and accuracy of prediction algorithm in percentage
+ `error.log`: failed files