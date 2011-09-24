-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Move schema from one database to another
--

class COPY_SCHEMA
	
inherit
	
	VERSANT_EXTERNALS

creation
	
	make

feature
	
	session: DB_SESSION is
		once
			!!Result
		end
	
	
	processor: CMD_PROCESSOR [ARGUMENT_COMMAND] is
		once
			!!Result.make
			-- don't clone commands
			Result.set_clone_command_objects (False)
		end
	
	from_db, to_db: DATABASE_COMMAND
	
	verbose: VERBOSE_COMMAND
	
	source_db, target_db: DATABASE
	
	source_schema: VSTR

	make is
		local
			args: expanded ARGUMENTS
		do
			if args.argument_count < 4 then
				io.putstring ("Usage: -from <db-name> -to <db-name> {-v}%N")
			else
				!!from_db
				processor.add_command ("-from", from_db)
				!!to_db
				processor.add_command ("-to", to_db)
				!!verbose
				processor.add_command ("-v", verbose)
				processor.parse
				if processor.parsed_ok then
					processor.execute
					session.begin (to_db.database_name)
					target_db := session.current_database
					io.putstring ("--> Connected to ")
					io.putstring (target_db.name)
					io.new_line
					!!source_db.make (from_db.database_name)
					source_db.connect
					io.putstring ("--> Connected to ")
					io.putstring (source_db.name)
					io.new_line
					
					-- retrieve target schema
					retrieve_schema
					-- move schema to desctination database
					move_schema_to_target
					io.putstring ("--> Schema moved %N")
					session.finish
				end
			end
		end
	
	retrieve_schema is
		local
			class_vstr: POINTER
		do
			class_vstr := c_db_select ($(("class").to_c), $(source_db.name.to_c), 
									   false, 0, default_pointer)
			!!source_schema.make (class_vstr)
			io.putstring ("--> Schema retrieved. There were ")
			io.putint (source_schema.integer_count)
			io.putstring (" classes. %N")
		end
	
	move_schema_to_target is
		local
			class_name: STRING
			class_id: INTEGER
			i: INTEGER
			failed_list: LINKED_LIST [STRING]
		do
			!!failed_list.make
			session.start_transaction
			-- just stupidly iterate over the vstr and move the
			-- classes to see what happens
			from i := 1
			until i > source_schema.integer_count
			loop
				class_id := source_schema.i_th_integer (i)
				class_name := get_db_string_attr (class_id, $(name_str.to_c))
				if verbose.verbose_flag then
					io.putstring ("...syncing: ")
					io.putstring (class_name)
					io.new_line
				end
				if not sync_one_class (class_name, source_db.name, target_db.name) then
					failed_list.extend (class_name)
				end
				i := i + 1
			end
			if failed_list.count > 0 then
				io.putstring ("Resyncing classes that were in error...%N")
				from failed_list.start
				until failed_list.off
				loop
					class_name := failed_list.item
					io.putstring ("Resyncing: ")
					io.putstring (class_name)
					io.new_line
					if not sync_one_class (class_name, source_db.name, target_db.name) then
						io.putstring ("...Failed again!!! %N")
					end
					failed_list.forth
				end
			end
			session.end_transaction
		rescue
			session.abort_transaction
		end
	
	name_str: STRING is "name"

	sync_one_class (class_name, source_db_name, target_db_name: STRING): BOOLEAN is
		do
			if sync_class ($(class_name.to_c), 
						   $(source_db_name.to_c), 
						   $(target_db_name.to_c), 0) /= 0 then
				io.putstring ("***ERROR: Failed to sync class: ")
				io.putstring (class_name)
				io.putstring (" Error: ")
				io.putint (session.last_error)
				io.new_line
			else
				Result := True
			end
		end

	sync_class (class_name, source, target: POINTER; options: INTEGER): INTEGER is
		external "C"
		alias "o_synclass"
		end

end -- MOVE_SCHEMA
