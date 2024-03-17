# Nashville Housing Data Cleaning Project

## Overview

This project focuses on cleaning and preprocessing a housing dataset sourced from Nashville. The dataset contained various issues such as inconsistent date formats, missing values, and non-standardized address fields. Using Microsoft SQL Server, advanced SQL queries were employed to clean the dataset and prepare it for further analysis.

## Table of Contents

- [Dataset](#dataset)
- [Cleaning Process](#cleaning-process)
- [SQL Queries](#sql-queries)
- [Results](#results)
- [Conclusion](#conclusion)

## Dataset

The dataset, named "Nashville Housing," contains information on property sales in Nashville. It includes fields such as SaleDate, PropertyAddress, OwnerAddress, SoldAsVacant, SalePrice, LegalReference, and more.

## Cleaning Process

The cleaning process involved several steps to address various issues within the dataset:

1. **Fixing Date Format**: The SaleDate field was standardized to a DATE format for consistency.

2. **Populating Empty Cells in Property Address**: Empty PropertyAddress fields were populated by matching ParcelID with other entries having the same ParcelID but different UniqueID.

3. **Dividing Address into Individual Columns**: The full address was split into separate columns for PropertyStreetAddress, PropertyCity, OwnerStreetAddress, OwnerCity, and OwnerState for better organization.

4. **Changing Y and N to Yes and No**: The SoldAsVacant field was standardized by replacing 'Y' with 'Yes' and 'N' with 'No'.

5. **Removing Duplicates**: Duplicate entries were removed based on unique combinations of ParcelID, SalePrice, SaleDate, and LegalReference.

## SQL Queries

Below are the SQL queries used to perform the cleaning tasks:

- [Query 1: Fixing Date Format](#query-1-fixing-date-format)
- [Query 2: Populating Empty Cells in Property Address](#query-2-populating-empty-cells-in-property-address)
- [Query 3: Dividing Address into Individual Columns](#query-3-dividing-address-into-individual-columns)
- [Query 4: Changing Y and N to Yes and No](#query-4-changing-y-and-n-to-yes-and-no)
- [Query 5: Removing Duplicate Rows](#query-5-removing-duplicate-rows)

### Query 1: Fixing Date Format

```sql
ALTER TABLE NashvilleHousing
ADD NewSaleDate DATE;

UPDATE NashvilleHousing
SET NewSaleDate = CONVERT(DATE, SaleDate);

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

EXEC sp_rename 'NashvilleHousing.NewSaleDate', 'SaleDate', 'COLUMN';
```

### Query 2: Populating Empty Cells in Property Address
```sql
UPDATE T1
SET PropertyAddress = ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM NashvilleHousing T1
JOIN NashvilleHousing T2
	ON T1.ParcelID = T2.ParcelID
	AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL;
```
### Query 3: Dividing Address into Individual Columns
#### Fixing Property Address (Used SUBSTRING and CHARINDEX):
```sql
ALTER TABLE NashvilleHousing
ADD PropertyStreetAddress NVARCHAR(255),
	PropertyCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ),
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));
```
#### Fixing Owner Address (Used PARSENAME and REPLACE):
```sql
ALTER TABLE NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255),
	OwnerCity NVARCHAR(255),
	OwnerState NVARCHAR(255)

Update NashvilleHousing	
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress;
```

### Query 4: Changing Y and N to Yes and No
```sql
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
```

### Query 5: Removing Duplicate Rows
```sql
WITH CTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleHousing
)
DELETE
From CTE
Where row_num > 1;
```
## Results

The dataset was successfully cleaned and standardized, resolving issues related to date formats, empty values, non-standardized addresses, and inconsistent data in the SoldAsVacant field. The final dataset is now ready for further analysis and modeling.

## Conclusion

This project demonstrates the application of advanced SQL queries in data cleaning tasks, specifically focusing on housing data from Nashville. By addressing various data quality issues, the cleaned dataset provides a solid foundation for conducting meaningful analysis and deriving valuable insights.
