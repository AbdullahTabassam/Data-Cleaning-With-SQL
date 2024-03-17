--Data Cleaning Project in SQL:
--Dataset: Nashville Housing Data


SELECT *
FROM NashvilleHousing.dbo.NashvilleHousing


-----------------------------------------------------
-- Fixing Date Format:

ALTER TABLE NashvilleHousing											-- Add a new Column
ADD NewSaleDate DATE;

UPDATE NashvilleHousing													-- Populate the new column with the updated sales date
SET NewSaleDate = CONVERT(DATE,SaleDate);

ALTER TABLE NashvilleHousing											-- Drop Original date column
DROP COLUMN SaleDate;

EXEC sp_rename 'NashvilleHousing.NewSaleDate', 'SaleDate', 'COLUMN';	-- Rename the new column as the original column name

SELECT SaleDate															-- Check if the changes have been made
FROM NashvilleHousing..NashvilleHousing;

------------------------------------------------------
-- Populating empty cells in Property Address:

UPDATE T1																-- Update the Property Address where the property has different Unique ID
SET PropertyAddress = ISNULL(T1.PropertyAddress,T2.PropertyAddress)		-- but same Parcel ID as another Unique ID
FROM NashvilleHousing.dbo.NashvilleHousing T1
JOIN NashvilleHousing.dbo.NashvilleHousing T2							-- i.e. same parcel id but different unique ids properies have same address
	ON T1.ParcelID = T2.ParcelID
	AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL


SELECT PropertyAddress													-- Check the changes made. This should return an empty table.
FROM NashvilleHousing.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

-----------------------------------------------------
-- Dividing Address into Individual Columns (Address, City, State)

SELECT PropertyAddress													-- Addresses and cities are separated by comma
FROM NashvilleHousing.dbo.NashvilleHousing

-- Fixing Property Address (Used SUBSTRING and CHARINDEX):

ALTER TABLE NashvilleHousing											-- Add new columns for City and Street address for the properties
ADD PropertyStreetAddress NVARCHAR(255),
	PropertyCity NVARCHAR(255);

UPDATE NashvilleHousing													-- Populate the columns by dividing full address using SUBSTRING and CHARINDEX
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

-- Fixing Owner Address (Used PARSENAME and REPLACE):

ALTER TABLE NashvilleHousing											-- Add new columns for City, Street, and State address for the owner
ADD OwnerStreetAddress NVARCHAR(255),
	OwnerCity NVARCHAR(255),
	OwnerState NVARCHAR(255)

Update NashvilleHousing													-- Populate the columns by dividing full address using PARSENAME and REPLACE
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

ALTER TABLE NashvilleHousing											-- Drop old columns
DROP COLUMN PropertyAddress, OwnerAddress;

SELECT *																-- Check for changes
FROM NashvilleHousing.dbo.NashvilleHousing

-----------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Update NashvilleHousing													-- Update 'Y' to 'Yes' and 'N' to 'No'
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)						-- Check for changes
From NashvilleHousing.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

-----------------------------------------------------
-- Remove Duplicates

WITH CTE AS(															-- Created a CTE to get the row number where ParcelID, SalePrice, SaleDate, 
Select *,																-- and LegalReference are same.
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleHousing.dbo.NashvilleHousing
)
DELETE																	-- Delete the rows where row number is more than 1.
From CTE
Where row_num > 1
-----------------------------------------------------

Select *
From NashvilleHousing.dbo.NashvilleHousing
