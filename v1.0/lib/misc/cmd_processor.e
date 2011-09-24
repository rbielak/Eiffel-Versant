-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class CMD_PROCESSOR [T -> ARGUMENT_COMMAND]

creation

	make

feature


	parse_ran_successfully: BOOLEAN

	parsed_ok: BOOLEAN is
		do
			Result := parse_ran_successfully
		end

	do_not_connect_to_database: BOOLEAN
				-- Default value is false.
				-- That means that Rainbow connects to the database if nobody says no.

	parse is
			-- Parse command line arguments and put
			-- relevant commands into a list for execution
		local
			current_command: ARGUMENT_COMMAND
			i: INTEGER
			arg_name: STRING
			bad_syntax: BOOLEAN;
		do
			!!args
			if args.argument_count < 1 then
				parse_ran_successfully := True
			else
				from i := 1
				until i > args.argument_count
				loop
					arg_name := args.argument(i);
					if arg_name.item (1) = '-' and (arg_name.item(2).is_alpha) then
						if current_command /= Void then
							execution_list.extend (current_command)
						end
						entered_switches.extend (arg_name)
						-- Get new command
						if clone_command_objects then
							current_command ?= clone(commands.item (arg_name));
						else
							current_command ?= commands.item (arg_name)
						end
						if current_command = Void then
							io.put_string ("%NInvalid argument entered: ")
							io.put_string (arg_name)
							io.put_string ("'%NType '")
							io.put_string (args.command_name)
							io.put_string (" -help' for additional help%N")
							io.new_line
							bad_syntax := True
						else
							-- Do not connect to database if one command says no
							do_not_connect_to_database := do_not_connect_to_database or current_command.do_not_connect_to_database
						end
					else
						-- it's an argument to a command
						if current_command = Void then
							if i = 1 then
								io.put_string ("Looking for an argument, found '")
								io.put_string (args.argument(1))
								io.put_string ("'%NType '")
								io.put_string (args.command_name)
								io.put_string (" -help' for additional help%N")
								io.new_line
								bad_syntax := True
								-- error_command.execute
							end
						else
							current_command.add_command_arg (arg_name);
						end
					end;
					i := i + 1
				end; -- loop
				if current_command /= Void then
					execution_list.extend (current_command)
				end
				parse_ran_successfully := not bad_syntax
			end
		end;


	execute is
			-- Parse command line and perform appropriate functions
		require
			parse_ran_successfully: parse_ran_successfully
		do
			if args.argument_count < 1 then
				if no_args_command /= Void then
					no_args_command.execute
				else
					error_command.execute
				end
			else
				if parse_ran_successfully then
					from execution_list.start
					until execution_list.off
					loop
						execution_list.item.execute
						execution_list.forth
					end
				end
			end
		end;

	add_command (cmd_name: STRING; cmd: T) is
			-- Add new command to the set (command
			-- syntax "-cmd arg1 arg2 arg3")
		require
			command_valid: cmd /= Void;
			name_ok: (cmd_name /= Void) and then (cmd_name.item(1) = '-')
		do
			commands.put (cmd, cmd_name);
		ensure
			commands.has (cmd_name);
		end

	error_command: ARGUMENT_COMMAND;
			-- What to do on error in the command line

	set_error_command (cmd: ARGUMENT_COMMAND) is
			-- Define new error command
		do
			error_command := cmd;
		end

	no_args_command: ARGUMENT_COMMAND;
			-- What to do if there are no arguments

	set_no_args_command (cmd: ARGUMENT_COMMAND) is
			-- define new default command
		do
			no_args_command := cmd
		end

	help is
			-- Print help, if any
		local
			cmds: ARRAYED_LIST [ARGUMENT_COMMAND]
			i: INTEGER
		do
			cmds := commands.linear_representation
			from -- i := cmds.lower
				cmds.start
			until -- i > cmds.upper
				cmds.off
			loop
				if cmds.item.help_text /= Void then
					io.put_string (cmds.item.help_text)
				end
				-- i := i + 1
				cmds.forth
			end
			io.new_line
		end

	set_clone_command_objects (value: BOOLEAN) is
		do
			clone_command_objects := value
		end

feature

	was_entered (switch: STRING): BOOLEAN is
			-- Check if another switch was entered
		do
			Result := entered_switches.has (switch)
		end

	count_of_entered_switches: INTEGER is
		require
			parsed_ok
		do
			Result := entered_switches.count
		end

feature {NONE}

	clone_command_objects: BOOLEAN

	args: ARGUMENTS
			-- command line arguments

	execution_list: LINKED_LIST [ARGUMENT_COMMAND]
			-- command found on the command line

	commands: HASH_TABLE [ARGUMENT_COMMAND, STRING];
			-- Defined commands

	entered_switches: LINKED_LIST [STRING];
			-- List of switches found on the command line.

	make is
		do
			!!commands.make (10)
			!DEFAULT_ERROR_CMD!error_command
			!!execution_list.make
			!!entered_switches.make
			entered_switches.compare_objects
			clone_command_objects := True
		end

end
