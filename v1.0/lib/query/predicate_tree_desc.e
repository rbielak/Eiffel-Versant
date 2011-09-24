-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- A descriptor class for the query expresion tree. It is used to
-- associate the values of query parameters with specific predicates
--

class PREDICATE_TREE_DESC
	
inherit
	
	DB_GLOBAL_INFO
	DB_CONSTANTS

creation
	
	make


feature
	
	
	root_predicate_block: DB_QUERY_PREDICATE_BLOCK
			-- top predicate block of this query
	
	
	prepare_predicate (parameters: ARRAY [ANY]; pclass: PCLASS) is
			-- Prepare predicate for the query
		require
			pclass_ok: pclass /= Void
		do
				if not predicates_created then
					-- Now create predicates of appropriate types
				        create_predicates (parameters, pclass)
					predicates_created := True
				else
					-- Simply reassign values to the query predicates
					reset_values (parameters)
				end

		end

	flush is
		local
			arg : ANY
			pdesc : PREDICATE_DESC
			predicate : DB_QUERY_PREDICATE[ANY]
		do
			from
				predicate_desc_list.start
			until
				predicate_desc_list.off
			loop			
				pdesc := predicate_desc_list.item
				predicate := pdesc.predicate
				if pdesc.argument_to_compare > 0 then
					predicate.set_value (void)
				end
				predicate_desc_list.forth
			end
		end

feature {NONE}
	
	make (parsed_query : QUERY_AS; new_root_block: DB_QUERY_PREDICATE_BLOCK) is
		require
			parsed_query /= Void
			new_root_block /= Void
		do
			!!predicate_desc_list.make
			parsed_query.action (new_root_block, predicate_desc_list)
			root_predicate_block := new_root_block
		ensure
			predicate_desc_list /= Void
		end
	

	pred_factory : PREDICATE_FACTORY is
		once
			!!Result
		end
	
	
	predicates_created: BOOLEAN
			--  true if all predicates have been created
			--  from the input parameters

	predicate_desc_list : LINKED_LIST [PREDICATE_DESC]
			-- list of predicate descriptors. This list is
			-- set up once during parsing
	
	
	create_predicates (parms : ARRAY[ANY]; pclass: PCLASS) is
		local
			pdesc : PREDICATE_DESC
			predicate : DB_QUERY_PREDICATE[ANY]
			pattribute: PATTRIBUTE
			arg : ANY
			ex : EXCEPTIONS
		do
			from  predicate_desc_list.start
			until predicate_desc_list.off
			loop
				pdesc := predicate_desc_list.item
				-- Retrieve the attribute description from the schema
				pdesc.feature_access.find_pattributes (pclass)

				-- Create a predicate from the descriptor
				predicate := pred_factory.make_from_descriptor (pdesc)

				if pdesc.argument_to_compare > 0 then
					-- Connect an argument with its predicate
					arg := parms @ pdesc.argument_to_compare
					predicate.set_value (arg)
				end
				pdesc.set_predicate (predicate)
				pdesc.predicate_block.add_predicate_term (predicate)
				predicate_desc_list.forth
			end
		end
	
	reset_values (parms : ARRAY [ANY]) is
		local
			arg : ANY
			pdesc : PREDICATE_DESC
			predicate : DB_QUERY_PREDICATE[ANY]
		do
			from  predicate_desc_list.start
			until predicate_desc_list.off
			loop			
				pdesc := predicate_desc_list.item
				predicate := pdesc.predicate
				if pdesc.argument_to_compare > 0 then
					if parms /= void then
						arg := parms @ pdesc.argument_to_compare
						predicate.set_value (arg)
					else
						predicate.set_value (void)
					end
				end
				predicate_desc_list.forth
			end
		end

end -- PREDICATE_TREE_DESC
