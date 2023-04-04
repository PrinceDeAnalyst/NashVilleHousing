
----Checking Data in SQL Queries

Select *
From [Portfolio Project]..NashvilleHousing

----Standardize Date Format
Select SaleDate, convert(Date, SaleDate) as FixDate
From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add FixDate date;

Update [Portfolio Project]..NashvilleHousing
Set FixDate = convert(Date, SaleDate)

Select SaleDate,  FixDate
From [Portfolio Project]..NashvilleHousing

---Populate Property Address Data

Select *
From [Portfolio Project]..NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select OriginalData.ParcelID, OriginalData.PropertyAddress, ReplicatedData.ParcelID,ReplicatedData.PropertyAddress,
ISNULL(OriginalData.PropertyAddress,ReplicatedData.PropertyAddress)
From [Portfolio Project]..NashvilleHousing OriginalData
Join [Portfolio Project]..NashvilleHousing ReplicatedData
on OriginalData.ParcelID = ReplicatedData.ParcelID
and OriginalData.[UniqueID ]<> ReplicatedData.[UniqueID ]
where OriginalData.PropertyAddress is null

Update OriginalData
Set PropertyAddress = ISNULL(OriginalData.PropertyAddress,ReplicatedData.PropertyAddress)
From [Portfolio Project]..NashvilleHousing OriginalData
Join [Portfolio Project]..NashvilleHousing ReplicatedData
on OriginalData.ParcelID = ReplicatedData.ParcelID
and OriginalData.[UniqueID ]<> ReplicatedData.[UniqueID ]
where OriginalData.PropertyAddress is null


----Breaking Out Address Into Individual Columns (Address, City, State)
Select PropertyAddress
From [Portfolio Project]..NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress),-1) as Address,
SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress), + 1, LEN(PropertyAddress)) as Address

From [Portfolio Project]..NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1 ,  LEN(PropertyAddress)) as Address

From [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)


Alter Table [Portfolio Project]..NashvilleHousing
Add PropertySplitCity nvarchar(255);


Update [Portfolio Project]..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1 ,  LEN(PropertyAddress))





Select *
from [Portfolio Project]..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.') ,3),
PARSENAME(Replace(OwnerAddress,',','.') ,2),
PARSENAME(Replace(OwnerAddress,',','.') ,1)
from [Portfolio Project]..NashvilleHousing
where OwnerAddress is not null

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.') ,3)


Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerSplitCity nvarchar(255);


Update [Portfolio Project]..NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.') ,2)

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerSplitState nvarchar(255);


Update [Portfolio Project]..NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.') ,1)

select *
from [Portfolio Project]..NashvilleHousing


----Change Y and N  To Yes and No in "Sold as Vacant" Field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
,
CASE When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'Yes'
	 Else SoldAsVacant
	 End
from [Portfolio Project]..NashvilleHousing

Update [Portfolio Project]..NashvilleHousing
Set SoldAsVacant =
CASE When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'Yes'
	 Else SoldAsVacant
	 End

----Remove Duplicates
With RowNumCTE As(
Select *,
ROW_NUMBER() OVER (
Partition By ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID )row_num
from [Portfolio Project]..NashvilleHousing
)
Delete
From RowNumCTE
where row_num > 1

----Delete Unused Columns
Select *
from [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


Alter Table [Portfolio Project]..NashvilleHousing
Drop Column SaleDate
