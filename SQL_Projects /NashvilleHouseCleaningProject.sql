/* 
Data Cleaning Project In SQL
*/


SELECT *
FROM NashvilleHouseProject..HouseData

--------------------------------------------------------------------------------

-- Standardizing Date Format
-- The sale dates all had 00:00:00.000 as a time
-- Want to remove that and just include year-month-day
-- Will change the data type to a DATE format to fix the issue

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHouseProject..HouseData

ALTER TABLE HouseData
ALTER Column SaleDate DATE

SELECT SaleDate
FROM HouseData

------------------------------------------------------------------------------------------------------------------------

-- Filling in NULL PropertyAddress Values
-- I noticed that when ParcellID repeats, the address is the same
-- Used UPDATE and JOIN to fill in the NULL PropertyAddress with the address in its matching ParcellID row

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouseProject..HouseData a
JOIN NashvilleHouseProject..HouseData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouseProject..HouseData a
JOIN NashvilleHouseProject..HouseData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------

-- Breaking PropertyAddress into individual columns (Address, City)

SELECT PropertyAddress
FROM NashvilleHouseProject.dbo.HouseData

-- After running, we see that each address has a comma and then the city after
-- Will use SUBSTRING and CHARINDEX to make two new columns with Address and City split

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHouseProject.dbo.HouseData

-- Updating the HouseData table to have 2 separate columns of Address and City
-- Using query from above to help make the columns

ALTER TABLE HouseData
ADD PropertySplitAddress nvarchar(255);

UPDATE HouseData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE HouseData
ADD PropertySplitCity nvarchar(255);

UPDATE HouseData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Looking at table to make sure everything updated correctly

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM NashvilleHouseProject..HouseData

-------------------------------------------------------------------------------------------------------------------------

-- Similar idea, but now splitting OwnerAddress into Address, City, State
-- First replacing commas (',') with periods ('.') in order to use PARSENAME

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHouseProject..HouseData

ALTER TABLE HouseData
ADD OwnerSplitAddress nvarchar(255);

UPDATE HouseData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE HouseData
ADD OwnerSplitCity nvarchar(255);

UPDATE HouseData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE HouseData
ADD OwnerSplitState nvarchar(255);

UPDATE HouseData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Checking to make sure everything updated correctly
																																																																																																																																																																																																											
SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHouseProject..HouseData

------------------------------------------------------------------------------------

-- Changing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant column

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHouseProject.dbo.HouseData

-- There are Y, N, Yes, and No entrees into the column
-- Want to convert all to either yes or no to keep data consistent

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHouseProject..HouseData
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'

-- Statement worked so now need to update the column

UPDATE HouseData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Checking to make sure everything updated to only yes and no

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHouseProject.dbo.HouseData

---------------------------------------------------------------------------------------

-- Remove Duplicates
-- Used CTE to make a column called row number that counted duplicates
-- Then selected all with duplicates, changed SELECT* to DELETE
-- Changed back to SELECT* to make sure all were deleted

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM NashvilleHouseProject.dbo.HouseData
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-------------------------------------------------------------------------------------------------------

-- Delting unused columns

SELECT *
FROM NashvilleHouseProject..HouseData

ALTER TABLE NashvilleHouseProject..HouseData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress























































































