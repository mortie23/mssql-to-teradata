#!/drives/c/Python38/python
# Author: Christopher Mortimer
# Date:   2020-08-26
# Desc:   A script to generate the DDL for the staging tables and the views
#         The output may need some manual modications but this is a starter
# Usage:  Run from local session from the root repo directory
#         ./function-lib/ddl-generate.py

import pandas as pd
import os
from time import gmtime, strftime


def datatype(dtype, dlength, dprecision, dscale):
  '''
    Data type MS-SQL to Teradata converstions
    Parameters
      @dtype: MS SQL type
      @dlength: MS Sql length
      @dprecision: MS SQL prescision
      @dscale: MS SQL Scale
    Return
      datatype for Teradata
  '''
  if dtype in ['varchar', 'nvarchar']:
    return 'varchar' + '(' + str(int(dlength)) + ')'
  elif dtype == 'datetime':
    return 'timestamp'
  elif dtype == 'decimal':
    return 'decimal(' + str(int(dprecision)) + ',' + str(int(dscale)) + ')'
  elif dtype == 'numeric':
    return 'numeric(' + str(int(dprecision)) + ',' + str(int(dscale)) + ')'
  else:
    return dtype


def datatypeStaging(dtype, dlength):
  '''
    Data type for Teradata staging table is all varchar of different lengths
    Parameters
      @dtype: MS SQL type
      @dlength: MS SQL length
    Return
      datatype for Tetadata Staging
  '''
  if dtype in ['varchar', 'nvarchar']:
    return 'varchar' + '(' + str(int(dlength)) + ')'
  elif dtype == 'int':
    return 'varchar(16)'
  else:
    return 'varchar(100)'

def colNameProc(dtype, colName):
  '''
    Hack function if extra processing is required in the view layer
    Column names are shortened
    Parameters
      @dtype: MS SQL Data type
      @colName: MS SQL column name
    Return
      Teradata column name
  '''
  if dtype == 'datetime':
    return 'substr(' + colName + ',1,20)'
  elif dtype == 'date':
    return 'substr(' + colName + ',1,10)'
  elif dtype in ['int', 'numeric']:
    return 'nullif(' + colName + ",'')"
  else:
    return colName

def createViewDDL(ext):
  '''
    Create a staging to source image view
    Parmeters
      @ext: name of extract
  '''
  # Read the CSV that defines the table structure for the MS SQL table
  filePathView = "./ddl/" + ext + '_V.sql'
  if os.path.exists(filePathView):
    os.remove(filePathView)
  else:
    print("Can not delete the file as it doesn't exists")
  view = pd.read_csv('./extract/ddl_' + ext + '.csv')
  viewFile = open(filePathView , "a+")
  viewFile.write("-- Author: Automagic\n")
  viewFile.write("-- Date:   " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + "\n")
  viewFile.write("-- Desc:   Table definition for " + ext + "\n\n")
  viewFile.write('REPLACE VIEW PRD_ADS_NFL_DB.' + ext + '_V AS')
  viewFile.write('\nSELECT')
  # Loop through all the columns
  for index, row in view.iterrows():
    # On first row set this as the primary index
    if row['ORDINAL_POSITION'] ==1:
      viewLine = '\n  TRYCAST(' + colNameProc(row['DATA_TYPE'],row['COLUMN_NAME']) + ' AS ' + datatype(row['DATA_TYPE'],row['CHARACTER_MAXIMUM_LENGTH'],row['NUMERIC_PRECISION'],row['NUMERIC_SCALE']) + ') AS ' + row['COLUMN_NAME']
      viewFile.write(viewLine)
    else:
      viewLine = '\n  , TRYCAST(' + colNameProc(row['DATA_TYPE'],row['COLUMN_NAME']) + ' AS ' + datatype(row['DATA_TYPE'],row['CHARACTER_MAXIMUM_LENGTH'],row['NUMERIC_PRECISION'],row['NUMERIC_SCALE']) + ') AS ' + row['COLUMN_NAME']
      viewFile.write(viewLine)
  # Finish off the file
  viewFile.write('\n  , CURRENT_USER AS EXTRACT_USER')
  viewFile.write('\n  , CURRENT_TIMESTAMP AS EXTRACT_TIMESTAMP')
  viewLine = '\nFROM\n  PRD_ADS_NFL_DB.' + ext + '\n;\n'
  viewFile.write(viewLine)

def createStgDDL(ext):
  '''
    Create a staging table
    Parmeters
      @ext: name of extract
  '''
  # Read the CSV of the DDL
  filePath = "./ddl/" + ext + '_STG.sql'
  if os.path.exists(filePath):
    os.remove(filePath)
  else:
    print("Can not delete the file as it doesn't exists")
  ddl = pd.read_csv('./extract/ddl_' + ext + '.csv')
  ddlFile = open(filePath , "a+")
  ddlFile.write("-- Author: Automagic\n")
  ddlFile.write("-- Date:   " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + "\n")
  ddlFile.write("-- Desc:   Table definition for " + ext + "\n\n")
  ddlFile.write('DROP TABLE PRD_ADS_NFL_DB.' + ext + ';\n')
  ddlFile.write('CREATE TABLE PRD_ADS_NFL_DB.' + ext + ' (')
  # Loop through all the columns
  for index, row in ddl.iterrows():
    # On first row set this as the primary index
    if row['ORDINAL_POSITION'] ==1:
      primaryIndex = row['COLUMN_NAME'] 
      ddlLine = '\n  ' + row['COLUMN_NAME'] + ' ' + datatypeStaging(row['DATA_TYPE'],row['CHARACTER_MAXIMUM_LENGTH'])
      ddlFile.write(ddlLine)
    else:
      ddlLine = '\n  , ' + row['COLUMN_NAME'] + ' ' + datatypeStaging(row['DATA_TYPE'],row['CHARACTER_MAXIMUM_LENGTH']) 
      ddlFile.write(ddlLine)
  # Finish off the file
  ddlLine = '\n)\nPRIMARY INDEX (' + primaryIndex + ')\n;\n'
  ddlFile.write(ddlLine)
  createViewDDL(ext)

def createSrcDDL(ext):
  '''
    Create the source image table
    Parmeters
      @ext: name of extract
  '''
  # Read the CSV of the DDL
  filePath = "./ddl/" + ext + '_SRC.sql'
  if os.path.exists(filePath):
    os.remove(filePath)
  else:
    print("Can not delete the file as it doesn't exists")
  ddl = pd.read_csv('./extract/ddl_' + ext + '.csv')
  ddlFile = open(filePath , "a+")
  ddlFile.write("-- Author: Automagic\n")
  ddlFile.write("-- Date:   " + strftime("%Y-%m-%d %H:%M:%S", gmtime()) + "\n")
  ddlFile.write("-- Desc:   Table definition for " + ext + "\n\n")
  ddlFile.write('DROP TABLE EDW_PRD_ADS_HWD_AGPT_SRC_DB.' + ext + ';\n')
  ddlFile.write('CREATE TABLE EDW_PRD_ADS_HWD_AGPT_SRC_DB.' + ext + ' (')
  # Loop through all the columns
  for index, row in ddl.iterrows():
    # On first row set this as the primary index
    if row['ORDINAL_POSITION'] ==1:
      primaryIndex = row['COLUMN_NAME'] 
      ddlLine = '\n  ' + row['COLUMN_NAME'] + ' ' + datatype(row['DATA_TYPE'],row['CHARACTER_MAXIMUM_LENGTH'],row['NUMERIC_PRECISION'],row['NUMERIC_SCALE'])
      ddlFile.write(ddlLine)
    else:
      ddlLine = '\n  , ' + row['COLUMN_NAME'] + ' ' + datatype(row['DATA_TYPE'],row['CHARACTER_MAXIMUM_LENGTH'],row['NUMERIC_PRECISION'],row['NUMERIC_SCALE'])
      ddlFile.write(ddlLine)
  # Finish off the file
  ddlFile.write('\n  , EXTRACT_USER VARCHAR(11)')
  ddlFile.write('\n  , EXTRACT_TIMESTAMP TIMESTAMP')
  ddlLine = '\n)\nPRIMARY INDEX (' + primaryIndex + ')\n;\n'
  ddlFile.write(ddlLine)

def createDDL(ext):
  '''
    Create all the Teradata structures required 
    Parameters
      @ext: name of extract
  '''
  createStgDDL(ext)
  createSrcDDL(ext)
  createViewDDL(ext)

# Run for all extracts
createDDL('nfl_extracts')
createDDL('nfl_extracts')
createDDL('nfl_extracts')
createDDL('nfl_extracts')
createDDL('nfl_extracts')