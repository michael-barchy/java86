type REGS86  AX%, BX%, CX%, DX%, BP%, SI%, DI%, FLAGS%

bundle reg REGS86

%REG_COUNT = 8
%REG_SIZE = 16

DIM LAST_FREE_PTR%

SUB InvokeNative(MethodRef$, Offset%)
SUB SafeMFree(PTR_TO_FREE%)
