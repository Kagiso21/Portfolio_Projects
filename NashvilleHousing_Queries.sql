-- Cleaning data SQL Queries

--Standerdising Sales Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Covid Portfolio Project]..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Replace NULL values in Property Address Field

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Covid Portfolio Project]..NashvilleHousing a
JOIN [Covid Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Covid Portfolio Project]..NashvilleHousing a
JOIN [Covid Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
--No Output as Null values have been populated

-- Splitting Address into individual values

Select PropertyAddress
From [Covid Portfolio Project]..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN (PropertyAddress)) as Address
From [Covid Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyAddressSplit Nvarchar(255)

Update NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN (PropertyAddress))

Select *
From [Covid Portfolio Project]..NashvilleHousing

-- To split Owner Address column
Select OwnerAddress
From [Covid Portfolio Project]..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From [Covid Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerAddressSplit Nvarchar(255);

Update NashvilleHousing
SET OwnerAddressSplit = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From [Covid Portfolio Project]..NashvilleHousing

--completing Y & N to Yes & No in Sold As Vacant Field

Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From [Covid Portfolio Project]..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

Select SoldAsVacant
From [Covid Portfolio Project]..NashvilleHousing
Where SoldAsVacant = 'Y'
OR SoldAsVacant = 'N'

--Removing Duplicate Values whith CTE creation

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY PropertyAddress,
				SalePrice,
				ParcelID,
				LegalReference,
				SaleDate
				ORDER BY 
					UniqueID
					) row_num
From [Covid Portfolio Project]..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress 

-- Remove Unused Columns which have been cleaned/split

Select *
From [Covid Portfolio Project]..NashvilleHousing

ALTER TABLE [Covid Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate