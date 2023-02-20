--Data Cleaning
use portfolioProject
select * from NashvilleHousing

--Standardize Date Format
select SaleDate --, CONVERT (date,SaleDate)
from NashvilleHousing

Update NashvilleHousing
SET SaleDateConverted = CONVERT (date,SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

--Populate property address data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelID = b.ParcelID AND a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelID = b.ParcelID AND a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

--Breaking out address into individual columns (Address, City, State)

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from NashvilleHousing


ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255)
Update NashvilleHousing
SET PropertySplitAddress  = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)



ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(255)
Update NashvilleHousing
SET PropertySplitCity  = substring(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

select * from NashvilleHousing

--Breaking out ownerAddress

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255)
Update NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(255)
Update NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255)
Update NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--Change Y and N to Yes and No in SoldAsVacant' fiels
select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--Remove duplicates
WITH RowNumCTE AS (
select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			 UniqueID) row_num
from NashvilleHousing )


DELETE
from RowNumCTE
where row_num >1


--Delete unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

select * from NashvilleHousing
