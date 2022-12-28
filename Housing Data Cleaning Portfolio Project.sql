/*

CLEANING HOUSING DATA WITH SQL QUERIES 

*/

SELECT *
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format


--Change dat e format using CONVERT function
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]


--Alter and Update table
ALTER TABLE [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
Add SaleDateConverted Date;
Update [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
SET SaleDateConverted = CONVERT(Date,SaleDate) 




-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data



--Find null values in Property Address column
SELECT PropertyAddress
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
WHERE PropertyAddress is null



-- Try to look for similar values in the data to replace null values. Use Parcel ID column to verify missing Property Addresses
SELECT *
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
order by ParcelID


--First join data with itself to query out Parcel ID with corresponding missing Property Address data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data] a
JOIN [Data Cleaning Portfolio Projects].[dbo].[Housing_Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Then Update and populate missing Property Adresses 
Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data] a
JOIN [Data Cleaning Portfolio Projects].[dbo].[Housing_Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out the Address column into individual columns (Address, City)




SELECT PropertyAddress
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]


--Seperate the strings in the column using SUBSRING and CHARINDEX functions
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]



--Update table with new split columns
ALTER TABLE [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
Add PropertySplitAdresss NVARCHAR(255);
Update [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
SET PropertySplitAdresss = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


--Update Table
ALTER TABLE [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
Add PropertySplitCity NVARCHAR(255);
Update [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Confirm Changes
SELECT *
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]




--OR

--Use a different method to seperate the columns


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out the Owner Address column into individual columns (Address, City, State)




SELECT OwnerAddress
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]



--Use PARSENAME function to seperate the columns
SELECT
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]




--Update table with new columns
ALTER TABLE [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
Add OwnerSplitAdresss NVARCHAR(255);
Update [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
SET OwnerSplitAdresss = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
Add OwnerSplitCity NVARCHAR(255);
Update [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
Add OwnerSplitState NVARCHAR(255);
Update [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)



--Confirm Changes
SELECT *
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in Sold as Vacant column




--check distnct values in column
SELECT DISTINCT (soldAsVacant), COUNT(soldAsVacant)
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
Group by SoldAsVacant
order by 2


--Standardize values
SELECT soldAsVacant, 
	CASE WHEN soldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]


--Update table
Update [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
SET SoldAsVacant = CASE WHEN soldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END



-----------------------------------------------------------------------------------------------------------------------------------------------------
--Remove duplicates (not standard practice to delete data unless necessary)




--Check data for multiple data point matches in multiple rows with ROW_NUMBER function and a temporary table. 
--Delete duplicates if any
WITH Row_NumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				   UniqueID
				   ) Row_Num
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
)
DELETE
FROM Row_NumCTE
WHERE Row_Num > 1


--Verify deletion of duplicates
SELECT
FROM Row_NumCTE
WHERE Row_Num > 1
order by PropertyAddress



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns



SELECT *
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]


-- Delete columns
ALTER TABLE [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]
DROP COLUMN SaleDate


--Check final clean data
SELECT *
FROM [Data Cleaning Portfolio Projects].[dbo].[Housing_Data]



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--This concludes the data cleaning exercise. Feed back for improvement is welcome. Thank you!!









