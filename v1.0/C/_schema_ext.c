#include	<osc.h>
#include	<oscerr.h>
#include	<omapi.h>
#include	<obmacros.h>
#include "omsch.h"

#include <stdio.h>


/* Fill in the "auxinfo" attribute in a schema "attribute" object */
c_set_auxinfo (o_object attr_id, o_u1b *data, o_u4b len)
{
  o_attrobj* atp;

  atp = (o_attrobj *)o_locateobj (attr_id, WLOCK);
  if (data == NULL)
      atp->auxinfo = NULL;
  else
      atp->auxinfo = o_newvstr (&atp->auxinfo, len, data);
  o_setdirty (attr_id);
}



