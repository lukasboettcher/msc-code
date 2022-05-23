file (GLOB SOURCES
        SVF-FE/*.cpp
        Graphs/*.cpp
        Util/*.cpp
        MemoryModel/*.cpp
        MSSA/*.cpp
        WPA/*.cpp
        MTA/*.cpp
        SABER/*.cpp
        DDA/*.cpp
        FastCluster/*.cpp
)

file(GLOB CUDD_SOURCES CUDD/*.c)

add_llvm_library(Cudd ${CUDD_SOURCES} LINK_LIBS m)
add_llvm_library(Svf STATIC ${SOURCES} LINK_LIBS Cudd z3)

set_target_properties(Cudd PROPERTIES COMPILE_FLAGS "-Wno-all -Wno-extra -Wno-format -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast -DHAVE_IEEE_754 -DSIZEOF_VOID_P=8 -DSIZEOF_LONG=8")

# add_subdirectory(spbla)