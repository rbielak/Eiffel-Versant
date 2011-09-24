#include "eif_eiffel.h"
#include <osc.h>
#include <oscerr.h>
#include <omapi.h>
#include <stdio.h>

/* #define versant_debug 0  */


extern int malloc (o_4b);

o_4b c_get_db_id (o_dbname database) 
{
  o_dblistdesc *ptr;
  o_err err;
  o_4b db_id = 0;
  char *parameter;
  int m_size = 3 + strlen (database) + 1;

  parameter = (char *)malloc (m_size);
  parameter[0] ='\0';
  strcat (parameter, "-d ");
  strcat (parameter, database);
  err = o_dblist (database, parameter, &ptr, (o_ptr)malloc);
  free (parameter);
  if (err > 0)
    {
      db_id = ptr->dbid;
      free (ptr);
    }
  /* will return 0, if call failed */
  return (db_id);
}

/* Get tge name of the database owner */
EIF_OBJ c_get_db_owner (o_dbname database)
{
  o_dblistdesc *ptr;
  o_err err;
  o_4b db_id = 0;
  EIF_OBJ dba = NULL;
  char *parameter;
  int m_size = 3 + strlen (database) + 1;

  parameter = (char *)malloc (m_size);
  parameter[0] ='\0';
  strcat (parameter, "-d ");
  strcat (parameter, database);
  err = o_dblist (database, parameter, &ptr, (o_ptr)malloc);
  free (parameter);
  if (err > 0)
    {
      dba = RTMS (ptr->dbowner);
      free (ptr);
    }
  /* Will return Void if failure */
  return (dba);
}


typedef struct scan_context  {
  o_dblistdesc *list;
  int count;
  o_dblistdesc *current_ptr;
  char *pattern;
} context;

/* Start scan of db names */
context* c_db_list_start (o_dbname database, char *pattern)
{
  context *ctx;
  char param[10];
  o_4b err;

  ctx = (context *)malloc (sizeof(context));
  ctx->pattern = pattern;
  param[0] = '\0';
  strcat (param, "-all");
  /* Get the info from Versant */
  err = o_dblist (database, param,  &(ctx->list), (o_ptr)malloc);
  if (err == -1) { 
    free (ctx);
    return (NULL);
  };
  ctx->current_ptr = ctx->list;
  ctx->count = err;
  return (ctx);
}

EIF_OBJ c_db_list_next (context *ctx)
{
  EIF_OBJ result = NULL;
  
  while ((ctx->count > 0) && (result == NULL)) {
    if (match_wild_card (ctx->current_ptr->dbname, ctx->pattern)) {
      result = RTMS (ctx->current_ptr->dbname);
    }
    ctx->count--;
    ctx->current_ptr++;
  };
  return (result);
  
}

void *c_db_list_end (context *ctx)
{
  free (ctx->list);
  free (ctx);
}
