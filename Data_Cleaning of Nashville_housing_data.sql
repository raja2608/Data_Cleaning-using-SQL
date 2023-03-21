--DATA CLEANING OF A DATASET THAT HAS THE HOUSEHOLD RECORDS OF A CITY 'NASHVILLE' IN THE UNITED STATES.

--NASHVILLE IS A CITY IN US THAT HAS 3% LOWER COST OF LIVING AND 9% LOWER HOUSING PRICES THAN THE NATIONAL PRICES.

--THE DATA IS IN .XLSX FORMAT AND IT IS IMPORTED USING THE SSMS IMPORT AND EXPORT TOOL-2019.

--FIXING OF SALESDATE COLUMN

SELECT SaleDate,CONVERT(date,SaleDate) Date_fixed
FROM Data_Cleaning..Nashville_Housing_Data
order by SaleDate

--Altering the table column 'saledate'

ALTER TABLE [dbo].[Nashville_Housing_Data]
ALTER COLUMN SALEDATE DATE

--After executing the above query the saledate column that didn't have any time mentioned has been removed and the saledate column is now only a 'date' format rather then 'datetime'.


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--POPULATING THE NULL PROPERTY ADDRESS HAVING DIFFERENT UNIQUE_ID BASED ON SAME PARCEL_ID

Select nash.ParcelID,nash.PropertyAddress,ville.ParcelID,ville.PropertyAddress
from Data_Cleaning..Nashville_Housing_Data nash
join Data_Cleaning..Nashville_Housing_Data ville
	on nash.[UniqueID ]!=ville.[UniqueID ]
	where nash.PropertyAddress is null

--updating the column property address

update nash
set PropertyAddress=ISNULL(nash.PropertyAddress,ville.PropertyAddress)
from Data_Cleaning..Nashville_Housing_Data nash
join Data_Cleaning..Nashville_Housing_Data ville
	on nash.[UniqueID ]!=ville.[UniqueID ]
	where nash.PropertyAddress is null

--After execution of the above query the property address column having the null values have been refilled based on their parcel_id.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Fixing the OwnerAddress column

Select OwnerAddress
from Data_Cleaning..Nashville_Housing_Data

Select OwnerAddress,rtrim(owneraddress) trimmed
from Data_Cleaning..Nashville_Housing_Data

--------------------------------------------------------------------------------------------------------------------------------------------

--Breaking OwnerAddress column into individual columns as (address, city, state)

Select 
OwnerAddress,
SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) as Address,
SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,len(owneraddress)) as CITY 
from Data_Cleaning..Nashville_Housing_Data

Alter table Data_Cleaning..Nashville_Housing_Data
add Address nvarchar(255),City nvarchar(255)

update Data_Cleaning..Nashville_Housing_Data
set address=SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1),City=SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,len(owneraddress))
--------------------------------------------------------------------------------------------------------------------------------------------
--Breaking PropertyAddress column into individual columns as (Address, city)

SELECT 
PROPERTYADDRESS,
PARSENAME(REPLACE(PropertyAddress,',','.'),2) AS ADDRESS ,
PARSENAME(REPLACE(PropertyAddress,',','.'),1) AS CITY
from Data_Cleaning..Nashville_Housing_Data

---------------------------------------------------------------------------------------------------------------------------------------------
--Changing 'Y' to 'Yes' & 'N' to 'No' in the SoldAsVacant Column

Select SoldAsVacant,
	Case 
		when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
	End as Soldasvacantnew
from Data_Cleaning..Nashville_Housing_Data

Update Nashville_Housing_Data
set SoldAsVacant=
	Case 
		when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
	End  
	
----------------------------------------------------------------------------------------------------------------------------------------------
--REMOVING DUPLICATE VALUES

WITH ROWNUM_CTE AS
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY PARCELID,PROPERTYADDRESS,SALEPRICE,LEGALREFERENCE,SALEDATE
	ORDER BY UNIQUEID
	) Row_num
from Data_Cleaning..Nashville_Housing_Data
)
select *
from ROWNUM_CTE
where Row_num >1
order by PropertyAddress


WITH ROWNUM_CTE AS
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY PARCELID,PROPERTYADDRESS,SALEPRICE,LEGALREFERENCE,SALEDATE
	ORDER BY UNIQUEID
	) Row_num
from Data_Cleaning..Nashville_Housing_Data
)
delete
from ROWNUM_CTE
where Row_num >1

---------------------------------------------------------------------------------------------------------------------------------------------
--Deleting columns

Alter table Data_Cleaning..Nashville_Housing_Data
drop column OwnerAddress

----------------------------------------------------------------------------------------------------------------------------------------------
--DELETING ENTRY HAVING CITY AS 'BELLEVUE'

DELETE FROM Data_Cleaning..Nashville_Housing_Data
WHERE City LIKE '%BELLEVUE%'

----------------------------------------------------------------------------------------------------------------------------------------------