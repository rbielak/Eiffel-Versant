-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DBA

inherit

	ARGUMENTS	
	SHARED_SESSION
	

creation 

	make

feature

	make is
		local		  
			dejected : BOOLEAN
		do
			io.putstring("DBA v2.01 -- A simple tool to define classes %N")
			if argument_count > 0 then
				process_cmd_line
			else	
				dejected := init_dbase (menu_init_error_msg)
				process_menu
			end
		end

feature    --  error messages
	
	menu_init_error_msg : STRING is "Failure to connect..  retry from menu.."

	cmd_init_error_msg : STRING is "Failure to connect to database"
                                  

feature    -- handle command lines

	processor: COMMAND_PROCESSOR_WITH_PRIORITY [PRIORITY_ARG_COMMAND]

	process_cmd_line is
		require
			argument_count > 0
		local
			dba_cmd: PRIORITY_ARG_COMMAND	
			help_cmd : HELP_CMD
--			display_instance_cmd: DISPAY_INSTANCE_COMMAND 
			dbase_default_failed : BOOLEAN 

		do
			!!processor.make
			!!help_cmd.make (1)
			processor.set_error_command (help_cmd)
			help_cmd.set_processor (processor)
			processor.add_command ("-help",help_cmd)
			!SESSION_COMMAND!dba_cmd.make (2)
			processor.add_command ("-d", dba_cmd)
			!DEFINE_CLASS_COMMAND!dba_cmd.make (3)
			processor.add_command ("-newclass",dba_cmd)
			!DROP_CLASS_COMMAND!dba_cmd.make (3)
			processor.add_command ("-dropclass",dba_cmd)
			!RETRIEVE_CLASS_COMMAND!dba_cmd.make (8)
			processor.add_command ("-class",dba_cmd)
			!RENAME_CLASS_COMMAND!dba_cmd.make (4)
			processor.add_command ("-renameclass",dba_cmd)
			!NEW_ATTRIB_COMMAND!dba_cmd.make (5)
			processor.add_command ("-newattr",dba_cmd)
			!DROP_ATTRIB_COMMAND!dba_cmd.make (6)
			processor.add_command ("-dropattr",dba_cmd)
			!RENAME_ATTRIB_COMMAND!dba_cmd.make (6)
			processor.add_command ("-renameattr",dba_cmd)
			!REDEFINE_ATTRIB_COMMAND!dba_cmd.make (5)
			processor.add_command ("-redefine",dba_cmd)
			!DB_INFO_COMMAND!dba_cmd.make (8)
			processor.add_command ("-free",dba_cmd)		
			!MIGRATE_COMMAND!dba_cmd.make (7) 
			processor.add_command ("-migrate",dba_cmd)
			!DISPLAY_INSTANCE_COMMAND!dba_cmd.make (8)
			processor.add_command ("-L", dba_cmd)
			-- ......
		
			processor.parse
			if processor.parsed_ok then
				if processor.was_entered ("-h") or processor.was_entered ("-help") then
					help_cmd.execute
				else
					if processor.was_entered ("-d") and processor.count_of_entered_switches = 1 then
						processor.execute
						process_menu
					else
						if not processor.was_entered ("-d") then
							dbase_default_failed := init_dbase (cmd_init_error_msg)
						else
							dbase_default_failed := false
						end
						if not dbase_default_failed then
							processor.execute
							if sess.active and sess.in_transaction then
								sess.end_transaction
								sess.finish
							end
						end
					end
				end
			else
				io.putstring ("Invalid command%N")
			end
			-- call finish session and commit
		
		end


feature -- handle interactive menu
	

	menu: MENU


   set_up_menu is
		local
			dba_cmd: CMD
			cmd_index: INTEGER
		do
			!!menu.make (17)
			!SESSION_MENU_COMMAND!dba_cmd	  
			menu.put ("Start session", dba_cmd)
			!DEFINE_CLASS_MENU_COMMAND!dba_cmd
			menu.put ("Define class",dba_cmd)
			!DROP_CLASS_MENU_COMMAND!dba_cmd
			menu.put ("Drop class",dba_cmd)
			!RETRIEVE_CLASS_MENU_COMMAND!dba_cmd
			menu.put ("Retrieve class",dba_cmd)
			!RENAME_CLASS_MENU_COMMAND!dba_cmd
			menu.put ("Rename Class",dba_cmd)
			!NEW_ATTRIB_MENU_COMMAND!dba_cmd
			menu.put ("Add attribute",dba_cmd)
			!DROP_ATTRIB_MENU_COMMAND!dba_cmd
			menu.put ("Drop attribute",dba_cmd)
			!RENAME_ATTRIB_MENU_COMMAND!dba_cmd
			menu.put ("Rename attribute",dba_cmd)
			!REDEFINE_ATTRIB_MENU_COMMAND!dba_cmd
			menu.put ("Redefine attribute",dba_cmd)
			!COMMIT_MENU_COMMAND!dba_cmd
			menu.put ("Commit transaction",dba_cmd)
			!DB_INFO_MENU_COMMAND!dba_cmd
			menu.put ("DB free info",dba_cmd)
			!CONNECT_DB_MENU_COMMAND!dba_cmd
			menu.put ("Connect to database",dba_cmd)
			!DISCONNECT_DB_MENU_COMMAND!dba_cmd
			menu.put ("Disconnect database",dba_cmd)
			!SWITCH_DB_MENU_COMMAND!dba_cmd
			menu.put ("Switch current database",dba_cmd)
			!MIGRATE_MENU_COMMAND!dba_cmd
			menu.put ("Move object to another database",dba_cmd)
			!DISPLAY_INSTANCE_MENU_COMMAND!dba_cmd
			menu.put ("Display instances of Object",dba_cmd)
			!END_MENU_COMMAND!dba_cmd
			menu.put ("End session",dba_cmd)
		
		end

	process_menu is
		local
			cmd_number: INTEGER
			finished: BOOLEAN
			command: CMD
			end_cmd: END_MENU_COMMAND
		do			
			set_up_menu;		
			from  
			until finished
			loop
				if sess.active then
					io.putstring ("%N--> Current db: ")
					io.putstring (sess.current_database.name)
					io.putstring (" <--- %N%N")
				end
				menu.display
				io.new_line
				cmd_number := get_integer ("Enter choice: ")
				if (cmd_number > 0) and (cmd_number <= menu.last_item) then
					command := menu.item(cmd_number)
				else
					command := Void
				end;
				if command = Void then
					io.putstring ("Invalid command...%N")
				else
					command.execute
					finished := cmd_number = menu.last_item
				end
				-- io.next_line;
			end -- loop
		rescue
			io.putstring ("We crashed. Try to end session...%N")
			if sess.active then
				if sess.in_transaction then
					sess.abort_transaction
				end
				sess.finish
			end
		end

	get_integer (prompt : STRING): INTEGER is
		do
			from
			until Result > 0
			loop
				io.putstring (prompt);
				io.putstring (" "); 
				io.readline;
				Result := io.laststring.to_integer;
			end;
		rescue
			retry
		end;
	

feature  -- initiate default database

	init_dbase (init_error_msg : STRING) : BOOLEAN is
		local
			db_name : STRING
			crash : BOOLEAN
		   	env : expanded ENVIRONMENT_VARIABLES	
		do
			if not crash then
				db_name := env.get ("O_DBNAME");
				if db_name /= Void then
					io.putstring ("Connecting to: <")
					io.putstring (db_name)
					io.putstring (">%N")
					sess.begin (db_name)					
					Result := false
				end;
			else
				Result := true
				io.putstring (init_error_msg)
				io.new_line
			end
		rescue
			crash := true;
			retry
		end

end
