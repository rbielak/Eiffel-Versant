To test the database code follow these steps:


1. Create a database using Versant tools.

2. Use "define_schema" with people.schema file as input.

3. Run "db_testor" to feed the database:

	db_testor -d <yourdb-name> <test_file>

   Use "inputs/test_file.txt"

4. Run db_testor with "-verify" option and the same input
   file.

5. Run db_testor with "-query" option and "inputs/query.txt" file.

