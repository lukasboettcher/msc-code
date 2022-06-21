#ifndef ANDERSENCUSTOM_H_
#define ANDERSENCUSTOM_H_

#include "WPA/Andersen.h"
#include <mmxcflr.h>

namespace SVF
{

class AndersenCustom : public Andersen
{


public:
    AndersenCustom(SVFIR *_pag, PTATY type = Andersen_WPA, bool alias_check = true) : Andersen(_pag, type, alias_check) {}

};

}

#endif 