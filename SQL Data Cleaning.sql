/* Data Cleaning in SQL Queries */

SELECT 
  *
FROM Nashville_Housing_Data_for_Data_Cleaning nhdfdc 
LIMIT
  1000
  
------------------------------------------------------------  
  
-- Standardizing Date Format (SaleDate column)
  
SELECT  
  SaleDate
FROM
  Nashville_Housing_Data_for_Data_Cleaning 

-- If it does not update properly:
ALTER TABLE
  Nashville_Housing_Data_for_Data_Cleaning
ADD 
  SalesDate_Converted Date
  
UPDATE 
  Nashville_Housing_Data_for_Data_Cleaning 
SET  
  SalesDate_Converted = CONVERT(Date, SaleDate)

  
-- Not supported in SQLite, but in other SQL Server
SELECT  
  SaleDate, 
  CONVERT(datetime, SaleDate, 103) AS Date
FROM
  Nashville_Housing_Data_for_Data_Cleaning 
  
UPDATE
  Nashville_Housing_Data_for_Data_Cleaning 
SET 
  SaleDate = CONVERT(Date,SaleDate)


--SQLite process: Creating the standardized YYYY-MM-DD (Optimal for SQLite)
SELECT 
  SaleDate,
  (substr(SaleDate, -4, 4) || '-' || -- extracts last 4 characters, the year
   CASE -- CASE function to convert the month into digits
     WHEN instr(SaleDate, 'January') > 0 THEN '01' 
     WHEN instr(SaleDate, 'February') > 0 THEN '02'
     WHEN instr(SaleDate, 'March') > 0 THEN '03'
     WHEN instr(SaleDate, 'April') > 0 THEN '04'
     WHEN instr(SaleDate, 'May') > 0 THEN '05'
     WHEN instr(SaleDate, 'June') > 0 THEN '06'
     WHEN instr(SaleDate, 'July') > 0 THEN '07'
     WHEN instr(SaleDate, 'August') > 0 THEN '08'
     WHEN instr(SaleDate, 'September') > 0 THEN '09'
     WHEN instr(SaleDate, 'October') > 0 THEN '10'
     WHEN instr(SaleDate, 'November') > 0 THEN '11'
     WHEN instr(SaleDate, 'December') > 0 THEN '12'
   END || '-' || -- concat [|| ||] with the digit months with '-'
   CASE -- ensure the day is two digits
     WHEN length(trim(substr(SaleDate, instr(SaleDate, ' '), instr(SaleDate, ',') - instr(SaleDate, ' ')))) = 1 --checks length, trim used to remove spaces
     THEN '0' || trim(substr(SaleDate, instr(SaleDate, ' '), instr(SaleDate, ',') - instr(SaleDate, ' '))) -- if 1 character length, then concat with '0' + previous WHEN query to extract the exact date digit together
     ELSE trim(substr(SaleDate, instr(SaleDate, ' '), instr(SaleDate, ',') - instr(SaleDate, ' '))) -- extract date length (2 characters) without any changes
     END
  ) AS standardized_date
FROM 
  Nashville_Housing_Data_for_Data_Cleaning
  
/* instr(column, "string"/value) > 0 THEN 'Y' checks if 'Month' is in the SaleDate string column, If found, it returns a position greater than 0, 
 indicating the month is "January", which is then converted to '01'. */
  
-- Update the new date format into the Table (Step 1: insert new column)
ALTER TABLE
  Nashville_Housing_Data_for_Data_Cleaning
ADD COLUMN
  Standardized_Date TEXT; -- if other SQL Servers like MySQL/PostgreSQL apply DATE instead of TEXT

-- Update (Step 2: Add permanently into the new column with UPDATE SET Clause)
UPDATE 
  Nashville_Housing_Data_for_Data_Cleaning 
SET
  Standardized_Date = (substr(SaleDate, -4, 4) || '-' || 
   CASE 
     WHEN instr(SaleDate, 'January') > 0 THEN '01' 
     WHEN instr(SaleDate, 'February') > 0 THEN '02'
     WHEN instr(SaleDate, 'March') > 0 THEN '03'
     WHEN instr(SaleDate, 'April') > 0 THEN '04'
     WHEN instr(SaleDate, 'May') > 0 THEN '05'
     WHEN instr(SaleDate, 'June') > 0 THEN '06'
     WHEN instr(SaleDate, 'July') > 0 THEN '07'
     WHEN instr(SaleDate, 'August') > 0 THEN '08'
     WHEN instr(SaleDate, 'September') > 0 THEN '09'
     WHEN instr(SaleDate, 'October') > 0 THEN '10'
     WHEN instr(SaleDate, 'November') > 0 THEN '11'
     WHEN instr(SaleDate, 'December') > 0 THEN '12'
   END || '-' || 
   CASE 
     WHEN length(trim(substr(SaleDate, instr(SaleDate, ' '), instr(SaleDate, ',') - instr(SaleDate, ' ')))) = 1 --checks length, trim used to remove spaces
     THEN '0' || trim(substr(SaleDate, instr(SaleDate, ' '), instr(SaleDate, ',') - instr(SaleDate, ' '))) -- if 1 character length, then concat with '0' + previous WHEN query to extract the exact date digit together
     ELSE trim(substr(SaleDate, instr(SaleDate, ' '), instr(SaleDate, ',') - instr(SaleDate, ' '))) -- extract date length (2 characters) without any changes
     END
  );
 
 
------------------------------------------------------------  

-- Populate Property Address Date (has NULL/Blank rows)
 
SELECT 
  PropertyAddress 
FROM 
  Nashville_Housing_Data_for_Data_Cleaning
WHERE  
  PropertyAddress == "" -- [PropertyAdress IS NULL] for other SQL Servers
 
--Cross checking with ParcelID column for address data
SELECT 
  PropertyAddress,
  ParcelID 
FROM
  Nashville_Housing_Data_for_Data_Cleaning
ORDER BY
  ParcelID 
  
-- Join table to find corresponding address for missing ones
SELECT
  a.ParcelID,
  a.PropertyAddress,
  b.ParcelID,
  b.PropertyAddress,
  IFNULL(a.PropertyAddress, b.PropertyAddress) -- other SQL Server, use ISNULL
FROM Nashville_Housing_Data_for_Data_Cleaning AS a
JOIN Nashville_Housing_Data_for_Data_Cleaning AS b
  ON a.ParcelID = b.ParcelID 
  AND a."UniqueID " <> b."UniqueID " -- parsing same table itself, while still separating rows of repeating ParcelIDs with UniqueID
WHERE
  a.PropertyAddress = ""
  
-- When column is empty instead of NULLs
SELECT
  a.ParcelID,
  a.PropertyAddress,
  b.ParcelID,
  b.PropertyAddress,
  CASE 
  	WHEN a.PropertyAddress = ""
  	THEN b.PropertyAddress
  	ELSE a.PropertyAddress
  END AS Address
FROM Nashville_Housing_Data_for_Data_Cleaning AS a
JOIN Nashville_Housing_Data_for_Data_Cleaning AS b
  ON a.ParcelID = b.ParcelID 
  AND a."UniqueID " <> b."UniqueID " -- parsing same table itself, while still separating repeating ParcelIDs with UniqueID
WHERE
  a.PropertyAddress = ""
  
--Update blank address (does not work on SQLite)
UPDATE a
SET 
  PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM
  PortfolioProject.dbo.NashvilleHousing a
JOIN 
  PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
  a.PropertyAddress is null
  
-- SQLite version to update through subquery
UPDATE Nashville_Housing_Data_for_Data_Cleaning
SET PropertyAddress = (
  SELECT 
    b.PropertyAddress
  FROM 
    Nashville_Housing_Data_for_Data_Cleaning AS b
  WHERE 
    Nashville_Housing_Data_for_Data_Cleaning.ParcelID = b.ParcelID
  AND 
    Nashville_Housing_Data_for_Data_Cleaning."UniqueID " <> b."UniqueID "
  LIMIT 1
)
WHERE PropertyAddress = ""

------------------------------------------------------------  
  
-- Splitting Property Address Column into 2 seprate columns (HouseNumber+Street, City)

SELECT 
  PropertyAddress 
FROM 
  Nashville_Housing_Data_for_Data_Cleaning 
  
SELECT 
  SUBSTR(PropertyAddress,1,INSTR(PropertyAddress,',')- 1) AS Address, --SQLite ver of SUBSTRING and CHARINDEX
  SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',')+ 1, LENGTH(PropertyAddress)) AS City --other SQL uses LEN() instead of LENGTH
FROM
  Nashville_Housing_Data_for_Data_Cleaning  

ALTER TABLE
  Nashville_Housing_Data_for_Data_Cleaning
ADD COLUMN
  StreetAddress TEXT; 
  
ALTER TABLE
  Nashville_Housing_Data_for_Data_Cleaning
ADD COLUMN
  City TEXT; 
  
UPDATE 
  Nashville_Housing_Data_for_Data_Cleaning 
SET 
  StreetAddress = SUBSTR(PropertyAddress,1,INSTR(PropertyAddress,',')- 1)
  
UPDATE 
  Nashville_Housing_Data_for_Data_Cleaning 
SET   
  City = SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',')+ 1, LENGTH(PropertyAddress))
  
------------------------------------------------------------  
  
/* Splitting Owner Address Column into 3 seprate columns (HouseNumber+Street, City, State)
 * The PARSENAME method, which is not available in SQLite
 */
  
SELECT 
  OwnerAddress 
FROM 
  Nashville_Housing_Data_for_Data_Cleaning  

SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM 
  Nashville_Housing_Data_for_Data_Cleaning  

ALTER TABLE 
  Nashville_Housing_Data_for_Data_Cleaning 
ADD COLUMN
  OwnerStreetAddress Nvarchar(255);

Update 
  Nashville_Housing_Data_for_Data_Cleaning 
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE 
  Nashville_Housing_Data_for_Data_Cleaning 
Add OwnerCity Nvarchar(255);

Update 
  Nashville_Housing_Data_for_Data_Cleaning 
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE 
  Nashville_Housing_Data_for_Data_Cleaning 
ADD COLUMN 
  OwnerState Nvarchar(255);

UPDATE
  Nashville_Housing_Data_for_Data_Cleaning 
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- SQLite Method: Splitting into 3 columns

SEELCT *
FROM Nashville_Housing_Data_for_Data_Cleaning 
  
--Use CTE to find Address Comma positions & Split into 3 columns 
WITH AddressParts AS (
  SELECT
    OwnerAddress,
    INSTR(OwnerAddress, ',') AS Comma1Pos, --finds the 1st comman position value
    INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') + INSTR(OwnerAddress, ',') AS Comma2Pos 
    	/* Finds the 2nd comma position by: 
    	 * 1st half: the substr(...) gets the remaining address after the 1st comma (returns: Goodlettsville, TN)
    	 * cont: Equates to instr(subtring extracted, ',') for the 2nd comma position value
    	 * 2nd half: adds on the 1st comman position value, getting 2nd comma's ACTUAL POSITION in the whole address length
    	 */
  FROM Nashville_Housing_Data_for_Data_Cleaning
)
SELECT
  SUBSTR(OwnerAddress, 1, Comma1Pos - 1) AS OwnerStreetAddress, -- extract starts from the 1st character, ends at -1 to omit the ',' 
  SUBSTR(OwnerAddress, Comma1Pos + 2, Comma2Pos - Comma1Pos - 2) AS OwnerCity,
  /* [Comma2Pos - Comma1Pos - 2] finds the length of City between 1st & 2nd comma, the -2 substracts the comma and whitespace */
  SUBSTR(OwnerAddress, Comma2Pos + 2) AS OwnerState -- extract starts from the 2nd comma +2 more
FROM AddressParts;

ALTER TABLE
  Nashville_Housing_Data_for_Data_Cleaning
ADD COLUMN
  OwnerStreetAddress TEXT;
  
ALTER TABLE
  Nashville_Housing_Data_for_Data_Cleaning
ADD COLUMN
  OwnerCity TEXT;

ALTER TABLE
  Nashville_Housing_Data_for_Data_Cleaning
ADD COLUMN
  OwnerState TEXT;

-- Update StreetAddress, City, and State columns
UPDATE 
  Nashville_Housing_Data_for_Data_Cleaning
SET 
  OwnerStreetAddress = SUBSTR(OwnerAddress, 1, instr(OwnerAddress, ',') - 1)

UPDATE 
  Nashville_Housing_Data_for_Data_Cleaning
SET 
  OwnerCity = SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',')+2, (INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') - 1))  
  
UPDATE 
  Nashville_Housing_Data_for_Data_Cleaning
SET 
  OwnerState = SUBSTR(OwnerAddress, (INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') + INSTR(OwnerAddress, ',')+2))

------------------------------------------------------------  
  
-- Change Y and N to Yes and No in "Sold as Vacant" field
  
SELECT 
  DISTINCT(SoldAsVacant),
  COUNT(SoldAsVacant)
FROM
  Nashville_Housing_Data_for_Data_Cleaning  
GROUP BY
  SoldAsVacant
ORDER BY 
  SoldAsVacant 
  
SELECT 
  SoldAsVacant,
  CASE 
  	WHEN SoldAsVacant = 'Y'THEN 'Yes'
  	WHEN SoldAsVacant = 'N' THEN 'No'
  	ELSE SoldAsVacant
  END
FROM
  Nashville_Housing_Data_for_Data_Cleaning
  
UPDATE 
  Nashville_Housing_Data_for_Data_Cleaning 
SET 
  SoldAsVacant = CASE 
  	WHEN SoldAsVacant = 'Y'THEN 'Yes'
  	WHEN SoldAsVacant = 'N' THEN 'No'
  	ELSE SoldAsVacant
  END
  
------------------------------------------------------------  
  
-- Remove Duplicates (Not Standard Practice to remove duplicates/delete data in databases)
  
-- Checking for Duplicates
WITH Row_NumCTE AS(
SELECT
  *,
  ROW_NUMBER() OVER (  -- a window function ROW_NUMBER generates a sequential number starting from 1
  PARTITION BY ParcelID, -- subclause to divide rows into groups
  				PropertyAddress,
  				SalePrice,
  				SaleDate,
  				LegalReference  -- a combination of columns used for finding duplicates
  				ORDER BY
  					"UniqueID ") AS row_num 
FROM
  Nashville_Housing_Data_for_Data_Cleaning 
)
SELECT
  *
FROM 
  Row_NumCTE
WHERE 
  row_num > 1
ORDER BY 
  PropertyAddress
  
/* Delete Duplicates use subquery method to delete duplicates from CTE table 
 * Limitation of SQLite */
WITH Row_NumCTE AS(
SELECT
  ROWID as row_id,
  ROW_NUMBER() OVER (  -- a window function: ROW_NUMBER generates a sequential number starting from 1
  PARTITION BY ParcelID, -- subclause to divide rows into groups
  				PropertyAddress,
  				SalePrice,
  				SaleDate,
  				LegalReference  -- a combination of columns used for finding duplicates
  				ORDER BY
  					"UniqueID ") AS row_num 
FROM
  Nashville_Housing_Data_for_Data_Cleaning 
)
DELETE FROM 
  Nashville_Housing_Data_for_Data_Cleaning
WHERE 
  ROWID IN (
  SELECT
    row_id
  FROM
    Row_NumCTE
  WHERE row_num > 1)  
  
------------------------------------------------------------  
  
/* Delete Unused Columns (Not Standard Practice to execute this and make changes to raw data, 
 * always ask seniors before proceeding) */
  
ALTER TABLE
  Nashville_Housing_Data_for_Data_Cleaning 
DROP COLUMN
  SaleDate,
  PropertyAddress