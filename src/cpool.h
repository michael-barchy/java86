DIM CP_CACHE%[10]
DIM CP_POS&[10] 'File position of the end of the constant pool
DIM CP_COUNT%
DIM CP_ENTRY$

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

SUB ReadConstantPool(FileHandle%, CP_IDX%)
SUB GetConstantPoolEntry(CP_IDX%, EntryIdx%, FileHandle%)
