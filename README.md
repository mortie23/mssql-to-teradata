# mssql-to-teradata
A repo for moving data from MS SQL Server to Teradata using scripts

## Setup

For this setup I installed SQL Server developer edition onto my Windows laptop (Dell XPS).
Also I installed SQL Server Management Studio.

Run the `database-setup.sql` to deploy the two databases that will be used as the source.

```sql
create database PRD_LA_NFL;
create database PRD_SI_NFL;
```

## Load source files

```sh
.\setup-mssql\load-all.ps1 <servername>
# in this case the servername is just the computer name of my XPS
```