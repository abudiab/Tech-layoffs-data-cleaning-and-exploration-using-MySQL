# Tech layoffs data cleaning and data exploration using MySQL
Tech layoffs dataset from COVID 2019 to 2023

------

Step 1: Setup the environment

1. Install and setup MySQL workbench.
2. Download the dataset: 
[https://www.kaggle.com/datasets/swaptr/layoffs-2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
[https://drive.google.com/file/d/12mIcynhjBajGj9zvRNx1HcsKOAVXLwGs/view?usp=sharing](https://drive.google.com/file/d/12mIcynhjBajGj9zvRNx1HcsKOAVXLwGs/view?usp=sharing)

Step 2: Importing the Data into MySQL

1. Create a new database, start by creating a new schema
    
    ![Screenshot 2024-09-08 at 3.33.14 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_3.33.14_PM.png)
    

1. Import the dataset into a table using the “Table Data Import Wizard”
    
    ![Screenshot 2024-09-08 at 3.36.32 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_3.36.32_PM.png)
    
    ![Screenshot 2024-09-08 at 3.38.17 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_3.38.17_PM.png)
    
2. Configure the input settings, and make sure the correct data type for each column is selected.
We left the ‘date’ column as ‘text’ for now instead of changing it to ‘DATETIME’ type.
    
    ![Screenshot 2024-09-08 at 3.40.20 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_3.40.20_PM.png)
    
    ![Screenshot 2024-09-08 at 3.40.59 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_3.40.59_PM.png)
    

Only 564 records were imported out of the 2361 records the .csv file has. 

1. Fixing the import in order to be able to import the whole .csv file with all the records, and for this I explored two methods:
    1. Changing the data type in the schema in the import wizard such that all columns are imported as text. 
        
        ![Screenshot 2024-09-08 at 3.50.15 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_3.50.15_PM.png)
        
        ![Screenshot 2024-09-08 at 3.51.04 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_3.51.04_PM.png)
        
    
    But that didn’t fix the issue.
    
    b. Converting the .csv file into a .json file and re-importing using the Wizard.
    
    ![Screenshot 2024-09-08 at 3.55.40 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_3.55.40_PM.png)
    
    ![Screenshot 2024-09-08 at 3.56.07 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_3.56.07_PM.png)
    
    The entire file was now imported. However, the detected format for all of the columns would be text. 
    
2. Now we want to start cleaning the data.

Step 3: Cleaning the data

We’re going to do a few things in this step that include the following:

1. Remove duplicates
2. Standardize the Data
3. handle Null values or Blank values
4. Remove any irrelevant columns

Before we start deleting or irreversibly change the data, we want to make a copy of the raw data, and keep one copy untouched, and then do our work in the other table.

Removing duplicates:

The result shows multiple duplicates

![Screenshot 2024-09-08 at 4.23.20 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_4.23.20_PM.png)

However, we need to check and confirm that the result records are actually duplicates.

![Screenshot 2024-09-08 at 4.26.59 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_4.26.59_PM.png)

The result shows that they’re not duplicates and so we need to adjust our criteria to partition by all the columns.

![Screenshot 2024-09-08 at 4.31.17 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_4.31.17_PM.png)

Duplicates were found and now we need to clean them.

We can use the CTE for that. 

![Screenshot 2024-09-08 at 4.34.11 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_4.34.11_PM.png)

However, running the code resulted in an error:

Error Code: 1288. The target table new_duplicate_cte of the DELETE is not updatable

Apparently, MySQL doesn’t support this action and instead, to workaround it, we can create a new table with the row_num colum and deleting the record where the value in that column is equal to 2.

That can be easily done if we right-click on the staging table > copy to clipboard > create statement. Then we can paste the code in the editor.

![Screenshot 2024-09-08 at 4.38.11 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_4.38.11_PM.png)

We will add the row_num column and run 

![Screenshot 2024-09-08 at 5.01.28 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_5.01.28_PM.png)

Now we’ll check the duplicate values once more

```sql
SELECT *
FROM layoffs_staging2
WHERE row_num > 1; 
```

The delete them

```sql
DELETE
FROM layoffs_staging2
WHERE row_num > 1; 
```

However, we get an error

Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.

We’ll disable the safe mode from the settings, hit the ‘reconnect to DBMS’ button and try gain.

![Screenshot 2024-09-08 at 5.08.09 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_5.08.09_PM.png)

![Screenshot 2024-09-08 at 5.08.26 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_5.08.26_PM.png)

![Screenshot 2024-09-08 at 5.08.39 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_5.08.39_PM.png)

Standardizing data:

Basically, we want to check columns, and look for things to improve. 

We’ll remove extra spaces using the TRIM function, and update the table. Then we’ll find different versions of the same record and update them such that they are standardized.

![Screenshot 2024-09-08 at 5.32.16 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_5.32.16_PM.png)

![Screenshot 2024-09-08 at 5.44.31 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_5.44.31_PM.png)

Fixing the date column format to make it standardized

![Screenshot 2024-09-08 at 6.31.21 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_6.31.21_PM.png)

However, when running the UPDATE command, we get and error:

Error Code: 1411. Incorrect datetime value: 'NULL' for function str_to_date

![Screenshot 2024-09-08 at 6.31.34 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_6.31.34_PM.png)

This error is because the function is trying to update date strings into datetime data type but it’s failing to update NULL values. Upon inspection, these NULL values are just strings of ‘NULL’ rather than a NULL value. This happened because of the way we imported the data. 

To fix that, we’ll do a workaround.

![Screenshot 2024-09-08 at 6.36.21 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_6.36.21_PM.png)

Now we have proper date format, but the column data type is still text, so we’ll need to change that.

![Screenshot 2024-09-08 at 6.37.35 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_6.37.35_PM.png)

We will alter the column and change it into a ‘Date’ type.

![Screenshot 2024-09-08 at 6.40.32 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_6.40.32_PM.png)

Handling NULL and Blank values:

```sql
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
; -- This code returns an empty table, because the NULL values are actually strings
-- 'NULL'. Therefore, this must be addresses, and one way to do that is:
UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = 'NULL';
```

Now the SELECT code works as expected

![Screenshot 2024-09-08 at 7.40.28 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_7.40.28_PM.png)

We’ll redo the same steps above to fix the other columns as well.

![Screenshot 2024-09-08 at 7.50.16 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_7.50.16_PM.png)

Let’s continue working on populating NULL or Missing values

Let’s get records where the industry column is either empty or has a NULL value and see if we can populate these. 

![Screenshot 2024-09-08 at 7.54.20 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_7.54.20_PM.png)

The below example shows how we can potentially fill the missing values from the industry column 

![Screenshot 2024-09-08 at 7.56.25 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_7.56.25_PM.png)

![Screenshot 2024-09-08 at 8.01.22 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_8.01.22_PM.png)

Or the better method

![Screenshot 2024-09-08 at 8.16.00 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_8.16.00_PM.png)

We’ll also delete records where both the total_laid_off and percentage_laid_off are NULL or missing, because we can’t extrapolate their values

![Screenshot 2024-09-08 at 8.25.10 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_8.25.10_PM.png)

Lastly, we want to remove the row_num column we added earlier

![Screenshot 2024-09-08 at 8.29.30 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_8.29.30_PM.png)



STEP 4: 

Data Exploration

1. Started by checking MAX values, but noticed that the value that was being returned was incorrect. And after further inspection, realized that the function wasn’t performing the calculation correctly on the column values, because the column data type was text, and so the values in the column were also strings/texts. 

Fixing the data type lead to getting the correct result from the max function.
    
    ![Screenshot 2024-09-08 at 11.33.11 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_11.33.11_PM.png)
    

I continue exploring the data, and also find that the funds_raised_millions column is being sorted incorrectly because the values in the column are also stored as strings rather than numbers. 

![Screenshot 2024-09-08 at 11.37.30 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_11.37.30_PM.png)

We’ll fix the column and values and try the query again

![Screenshot 2024-09-08 at 11.43.50 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_11.43.50_PM.png)

![Screenshot 2024-09-08 at 11.52.24 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_11.52.24_PM.png)

We continue to explore the data with more queries to find out what companies had the most layoffs, which industries had the most layoffs, find what is the date range we have for the data and more..

![Screenshot 2024-09-08 at 11.54.34 PM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-08_at_11.54.34_PM.png)

Continue exploring  to find more insights

![Screenshot 2024-09-09 at 12.09.14 AM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-09_at_12.09.14_AM.png)

More advanced exploration

![Screenshot 2024-09-09 at 12.40.50 AM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-09_at_12.40.50_AM.png)

 Find company lay offs, partitioned by year and ordered by dense rank

![Screenshot 2024-09-09 at 11.43.56 AM.png](Project%201%20Tech%20layoffs%20data%20cleaning%20and%20data%20expl%20ffc72114d07945f9bfc46bfbef8ad9db/Screenshot_2024-09-09_at_11.43.56_AM.png)


