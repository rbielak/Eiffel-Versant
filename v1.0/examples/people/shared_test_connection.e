-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SHARED_TEST_CONNECTION

inherit
	
	EXCEPTIONS
	
	ARGUMENTS

feature
	
	session : expanded DB_SESSION;
	

	connected_databases: ARRAY [DATABASE]

	start_connection is
		local
			db_name : STRING;
			db: DATABASE
			i: INTEGER
		do
			if argument_count > 0 then
				!!connected_databases.make (1, argument_count)
				db_name := argument (1)
				io.putstring ("Connecting to database: ")
				io.putstring (db_name)
				io.new_line
				session.begin (db_name)
				connected_databases.put (session.current_database, 1)
				from i := 2
				until i > argument_count
				loop
					!!db.make (argument (i))
					db.connect
					print ("Also connected to: ")
					print (db.name)
					print ("%N")
					connected_databases.put (db, i)
					i := i + 1
				end
			else
				print ("ERROR: no database specified on the command line %N")
				raise ("no databases")
			end
		end
	
	
	end_connection is
		do
			session.finish
		end


end -- SHARED_TEST_CONNECTION
