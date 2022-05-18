/*

Cleaning Data with SQL Queires

*/
------------------------------------------------------------------------
select * from my_project..NashvilleHousing
--- Standardize the Data Formate

ALTER TABLE my_project..NashvilleHousing
Add SaleDateConverted DATE;

Update my_project..NashvilleHousing
SET SaleDateConverted = CONVERT( DATE, SaleDate)


-------------------------------------------------------------------------

--- Populate Property Address Data

SELECT PropertyAddress
FROM my_project..NashvilleHousing

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From my_project..NashvilleHousing a
JOIN my_project..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL
order by a.[UniqueID ]

Update a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress) 
From my_project..NashvilleHousing a
JOIN my_project..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-----------------------------------------------------------------------------

-- Beaking Out The Address Into Individual Column(Address, City , State)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City 
FROM my_project..NashvilleHousing

ALTER TABLE my_project..NashvilleHousing
ADD Property_Split_Address Nvarchar(255);

Update my_project..NashvilleHousing
SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE my_project..NashvilleHousing
ADD Property_Split_City Nvarchar(255);

UPDATE my_project..NashvilleHousing
SET Property_Split_City = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

--Spliting Owers Address

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM my_project..NashvilleHousing

ALTER TABLE my_project..NashvilleHousing
ADD Owner_Split_Address Nvarchar(255);

Update my_project..NashvilleHousing
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE my_project..NashvilleHousing
ADD Owner_Split_City Nvarchar(255);

Update my_project..NashvilleHousing
SET Owner_Split_City =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE my_project..NashvilleHousing
ADD Owner_Split_State Nvarchar(255);

Update my_project..NashvilleHousing
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)





---------------------------------------------------------------------------

--- Change Y and N to Yes and No in " Sold  as Vacant" Field	

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From my_project..NashvilleHousing
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
     WHEN SoldAsVacant= 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM my_project..NashvilleHousing

UPDATE my_project..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
                        WHEN SoldAsVacant= 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END
	               FROM my_project..NashvilleHousing

select Distinct(SoldAsVacant), Count(SoldAsVacant)
From my_project..NashvilleHousing
group by SoldAsVacant

---------------------------------------------------------------------

-- Removes Duplicates 
WITH Row_NUMB_CTE AS(
SELECT *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID
					 ) row_numb
From my_project..NashvilleHousing
--Order by ParcelID
)
DELETE 
From Row_NUMB_CTE
WHERE row_numb > 1



-------------------------------------------------------------------

--Deleting Unused Columns

select * 
from my_project..NashvilleHousing

ALTER TABLE my_project..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict