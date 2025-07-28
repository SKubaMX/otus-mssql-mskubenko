CREATE ASSEMBLY NewtonsoftJson
FROM '/Users/mskubenko/SqlJsonValidator/bin/Debug/net9.0/Newtonsoft.Json.dll'
WITH PERMISSION_SET = UNSAFE;

CREATE ASSEMBLY SqlJsonValidator
FROM '/Users/mskubenko/SqlJsonValidator/bin/Debug/net9.0/SqlJsonValidator.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS;
GO

CREATE FUNCTION dbo.IsValidJson(@json NVARCHAR(MAX))
RETURNS BIT
AS EXTERNAL NAME SqlJsonValidator.[SqlJsonValidator.JsonFunctions].IsValidJson;
GO

-- 1
SELECT dbo.IsValidJson('{"name": "Alice"}') AS Result;
-- 0
SELECT dbo.IsValidJson('{name: "Bob"}') AS Result; 
-- NULL
SELECT dbo.IsValidJson(NULL) AS Result;



CREATE TABLE JsonTest (
    Id INT PRIMARY KEY,
    Data NVARCHAR(MAX)
);

INSERT INTO JsonTest (Id, Data) VALUES
(1, '{"product": "Laptop", "price": 1000}'),
(2, '{"error": Invalid}');

SELECT 
    Id,
    Data,
    dbo.IsValidJson(Data) AS IsValid
FROM JsonTest;