# mssql-to-teradata
A repo for moving data from MS SQL Server to Teradata using scripts

## Setup

For this setup I installed SQL Server developer edition onto my Windows laptop (Dell XPS).
Also I installed SQL Server Management Studio.

Run the `database-setup.sql` to deploy the two databases that will be used as the source.

## Load source files

```sh
.\setup-mssql\load-all.ps1 <servername>
# in this case the servername is just the computer name of my XPS
```

These source files are loaded to the database to simply resemble a source database.

## Extract the source data to files

```sh
.\extract.ps1 
```
## Load the extracts to Teradata

```sh
.\load.ps1 
```