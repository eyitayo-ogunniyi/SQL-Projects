/* Cleaning Data in SQL Queries 
*/

SELECT *
FROM nashville_housing

-- Standardize date format
ALTER TABLE nashville_housing
ADD salesdate date

UPDATE nashville_housing
SET salesdate = CAST(saledate AS date)

SELECT salesdate
FROM nashville_housing;

-- Populate property address
SELECT *
FROM nashville_housing
WHERE propertyaddress IS NULL
ORDER BY parcelid;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,	
	COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing a
JOIN nashville_housing b
	 ON a.parcelid = b.parcelid
	 AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL


UPDATE nashville_housing a
SET propertyaddress = b.propertyaddress 
FROM nashville_housing b
	WHERE a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
	AND a.propertyaddress IS NULL
	
SELECT *
FROM nashville_housing
WHERE propertyaddress IS NULL

-- Breaking property address into individual columns (Address, City)
SELECT propertyaddress
FROM nashville_housing
-- WHERE propertyaddress IS NULL
-- ORDER BY parcelid;

SELECT 
	SUBSTRING(propertyaddress, 1, strpos(propertyaddress, ',')-1) address,
	SUBSTRING(propertyaddress, strpos(propertyaddress, ',')+1, length(propertyaddress)) city
FROM nashville_housing

--  Creating property address and city columns
ALTER TABLE nashville_housing
ADD PropertySplitAddress varchar(50)

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, strpos(propertyaddress, ',')-1)

ALTER TABLE nashville_housing
ADD PropertyCity varchar(50)

UPDATE nashville_housing
SET PropertyCity = SUBSTRING(propertyaddress, strpos(propertyaddress, ',')+1, length(propertyaddress))


-- Breaking owner's address into individual columns (Address, City, State)

SELECT split_part(owneraddress, ',', 1) address,
	split_part(owneraddress, ',', 2) city,
	split_part(owneraddress, ',', 3) state
FROM nashville_housing

ALTER TABLE nashville_housing
ADD OwnerSplitAddress varchar(50)

UPDATE nashville_housing
SET OwnerSplitAddress = split_part(owneraddress, ',', 1)

ALTER TABLE nashville_housing
ADD OwnerCity varchar(50)

UPDATE nashville_housing
SET OwnerCity = split_part(owneraddress, ',', 2)

ALTER TABLE nashville_housing
ADD OwnerState varchar(50)

UPDATE nashville_housing
SET OwnerState = split_part(owneraddress, ',', 3)

-- Changing N and Y to No and Yes in 'Sold as Vacant' field
SELECT distinct soldasvacant, count(*)
FROM nashville_housing
GROUP BY soldasvacant
ORDER BY 2;

SELECT soldasvacant,
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	     WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 END
FROM nashville_housing;

UPDATE nashville_housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	     WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 END;

---- Deleting Unused Columns
ALTER TABLE nashville_housing
DROP COLUMN propertyaddress, 

ALTER TABLE nashville_housing
DROP COLUMN taxdistrict 

ALTER TABLE nashville_housing
DROP COLUMN owneraddress

SELECT *
FROM nashville_housing


--- Remove Duplicates
CREATE TEMP TABLE row_num (
UniqueID int, 	
ParcelID varchar(50),	
LandUse	varchar(50),
SaleDate timestamp,
SalePrice varchar(50),
LegalReference	varchar(50),
SoldAsVacant varchar(50),
OwnerName varchar(100),	
Acreage	float,
LandValue int,	
BuildingValue int,
TotalValue int,
YearBuilt smallint,
Bedrooms smallint,
FullBath smallint,
HalfBath smallint,
SalesDate date,
propertysplitaddress varchar(50),
propertycity varchar(50),
ownersplitaddress varchar(50),
ownercity varchar(50),
ownerstate varchar(50),
rownum int
) 

INSERT INTO row_num
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY parcelid, salesdate, saleprice, propertysplitaddress, legalreference
		ORDER BY uniqueid) RowNum
FROM nashville_housing
ORDER BY parcelid
	
DELETE 
FROM row_num
WHERE rownum > 1;

SELECT parcelid, salesdate, saleprice, propertysplitaddress, legalreference
FROM row_num
GROUP BY parcelid, salesdate, saleprice, propertysplitaddress, legalreference
HAVING count(*) > 1;
