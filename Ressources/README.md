# Mémo

- [Table des syscalls x86-64](https://syscalls.w3challs.com/?arch=x86_64)
- [Cheat Sheet AT&T / Intel](https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf)

## Comparaisons
ZF zéro · CF retenue (carry) · SF signe · OF overflow · PF parité

| Intuition         | Relation |       Domaine | `jcc` (saut)  | `setcc`           | `cmovcc` | Flags             |
| ----------------- | -------- | ------------: | ------------- | ----------------- | -------- | ----------------- |
| égal              | `a == b` |          tous | `je` / `jz`   | `sete` / `setz`   | `cmove`  | `ZF=1`            |
| non égal          | `a != b` |          tous | `jne` / `jnz` | `setne` / `setnz` | `cmovne` | `ZF=0`            |
| supérieur strict  | `a > b`  |     **signé** | `jg` / `jnle` | `setg`            | `cmovg`  | `ZF=0` & `SF=OF`  |
| supérieur ou égal | `a >= b` |     **signé** | `jge` / `jnl` | `setge`           | `cmovge` | `SF=OF`           |
| inférieur strict  | `a < b`  |     **signé** | `jl` / `jnge` | `setl`            | `cmovl`  | `SF≠OF`           |
| inférieur ou égal | `a <= b` |     **signé** | `jle` / `jng` | `setle`           | `cmovle` | `ZF=1` || `SF≠OF` |
| supérieur strict  | `a > b`  | **non signé** | `ja` / `jnbe` | `seta`            | `cmova`  | `CF=0` & `ZF=0`   |
| supérieur ou égal | `a >= b` | **non signé** | `jae` / `jnb` | `setae`           | `cmovae` | `CF=0`            |
| inférieur strict  | `a < b`  | **non signé** | `jb` / `jnae` | `setb`            | `cmovb`  | `CF=1`            |
| inférieur ou égal | `a <= b` | **non signé** | `jbe` / `jna` | `setbe`           | `cmovbe` | `CF=1` || `ZF=1`  |

| Intuition                 | `jcc`         | `setcc`           | Flags  |
| ------------------------- | ------------- | ----------------- | ------ |
| carry                     | `jc`          | `setc`            | `CF=1` |
| no carry                  | `jnc`         | `setnc`           | `CF=0` |
| overflow                  | `jo`          | `seto`            | `OF=1` |
| no overflow               | `jno`         | `setno`           | `OF=0` |
| signe (négatif)           | `js`          | `sets`            | `SF=1` |
| non signé (positif/zero)  | `jns`         | `setns`           | `SF=0` |
| parité paire              | `jp` / `jpe`  | `setp` / `setpe`  | `PF=1` |
| parité impaire            | `jnp` / `jpo` | `setnp` / `setpo` | `PF=0` |
| zéro (utile après `test`) | `jz` / `je`   | `setz` / `sete`   | `ZF=1` |
| non zéro                  | `jnz` / `jne` | `setnz` / `setne` | `ZF=0` |
