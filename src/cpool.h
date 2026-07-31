DIM CP_CACHE%[10]
DIM CP_COUNT%

%CP_ENTRY_SIZE = 9

%CP_Utf8 = 1
%CP_Integer = 3
%CP_Float = 4
%CP_Long = 5
%CP_Double = 6
%CP_Class = 7
%CP_String = 8
%CP_Fieldref = 9
%CP_Methodref = 10
%CP_InterfaceMethodref = 11
%CP_NameAndType = 12

SUB READ_CONSTANT_POOL(FILE_HANDLE%, CP_IDX%)
