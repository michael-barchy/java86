type REGS86  AX%, BX%, CX%, DX%, BP%, SI%, DI%, FLAGS%

bundle reg REGS86

%REG_COUNT = 8
%REG_SIZE = 16

SUB InvokeNative(MethodRef$, Offset%)
