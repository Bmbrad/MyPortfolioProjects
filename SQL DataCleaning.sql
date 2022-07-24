SELECT*
FROM DBO.NashvilleHousingData

--Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM DBO.NashvilleHousingData

UPDATE dbo.NashvilleHousingData         
SET SaleDate = CONVERT(Date, SaleDate)  

--ALTER TABLE DBO.NashvilleHousingData

SELECT SaleDate
FROM DBO.NashvilleHousingData

SELECT *
FROM dbo.NashvilleHousingData

--Populate Property Address Data

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousingData
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousingData a
JOIN dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousingData a
JOIN dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--SELECT ROW_NUMBER() OVER (ORDER BY UniqueID) ROW_NUM,ParcelID
--FROM dbo.NashvilleHousingData

SELECT TOP 161 *
FROM dbo.NashvilleHousingData

-- Breaking PropertyAddress Column into Address, City, State

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM dbo.NashvilleHousingData

ALTER TABLE dbo.NashvilleHousingData
ADD PropertyAddressSplitAddress NVARCHAR(255);

UPDATE dbo.NashvilleHousingData
SET PropertyAddressSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 

ALTER TABLE dbo.NashvilleHousingData
ADD PropertyAddressSplitCity NVARCHAR(255);

UPDATE dbo.NashvilleHousingData
SET PropertyAddressSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM dbo.NashvilleHousingData



SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM dbo.NashvilleHousingData

ALTER TABLE dbo.NashvilleHousingData
ADD OwnerAddressSplitAddress NVARCHAR(255);

UPDATE dbo.NashvilleHousingData
SET OwnerAddressSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3) 

ALTER TABLE dbo.NashvilleHousingData
ADD OwnerAddressSplitCity NVARCHAR(255);

UPDATE dbo.NashvilleHousingData
SET OwnerAddressSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE dbo.NashvilleHousingData
ADD OwnerAddressSplitState NVARCHAR(255);

UPDATE dbo.NashvilleHousingData
SET OwnerAddressSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT TOP 50 *
FROM dbo.NashvilleHousingData

---Change N to No and Y to Yes in SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM dbo.NashvilleHousingData

ALTER TABLE dbo.NashvilleHousingData
ADD OwnerAddressSplitState NVARCHAR(255);

UPDATE dbo.NashvilleHousingData
SET OwnerAddressSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


UPDATE dbo.NashvilleHousingData
SET SoldAsVacant = CASE 
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

SELECT TOP 50 *
FROM dbo.NashvilleHousingData

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2


--------Remove Duplicates ----------------

-- Partition data into duplicate rows
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM dbo.NashvilleHousingData
ORDER BY ParcelID)

--Query duplicate rows

WITH CTE_Dem AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM dbo.NashvilleHousingData
)
SELECT *
FROM CTE_Dem
WHERE row_num > 1

-- Delete duplicate rows

WITH CTE_Dem AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM dbo.NashvilleHousingData
)
DELETE
FROM CTE_Dem
WHERE row_num > 1

------------------ Delete Unused Columns ---------------------

ALTER TABLE dbo.NashvilleHousingData
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

SELECT *
FROM dbo.NashvilleHousingData

------------------------------------- TO CHECK COUMNS IN A TABLE ----------------------------------

select COLUMN_NAME, COUNT(COLUMN_NAME) Total_Col
from information_schema.columns 
where table_name = 'NashvilleHousingData'
GROUP BY COLUMN_NAME