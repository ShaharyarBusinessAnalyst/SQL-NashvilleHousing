
-- standardized date
select SaleDateConverted, CONVERT(Date,SaleDate)
From PorfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate property address data (currently NULL values)
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress,b.propertyAddress) 
From PorfolioProject.dbo.NashvilleHousing a
JOIN PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.propertyAddress,b.propertyAddress)
From PorfolioProject.dbo.NashvilleHousing a
Join PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is not null


-- Breaking out Address into individual columns (Address, City, State)
Select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyAddress)) as Address2
FROM PorfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress varchar(250);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity varchar(250);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyAddress))


-- change Y and N to Yes/No in "Sold as Vacant" field

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From PorfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
		END


-- Remove Duplicates

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

From PorfolioProject.dbo.NashvilleHousing

)

Delete
From RowNumCTE
WHERE row_num > 1
;


-- delete unused columns

select *
FROM PorfolioProject.dbo.NashvilleHousing

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN SalesDate