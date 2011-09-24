-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- DB_QUERY - this is the basic interface to the DB querying facility. Queries
--  run against all objects of a given class, or against all objects
-- of a given class and its descendant types
--

indexing

	description: "Low level interface to database queries";
	database: "Versant"

class DB_QUERY [T->POBJECT]

inherit

	VERSANT_EXTERNALS
	DB_GLOBAL_INFO
	MEMORY

creation
	make 

feature
	
	make (new_class : STRING) is
			-- Make a query object
		do
			if new_class /= Void then
				class_name := clone (new_class);
				class_name.to_lower;
			end;
			!LINKED_LIST[DB_QUERY_PREDICATE[ANY]]!predicates.make;
			include_descendants := True;
		ensure
			include_descendants;
		end;
	
	execute is
			-- Run the query defined by the predicates
		require
			class_specified : class_name /= Void
		local
			count, i, poid: INTEGER
			po: POBJECT
			timer: SIMPLE_TIMER
		do
			debug ("query")
				!!timer
				timer.start
			end
			last_result := Void
			do_select
			-- Create a result array
			if c_get_error = 0 and then result_vstr.exists then
				!!last_result.make_from_vstr (result_vstr, result_generator)
			else
				debug
					io.putstring ("Select failed: Error = ");
					io.putint (c_get_error);
					io.new_line;
				end;
			end;
			-- Free up any vstrs
			if predicate_vstr /= default_pointer then
				c_deletevstr (predicate_vstr)
				predicate_vstr := default_pointer
			end
			debug ("query")
				timer.stop
				io.putstring ("DB_QUERY on (")
				io.putstring (class_name)
				io.putstring (") called: ")
				timer.print_time
			end
		ensure
			(last_result /= Void) implies (last_result.count > 0)
		end;

	last_result : PLIST [T]
			-- Objects returned from the query, after call
			-- to "execute"

	class_name : STRING
			-- Query on objects of this class
	
	set_class_name (new_name: STRING) is
		require
			ok_name : new_name /= Void
		do
			class_name := clone(new_name);
		end;
	
	include_descendants : BOOLEAN
			-- True, if the query should also consider
			-- descendant classes
	
	set_include_descendants (value : BOOLEAN) is
			-- Tell the query processor if object of descendant types
			-- should be included in the search
		do
			include_descendants := value;
		end; -- set_include_decendants
	
	
	database : DATABASE
			-- if not void, the query runs on just this datbase
	
	set_database (new_db : DATABASE) is
			-- Set the database for the query
		require
			db_connected: (new_db /= Void) implies new_db.is_connected
		do
			database := new_db
		end

	add_predicate (new_predicate : DB_QUERY_PREDICATE[ANY]) is
			-- Add a predicate
		require
			pred_ok: new_predicate /= Void
		do
			predicates.extend (new_predicate);
		end;

	clear_predicates is 
			-- Clear all predicates for this query
		do
			predicates.wipe_out;
		end;

	predicate_count : INTEGER is
			-- Count of defined predicates
		do
			Result := predicates.count;
		end

feature {NONE}

	result_generator : STRING is 
		do
			Result := "plist[";
			Result.append (class_name);
			Result.append("]");
		end;

	result_vstr: VSTR
			-- Result of the query	

	do_select is
		local
			result_so_far: VSTR
			db : DATABASE
			gc_was_on: BOOLEAN
		do
			-- disable GC while doing query, so that
			-- objects don't get moved
			if collecting then
				collection_off
				gc_was_on := True
			end

			-- Build predicate vstr
			if predicates.count > 0 then
				build_predicate_vstr;
				debug ("db_query")
					io.putstring ("Size of predicate vstr: ");
					io.putint (c_sizeofvstr(predicate_vstr));
					io.new_line;
				end;
			end;

			if database /= Void then
				!!result_vstr.make (database.db_select (class_name, 
							      predicate_vstr, 
							      include_descendants))
			else
				-- Issue select on each database we are connected to 
				from 
					!!result_vstr.make (default_pointer)
					db_interface.active_databases.start
				until 
					db_interface.active_databases.off
				loop
					db := db_interface.active_databases.item
					!!result_so_far.make (db.db_select (class_name, 
								       predicate_vstr, 
								       include_descendants))
					-- Append vstrs
					if result_so_far.exists then
						result_vstr.concat_area (result_so_far)
						result_so_far := Void
						check_error
					end
					db_interface.active_databases.forth
				end
			end
			if gc_was_on then
				collection_on
			end
		rescue
			if gc_was_on then
				collection_on
			end
		end

	predicates : LIST[DB_QUERY_PREDICATE[ANY]]
			-- list of predicates ro the query

	predicate_vstr : POINTER
			-- pointer to Versant representation of the predicates

	build_predicate_vstr is
			-- Build a predicate vstr for the select
		local
			pred : DB_QUERY_PREDICATE[ANY];
		do
			from predicates.start
			until predicates.off
			loop
				pred := predicates.item;
				predicate_vstr := c_build_pred_vstr (predicate_vstr, pred.to_pointer);
				debug ("db_query")
					io.putstring ("db_query.build_predicate_vstr. Pred_vstr=");
					io.putstring (predicate_vstr.out);
					io.new_line;
					io.putstring ("Error=");
					io.putint (c_get_error);
					io.new_line;
				end
				predicates.forth
			end
		end

end -- DB_QUERY
