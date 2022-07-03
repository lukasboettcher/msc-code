#ifndef ANDERSENOPT_H_
#define ANDERSENOPT_H_

#include "WPA/Andersen.h"
#include "MemoryModel/PointsTo.h"

namespace SVF
{

    class AndersenOpt : public AndersenWaveDiff
    {

    private:
        bool runComplete = false;
        NodeStack changeSet;

    protected:
    public:
        AndersenOpt(SVFIR *_pag, PTATY type = Andersen_WPA, bool alias_check = true) : AndersenWaveDiff(_pag, type, alias_check) {}

        ~AndersenOpt()
        {
        }
    };

}

#endif