# offnariscv

offNariaのRISC-Vでoffnariscv．

RISC-VとSystemVerilogの勉強を兼ねて，自作CPUをやっていく．

### 命名規則
とりあえずRV32Iをベースとするoffnariscvということで，大きめのモジュールには`ofnrv32_hoge`という名前を付ける．

### ISA
実装{完了, 予定}のものたち．
- 非特権命令
    - `RV32I`(予定)
    - `RV32M`(予定)