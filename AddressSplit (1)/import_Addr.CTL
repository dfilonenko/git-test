LOAD DATA
INFILE 'convert1.csv'
REPLACE
INTO TABLE "IMPORT_CLNT_EXAMPLE_TEMP"
FIELDS TERMINATED BY ';'
TRAILING NULLCOLS
(

comment1, -- flag

--comment2, -- n

id_in_bank, --4

C_P_index,
C_P_region,
C_P_area,
C_P_CITY,
C_P_street

)
