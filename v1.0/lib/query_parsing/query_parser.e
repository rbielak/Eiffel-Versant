-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Main class for the parsing of an SQL-like
-- query string which builds an Abstract Syntax
-- Tree.

class QUERY_PARSER

feature

	syntax_error: BOOLEAN

	parse (q_string: STRING): QUERY_AS is
		require
			query_string_not_void: q_string /= Void
		local
			abstract_tree_builder: ABSTRACT_TREE_BUILDER
		do
			!!abstract_tree_builder
			Result := abstract_tree_builder.ast_build (q_string)
			syntax_error := abstract_tree_builder.syntax_error
		end -- parse

	query_interpreter (ast: QUERY_AS): BYTE_CODE is
		require
			ast_not_void: ast /= Void
		do
			Result := ast.interpreter
		end

end -- class QUERY_PARSER
