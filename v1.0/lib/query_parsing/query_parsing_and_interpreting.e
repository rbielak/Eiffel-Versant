-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class QUERY_PARSING_AND_INTERPRETING

feature

	qs: STRING

	build_parser_and_interpreter (query_string: STRING) is
		require
			query_not_void: query_string /= Void
		do
			build_parser_only (query_string)
			if not bad_query and then parsed_query /= Void then
				query_interpreter := query_parser.query_interpreter (parsed_query)
			end
		end

	build_parser_only (query_string: STRING) is
		require
			query_not_void: query_string /= Void
		do
			qs := query_string
			if not equal (query_string, "")  then
				parsed_query := query_parser.parse (query_string)
				if query_parser.syntax_error then
					bad_query := true
					parsed_query := Void
				end
			else
				parsed_query := Void
			end
			debug ("query_parser")
				io.putstring ("Original query string was: ")
				io.putstring (query_string)
				io.new_line
				io.putstring ("Parsed syntax tree is: ")
				if parsed_query /= Void then
					parsed_query.dump
					io.new_line
				else
					io.putstring ("Void%N")
				end
				if bad_query then
					io.putstring ("!!!! SYNTAX ERROR !!!!%N")
				end
			end
		end

	bad_query: BOOLEAN
			-- True if parse of last query failed

feature

	dump_parser is
		do
			parsed_query.dump
		end

feature {NONE}  -- Implementation

	parsed_query: QUERY_AS
			-- abstract syntax tree for the query

	query_interpreter: BYTE_CODE
			-- Interpreter for in-memory query.

	query_parser: QUERY_PARSER is
		once
			!!Result
		end

end -- class QUERY_PARSING_AND_INTERPRETING
