-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

class DEFINE_SCHEMA

creation
	
	make

feature
	
	f : PLAIN_TEXT_FILE;
			-- file where the schema is in
	
	
	database_name : STRING
			-- name of the database in which we define the schema
	
	schema_file_name : STRING
			-- name of the schema file

	parser : SCHEMA_PARSER;
			-- Parser for the schema
	
	sorter : CLASS_SORTER
			-- Sorter for schema classes
	
	builder : SCHEMA_BUILDER
			-- Actually defines the schema in the database
	
feature -- command line arguments handling

	args : expanded ARGUMENTS;
			-- command line arguments
	
	args_ok : BOOLEAN
			-- true if args OK
	
	handle_arguments is
		local
			env : expanded ENVIRONMENT_VARIABLES
		do
			-- expect either two or four parameters
			-- build_schema  -d <db_name> <schema_file>
			-- build_schema  <schema_file>
			if args.argument_count = 1 then
				database_name := env.get ("O_DBNAME");
				schema_file_name := clone (args.argument(1));
				args_ok := database_name /= Void;
			elseif args.argument_count = 3 then
				if (args.argument(1).is_equal ("-d") or 
				   args.argument(1).is_equal ("-D")) then
					database_name := clone (args.argument(2));
					schema_file_name := clone (args.argument(3));
					args_ok := True;
				end;
			end
			if not args_ok then
				io.putstring ("Usage: define_schema -d <db_name> <schema_file_name>%N");
				io.putstring ("       define_schema <schema_file_name>%N");
			end
		end


	make is
		do
			io.putstring ("--> define_schema. version 10-16-96%N")
			handle_arguments;
			if args_ok then
				-- First parse the schema
				!!f.make_open_read (schema_file_name);
				!!parser.make (f);
				io.putstring ("***** Parsing schema file %N");
				parser.parse;
				f.close;
				io.putstring ("***** Sorting classes  %N");
				!!sorter.make 
				sorter.sort_list (parser.classes)
				io.putstring ("...sort done...%N");
				!!builder.make (database_name)
				builder.start_session
				if sorter.missing_parents then
					builder.build_partial_schema (sorter.sorted_classes)
				else
					builder.build_full_schema (sorter.sorted_classes)
				end
				builder.end_session
			end
		end
	

end -- DEFINE_SCHEMA
